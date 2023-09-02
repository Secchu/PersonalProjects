Project
=======
This project is something I done in my spare time. It toubleshoots Remote Desktop Services on Windows Server. Note like most Powershell commands, CLI commands
it does not resolve the issue for you. Like most tools it just relays information back to the user. In otherwords it displays information to the Administrator
and it would be up to the Administrator to troubleshoot the problem.

The troubleshooting steps in which the script is based can be found on the link below. It is a link to the Microsoft Learn article on how to troubleshoot 
RDP.

https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/troubleshoot/rdp-error-general-troubleshooting

Features: It uses aliases on some parameters ie. The $ComputerName parameter has the alias of "CN","MachineName","Com" meaning you can use any of those
aliases in place of $ComputerName. Using the shorthand $CN is perfectly valid shorthand for $ComputerName. It contains switches activating the option 
to display useful website links. It contains a switch called $IncludeHelpTips where when used will show information and tips on how to troubleshoot the
issue further.

Here are the general steps it uses to gather troubleshooting information.

1. Checks the status of the RDP protocol on local or remote machine. You can do this by checking the status of the following registry key

HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services

Then checking the status of the following registry value


    If the value of the fDenyTSConnections key is 0, then RDP is enabled.
    If the value of the fDenyTSConnections key is 1, then RDP is disabled.

2. Checks whether the registry key is set through local or group policy.

3. Check the status of the RDP services.

On both the local (client) computer and the remote (target) computer, the following services should be running:

    Remote Desktop Services (TermService)
    Remote Desktop Services UserMode Port Redirector (UmRdpService)

4. Check the status of the RDP self-signed certificate

5. Check the permissions of the MachineKeys folder C:\ProgramData\Microsoft\Crypto\RSA\

6. Check the RDP listener port 3389 and get the name of the process that is using that port.

7. Checks that RDP is enabled through the Windows Firewall

Files
=====
The project consists of two folders. The scripts folder contains all Powershell scripts. Each script provides separate troubleshooting information
for troubleshooting RDP.

The RDPTShoot folder contains the .psd1 and the .psm1 file required for registering the commandlets as a module. This of course is an optional
step and is not required.

Scripts in the Script Folder
============================

GetRDPServices.ps1
------------------
Gets the RDP services running on the local or remote server.

RDPCertTshootInfo.ps1
---------------------
Gets information of the RDP Self Signed certificate on the local and remote server.

RDPEnabledTshootInfo.ps1
------------------------
Displays troubleshooting information about how RDP is enabled on the local or remote servwer. Displays information about the 
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services registry key whether it was enabled through local
or group policy.

RDPFirewallTshootInfo.ps1
-------------------------
Tests to see if RDP firewall rules is enabled on the local or remote server.

RDPListenerPortTshootInfo.ps1
-----------------------------
Gets the process name of the process listening on the RDP port such as port 3389

RDPMachineKeysFolderTshootInfo.ps1
----------------------------------
Displays the machine key folder permissions. ("C:\ProgramData\Microsoft\Crypto\RSA\")

RDPTshootTool.ps1
-----------------
Each breaking the task in small individual steps and more manageable tasks this is the main tool which executes all the scripts in turn to display as 
much troubleshooting information to the Administrator regarding RDP. You may want to modify the paths of the script files as it uses absolute paths.

Example Usage
=============
Please refer to the scripts comments. However I have provided a few examples below. WIN-1RM6N8V856J is name of remote
server.

Display information on RDP Listeners
.\Get-RDPListeners -CN localhost,WIN-1RM6N8V856J -IncludeHelpTips:true

Display information on RDP Self signed certificate
$Credential = Get-Credential
.\Get-RDPCertInfo -Com localhost,WIN-1RM6N8V856J -Credential $Credential -IncludeHelpTips:true

Detect local and any group policies affecting RDP (Check registry key value)
$Credential = Get-Credential
.\Get-RDPEnabled -Com localhost,WIN-1RM6N8V856J -Credential $Credential -IncludeHelpTips:true

Display RDP Firewall rules troubleshooting information
$ComputerName = "WIN-1RM6N8V856J"
$Credential = Get-Credential
.\Get-RDPFireWallRuleTshootInfo -CN $ComputerName -Credential $Credential -IncludeHelpTips

Displays Troubleshooting information on MachineKeys folder
.\Get-RDPListenerTshootInfo -ComputerName localhost,WIN-1RM6N8V856J -IncludeHelpTips

Display all Troubleshooting information
RDPTshootTool.ps1
$Credential = Get-Credential
.\RDPTShootTool.ps1 -CN localhost,WIN-1RM6N8V856J -Credentials $Credential -IncludeHelpTips

Registering the module
======================
The process for registering any PowerShell module is the same. 

Refer to the following link 
https://learn.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.3

More information
================
You can get more information about this tool from the link below which is a AWS CloudFront link to my S3 Static website.

https://d2n2rgkzriycso.cloudfront.net/Demos/PSModule-Part1.html