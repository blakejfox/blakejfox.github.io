---
title: 'Intune Application Packaging'
date: '2022-12-19 17:00:00 -0600'
categories: [Intune, Powershell]
tags: endpoint, mdm, intune, autopilot    
author: blake
---

# Intune: Your Best Friend for Business Applications

Microsoft **Intune** is a product that has brought features previously only available to Enterprise users to small businesses across the world. By leveraging Azure AD and Microsoft Intune, companies can reduce friction for users. 

## Standard Methods for Application Deployment
 
 You can officially deploy many types of applications via Microsoft Intune, including: 

 1. Win32 apps
 2. Offline licensed Microsoft Store for Business apps
 3. LOB Apps (MSI, Appx, and MSIX)
 4. Microsoft 365 Apps for Business

 Support for these types of applications is great, and typically they can be deployed seamlessly. However, sometimes an application is obfuscated by the developer or does not follow best practices for deployments. In these circumstances, you may only have an .EXE file available to use as an installer, and no good way to package this application via the [Win32 Content Prep Tool](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool). 

 ## Deploying Installers Via Powershell

 The solution is to use a powershell script to deploy your script via powershell. In the example given, we use a public repository to host our installer. 

 **Consider the security implications before placing your executables on a public facing repository**

 ```powershell

 $url = "https://get.diagrams.net/"
$outpath = "$PSScriptRoot/drawio.exe"
Invoke-WebRequest -Uri $url -OutFile $outpath
Start-Process -Filepath "$PSScriptRoot\drawio.exe" -WorkingDirectory "$PSScriptRoot"
 ```

 Depending on your application, you may still be able to determine valid arguments using the [strings](https://learn.microsoft.com/en-us/sysinternals/downloads/strings) utility. It is a good idea to output this to a file for review. 
 
 ```batch
strings draw.io-20.6.2-windows-installer.exe > param.txt
 ```

Unfortunately, we do not learn of any flags for this executable. We can see that the application is open source and available at https://github.com/jgraph/drawio. 

Once you have determined the necessary flags, you can upload this script to Intune under 'scripts' and target it to your desired groups. 

![Intune Endpoint Scripts](/assets/images/2022-12-19-intunepackages/scripts-deployment.png)

For this example, I might be installing the application for my network and sales engineers. 

![Assign or Exclude Users](/assets/images/2022-12-19-intunepackages/scripts-assignment.png)

Once you push this script to the assigned users or machines, start process will execute this upon next start up. 

# Conclusion 

This is a secondary way to deploy publicly available (or known repository) applications through Intune. 

Under most circumstances, I would recommend this order of choice when deploying an application: 

1. Apps for Business Native Deployment 
2. Microsoft Store Deployment
3. LOB Apps
4. Win32 Apps
5. Powershell Script Deployment

Native deployment will always be easy to update in the future. Windows Store apps will update automatically, making them a preferred method if the app is available via the Store. 

Once you are maintaining LOB (MSI, APPX, etc) applications, [Win32 Content Prepared Apps](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool), or powershell script deployed applications, you will need to implement manual checks to keep the applications up to date. This will need to be built into your monthly or quarterly review, and can start to take significant engineer time to maintain if you have a large suite of applications. 

###Contact Me!

Did you find this helpful? Maybe discovered a flaw? Please contact me at blake@foxlabsolutions.com, or connect with me on [Linkedin!](https://www.linkedin.com/in/blake-fox-b2a3171b2/)