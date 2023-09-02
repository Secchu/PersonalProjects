<#
 .Synopsis
  This script displays detailed troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP).

 .Description
  This script displays detailed troubleshooting information tips for troubleshooting Remote Desktop 
  Protocol (RDP). This tool calls other RDP troubleshooting tips in the module. It is intended to run on 
  Windows Servers therefore it is not ideal for  Windows clients such as Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get detailed troubleshooting information for localhost only
   \RDPTShootTool.ps1

 .Example
   # Get detailed troubleshooting information for remote computer specifying credentials to perform the 
   # operation.
    \RDPTShootTool.ps1 -ComputerName NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips

 .Example
   # Display detailed troubleshooting information for multiple computers with troubleshooting tips and 
   # useful links specifying credentials to perform the operation.
    \RDPTShootTool.ps1 -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips
#>

param(
        [Parameter()]
        [Alias("CN","MachineName","Com")]
        [string[]]$ComputerName  = @("localhost"),
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [Alias("GetHelp","GH","Help","HelpTips")]
        [switch]$IncludeHelpTips = $false
)

. C:\Users\Administrator\Documents\Sec\RDPEnabledTshootInfo.ps1 -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips 
. C:\Users\Administrator\Documents\Sec\GetRDPServices.ps1 -ComputerName $ComputerName -IncludeHelpTips:$IncludeHelpTips
. C:\Users\Administrator\Documents\Sec\RDPFirewallTshootInfo.ps1 -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
. C:\Users\Administrator\Documents\Sec\RDPListenerPortTshootInfo.ps1 -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
. C:\Users\Administrator\Documents\Sec\RDPCertTshootInfo.ps1 -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
. C:\Users\Administrator\Documents\Sec\RDPMachineKeysFolderTshootInfo.ps1 -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips

