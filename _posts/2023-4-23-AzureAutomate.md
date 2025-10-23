---
title: 'Azure AD Automation: A Modern Graph Powershell SDK Approach'
date: '2023-4-23 17:00:00 -0600'
categories: [Azure, Powershell]
tags: 
- azure
- automation
- graphAPI
- AzureAD
- powershell
author: blake
---
# Introduction 
As more enterprises move to AzureAD as their core Identity Provider, security and identity administrators face an ever expanding landscape of conditional access, user objects, groups, and external users. To manage their expanding tenants, Administrators need tools to automate repeatable tasks, or develop solutions to novel situations. 

In this article, we will use Azure Automation and the Graph API Powershell SDK to programatically make changes to an AzureAD tenant on a schedule. 

# Enter: Azure Automation and Graph Powershell SDK

Process Automation in Azure Automation allows you to automate frequent, time-consuming, and error-prone management tasks. This service helps you focus on work that adds business value. By reducing errors and boosting efficiency, it also helps to lower your operational costs. The process automation operating environment is detailed in Runbook execution in Azure Automation.

__A note on security: Azure Automation will use Microsoft managed encryption, with the option of adding your own keys and secret management with Azure Key Vault. Credentials, Certificates, Connections, and user-selected variables are all encrypted. Self Managed Keys are not covered in this article.__ 

# Set Up Automation Account
Before you can use Azure Automation on Azure AD, you must complete the following steps. 

1. Create an Azure Automation Account in the Azure portal. 
2. Create an App Registration in the desired AD Tenant. 
3. Generate a certificate for authentication of your application against AzureAD. It is recommended that you generate this certificate on a secure jumpbox or virtual machine. 

{% highlight powershell %}
$certname = "{certificateName}"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter (Get-date).AddMonths(24)
{% endhighlight %}

4. Export the certificate as a .cer and as a .pfx. 

{% highlight powershell %}
Export-Certificate -Cert $cert -FilePath "C:\Users\YOURUSER\Desktop\$certname.cer"   ## Specify your preferred location

$mypwd = ConvertTo-SecureString -String "{myPassword}" -Force -AsPlainText  ## Replace {myPassword}

Export-PfxCertificate -Cert $cert -FilePath "C:\Users\admin\Desktop\$certname.pfx" -Password $mypwd   ## Specify your preferred location
{% endhighlight %}
5. Upload the .cer to AzureAD. After uploading, annotate the ClientID and TenantID of your App Registration from  the 'overview' tab. We will need these for later. 

![App Reg Cert](/assets/images/2023-4-18-AzureAutomate/appregCert.jpg)

6. Upload the .pfx to the Automation Account  

![Upload PFX to Automation Account](/assets/images/2023-4-18-AzureAutomate/automationCert.jpg)

7. Delete the certificate from local keystore and remove files from your machine.

{% highlight powershell %}
Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -Match "$certname"} | Select-Object Thumbprint, FriendlyName

# copy the thumbprint you found and paste it into the path below

Remove-Item -Path Cert:\CurrentUser\My\{pasteTheCertificateThumbprintHere} -DeleteKey
{% endhighlight %}

Congratulations! Your Automation account is now ready to communicate with Azure AD. You will now need to determine the permissions your Automate account will need to perform your desired actions. Remember, least privilege should be followed. 

---

# Discovery: What Cmdlets, modules, and permissions do I need?

Many administrators are migrating from the MSOnline and AzureAD powershell modules to Microsoft Graph. If you have an existing script, you can find your current cmdlets and map them against the new Graph cmdlets using [this list](https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0). 

## Permissions
In this example, I am using the *Update-MgIdentityConditionalAccessPolicy* cmdlet. From there a quick web search will bring me to the Graph API method *"[Update conditionalaccesspolicy](https://learn.microsoft.com/en-us/graph/api/conditionalaccesspolicy-update?view=graph-rest-1.0&tabs=http)"*. We can then view the permissions table. Since we are deploying an Application, we will pay attention to the "Application permissions": 
- Policy.Read.All
- Policy.ReadWrite.ConditionalAccess
- Application.Read.All

We will need to add these permissions and authorize them on our App Registration before we can manipulate Conditional Access Policies from our Automate account. Additionally, annotate the source modules for the cmdlet: In the example, we are using:
- microsoft.graph.identity.signins
- microsoft.graph.authentication

We will need to add these modules to our Automate Account - more on that later. 

## Permissions Finder: Graph Explorer
[Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) is a great way to discover the necessary permissions for your actions. Once you have the action you want to perform, you can run the action and analyze the permissions in Graph Explorer.  

### Add Permissions to App Registration in Azure AD

We need to authorize our automation account to make the changes that we desire. To do so, you can modify the 'API Permissions' of the app. Add the Graph API permissions as Application Permissions, and then grand admin consent. There are some known bugs with the conditional access module, so, you may have to play with the permissions a little more to get everything just right.

