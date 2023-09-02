<#
 .Synopsis
  This script displays useful troubleshooting information tips for troubleshooting Remote Desktop 
  Protocol (RDP) Self Signed Certificate.

 .Description
  This script displays useful troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) Self Signed Certificate. It is intended to run on Windows Servers
  therefore it is not ideal for Windows clients such as Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get RDP Machine Keys Folder information for localhost only
   Get-RDPCertInfo

 .Example
   # Get RDP Machine Keys Folder information for remote computer specifying credentials to perform the operation.
   Get-RDPCertInfo -ComputerName NameRemoteComputer -Credentials YourCredentials  -IncludeHelpTips

 .Example
   # Display RDP Machine Keys Folder information for multiple computers with troubleshooting tips and 
   # useful links  specifying credentials to perform the operation.
   Get-RDPCertInfo -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials  -IncludeHelpTips
#>

	param (
        [Parameter()]
        [Alias("CN","MachineName","Com")]
        [string[]]$ComputerName  = @("localhost"),
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [Alias("GetHelp","GH","Help","HelpTips","IncludeTshootInfo")]
        [switch]$IncludeHelpTips
	)

function Get-RDPCertInfo{
    
    [CmdletBinding()]
	param (
        [Parameter()]
        [Alias("CN","MachineName","Com")]
        [string[]]$ComputerName  = @("localhost"),
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [Alias("GetHelp","GH","Help","HelpTips","IncludeTshootInfo")]
        [switch]$IncludeHelpTips
	)


    if($IncludeHelpTips)
    {
        Write-Warning "If you cannot connect via RDP you should take the following steps before Troubleshooting RDP Certificate."
        Write-Warning "You should check if RDP is enabled locally or via Group Policy using Get-RDPEnabled cmdlet."
        Write-Warning "Refer to help Get-RDPEnabled for more details`n"

        Write-Warning "You should use the Get-RDPListeners cmdlet to troubleshoot RDP Services"
        Write-Warning "Refer to help Get-RDPListeners for more details`n"

        Write-Host "Troubleshoot Self Signed RDP Certificate"
        Write-Host "==========================================`n"
        Write-Host "If you cannot connect to RDP having troubleshooted the listener then try deleting the Self Signed Certificate."
        Write-Host "After deleting the self signed certificate then restart the RDP service and retry connecting."
        Write-Host "A new self signed certificate should be generated after restarting the service."
        Write-Host "If a self signed certificate isn't generated the next step is to check the machine folders"
        Write-Host "Use the Get-RDPCertMachinePermissions to get the machine folder permissions"
        Write-Host "More information is provided in useful links`n"

    }

    foreach($Computer in $ComputerName)
    {
        $Cert = Invoke-Command -ComputerName $ComputerName -ErrorAction SilentlyContinue -Scriptblock {
            Get-ChildItem "Cert:\LocalMachine\Remote Desktop" 
        } -Credential $Credential

        Write-Host "RDP Certificate on $Computer"
        Write-Host "============================="

        Write-Host $Cert

        if($IncludeHelpTips)
        {
            if(!$Cert)
            {
               Write-Warning "RDP Certificate is absent on $Computer"
               Write-Host "If you have deleted the certificate and restarted the RDP Service and the certificate failed to generate"
               Write-Host "there may be a problem with Machine Folder Permissions"
               Write-Host "Use the Get-RDPCertMachinePermissions to get the machine folder permissions"
            }
        }
    }
    
    if($IncludeHelpTips)
    {
        Write-Host "Troubleshoot RDP Self Signed Certificate"
        Write-Host "https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/troubleshoot/rdp-error-general-troubleshooting#check-the-status-of-the-rdp-self-signed-certificate`n"
    }   
}

Get-RDPCertInfo -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips