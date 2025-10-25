---
title: 'Get All User Info On Local Device'
date: '2022-12-22 16:00:00 -0600'
categories: [Powershell]
tags: 
- endpoint
- powershell
- script
- registry 
author: blake
---

<h1> Powershell: Getting ALL User Accounts and SIDs </h1>

Using Powershell, you can easily get the local users on a machine using the [Get-LocalUser](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/get-localuser?view=powershell-5.1) cmdlet. However, this cmdlet does not see Active Directory or Azure AD users. I recently found myself with a need to identify all users on a device, so that I could then go and check some registry settings in that user's HKEY_USERS hive. To quickly discover the correct hive, I wanted a way to associate the username to the SID for AzureAD users.

<h2> Script </h2>

The following script identifies all users that have logged into the device via registry keys available in the Local Machine hive. It then processes those keys to get the ProfileImagePath and PSChildName properties. ProfileImagePath ends in the username of the user, and PSChildName will contain the SID. Our final output is a $userList object that contains the Username and SID properties.
 
``` powershell
$userList = get-ChildItem -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' | 
Get-ItemProperty -Name "ProfileImagePath" | Select-Object -Property ProfileImagePath, PSChildName 

foreach ($user in $userList) {
    $userName = ($user.ProfileImagePath -split "\\")[-1]
    $SID = ($user.PSChildName)
    $user | Add-Member -NotePropertyName Username -NotePropertyValue $userName
    $user | Add-Member -NotePropertyName SID -NotePropertyValue $SID
}

$userList = $userList | Select-Object Username, SID
```
 <br>

 This script is a great tool for Intune administrators, as the SIDs associated with AzureAD users are not as accessible as local users. You also don't have the Active Directory powershell model to assist with this. You could discover the SID by using the [Get-AzureADUser](https://learn.microsoft.com/en-us/powershell/module/azuread/get-azureaduser?view=azureadps-2.0) cmdlet, however this requires you to already be in cloudshell.

 <h2>Use Cases </h2>

 1. Checking if registry changes you made have taken effect for users yet, without jumping into the local session
 2. SyncroMSP scripting - if you need to make changes against an AzureAD based user, you can start with this script to identify the user and run your changes against their HKEY_USER hive.
 3. Identifying AzureAD SIDs from the user list, so that you can identify users without having to look up the device in Intune and view the audit

 <h2> Other Considerations </h2>
This script can be run in the user space - no elevation required. However, to work with other users' registry keys you must elevate the session. 


<h1> Conclusion </h1>

This script is meant to help you identify and work with user accounts that will not be identified by the Get-LocalUsers cmdlet. These are typically AzureAD users. 

This is a corner case, as most of the time you can simply run your script during user login in the user space to make changes to the HKCU hive. 

<h1>Update </h1>

This can also be solved more simply by elevating your session and using the wmic command. 

{% highlight batch %}
wmic useraccount get name,sid
{% endhighlight %}

<h2> Contact Me! </h2>

Did you find this helpful? Maybe discovered a flaw? Please contact me at:
-  blake@foxlabsolutions.com
- [Linkedin!](https://www.linkedin.com/in/blake-fox-b2a3171b2/)