![API Permissions](/assets/images/2023-4-18-AzureAutomate/addAPIPermissions.jpg)

---

# Deploy the Runbook

## Add a Module
Before we dive into script, we will need to install the following modules:

- *microsoft.graph.authentication*

This module is a key dependency for all microsoft.graph modules in powershell. No other Graph modules will download properly without this module installed in your Automation account

![Add a module in Azure AD Automation Account](/assets/images/2023-4-18-AzureAutomate/addModuleAZAuto.jpg)

Select 'Browse from gallery' and search for the module name. Note that you must select a runtime version. From my testing, I had an issue with the 7.2 and 7.1 previews due to a Newtonsoft json dependency failure. You may be able to get this working, but in my case I chose the 5.1 Powershell runtime instead.  

After you let the authentication module install, you can return to the gallery and repeat the process for:

-  *microsoft.graph.identity.signins*

This will be the module that our primary cmdlets will be housed in. 

## Create Variables

Remember the Tenant and Application IDs from earlier? We'll need to add them now to our Automation Account as variables. You can store these as plaintext, or encrypt them and expose them only at runtime. Encrypted variables will not be viewable outside of playbook runtime. I encrypt mine here. 

- Client ID
- Tenant ID
- Cert Thumbprint
- Policy ID of a Conditional Access

![Add variables in Automation account](/assets/images/2023-4-18-AzureAutomate/addVariables.jpg)

## Write your Runbook

We are now ready to start writing our Powershell Runbook. 

![Add a module in Azure AD Automation Account](/assets/images/2023-4-18-AzureAutomate/runbookSettings.jpg)

>Make sure when creating your runbook that your runtime matches the module that you installed - 5.1 in our case. 

Once the Runbook is created, you can use the following powershell code as an example of how to interact with a conditional access policy. While this is a simple interaction, you now have access to all of the tools available from powershell to write code for your Azure AD environment.

{% highlight powershell %}
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.Signins

$ClientID = Get-AutomationVariable -Name 'azureADAutomationClient'
$TenantID = Get-AutomationVariable -Name 'azureADAutomationDirectory'
$Thumbprint = Get-AutomationVariable -Name 'appCertThumbprint'
$PolicyID = Get-AutomationVariable -Name 'CAPolicyID'

#log into Graph API 
Connect-MgGraph -clientID $ClientID -tenantId $TenantID -certificatethumbprint $Thumbprint

#Get the current state of the conditional access policy
Get-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyID $PolicyID 

Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyID $PolicyID -State "Enabled"

#Get the now modified state of the conditional access policy
Get-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyID $PolicyID
{% endhighlight %}

>You may come across some errors due to permissions - you will likely need to go back to your App Registration and add additional permissions to get the script to work. 

---

# Why Not Logic Apps?

Logic Apps has its own managed connection with Azure AD. However, Logic Apps also only has specific API endpoints exposed as part of the 'built in' connection. This means that you would still need to write code to create the automations possible from using the Graph Powershell SDK. The Azure team has a great example of using a Logic App for managing large scale deployment of Conditional Access Policies. For me, an Automation Powershell based approach was sufficient to achieve my goals in a language I am familiar with. You can make calls to Azure Automation from Logic Apps, so there is the possibility to combine these approaches at a later time. 

- [Azure Logic App Example](https://github.com/Azure-Samples/azure-ad-conditional-access-apis)

# Conclusion

Azure Automation Accounts, combined with the Microsoft Graph Powershell SDK, provide a powerful toolset to automate and extend on identity management in Azure AD. While the sample deployment was fairly simple in it's output, the same framework can be used to deploy all kinds of changes. Some potential examples: 

- Automated removal of stale guest accounts from your tenant after a set age
- Replication of conditional access policies and groups from one tenant to another
- Snapshots and backups of Azure AD configuration 

Azure Automation accounts can be triggered in a multitude of ways - you can configure webhooks for runbooks, manual triggers, or even run them on a schedule. With an Automation account, you can expand your ability to interact with Azure AD as Code and start to ingest your Identity Management into your DevSecOps pipeline. 

## Contact Me!

Did you find this helpful? Maybe discovered a flaw? Please contact me at:
-  bfox@adaptivedge.com
- [Blake Fox Linkedin](https://www.linkedin.com/in/blake-fox-b2a3171b2/)

## References

- [AzureAD and MSOnline Mapped to Graph SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0)
- [Automate Entra Identity Governance with Azure Automation](https://learn.microsoft.com/en-us/azure/active-directory/governance/identity-governance-automation)
- [Create a Self Signed Certificate](https://learn.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2019-ps&preserve-view=true)
- [Authenticate your App to AzureAD](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-self-signed-certificate)
- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
- [Graph API Conditional Access Examples](https://github.com/Azure-Samples/azure-ad-conditional-access-apis/tree/main/01-configure/graphapi)
- [Graph API Conditional Access API](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy?view=graph-rest-1.0)

