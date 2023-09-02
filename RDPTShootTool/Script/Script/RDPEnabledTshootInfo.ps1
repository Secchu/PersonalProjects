<#
 .Synopsis
  This script displays troubleshooting information and tips for troubleshoot whether Remote Desktop 
  Protocol (RDP) is enabled locally or through Group Policy.

 .Description
  This script displays troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) configuration. It is intended to run on Windows Servers therefore it is not ideal for  
  Windows clients such as Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get RDP configuration information for localhost only
   Get-RDPEnabled

 .Example
   # Get RDP configuration information for remote computer specifying credentials to perform the 
   # operation.
   Get-RDPEnabled -ComputerName NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips

 .Example
   # Display RDP configuration information for multiple computers with troubleshooting tips and 
   # useful links specifying credentials to perform the operation.
   Get-RDPEnabled -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips
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

function Get-RDPEnabled {
    
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

    $GPOReg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
    $localReg = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'

    write-host "RDP INFORMATION"
    write-host "===============`n`n"

    foreach($Computer in $ComputerName)
    {
        try
        {
            Write-Host "Getting RDP Enabled for $Computer"
            Write-Host "---------------------------------`n"

            $GPConfig = Invoke-Command -ComputerName $Computer -ScriptBlock {
            Get-ItemProperty -Path $using:GPOReg -ErrorAction SilentlyContinue -Name "fDenyTSConnections" | select "fDenyTSConnections"
            } -Credential $Credential
        
            
            $LocalConfig = Invoke-Command -ComputerName $Computer -ScriptBlock {
            Get-ItemProperty -Path $using:localReg -ErrorAction SilentlyContinue -Name "fDenyTSConnections" | select "fDenyTSConnections"
            } -Credential $Credential
        
            $LocalConfigEnum = 2
            $GPConfigEnum = 2

            if($GPConfig)
               { $GPConfigEnum = $GPConfig.fDenyTSConnections }

            if($LocalConfig)
               { $LocalConfigEnum = $LocalConfig.fDenyTSConnections }

            
            $LocalConfigMsg = Get-RDPEnabledCheckMsg $LocalConfigEnum  
            $GPConfigMsg = Get-RDPEnabledCheckMsg $GPConfigEnum
            
            Write-Host "Local Configuration of RDP: $LocalConfigMsg"
            Write-Host "Group Policy Configuration of RDP Detection: $GPConfigMsg" 

            if($IncludeHelpTips)
            {
                Write-Host "`nTroubleshooting Warnings Info for $Computer"
                Write-Host "=============================================`n"

                
                if($LocalConfigEnum -eq 1)
                    {Write-Warning "RDP is blocked locally`n" }

                if($GPConfigEnum -eq 1)
                {
                    Write-Warning "RDP is blocked by Group Policy."
                    Write-Warning "Even if you try to change the registry value to fDenyTSConnections locally it will revert back to 1`n"
                }
                if($LocalConfigEnum -lt 2 -and $GPConfigEnum -lt 2)
                {
                    Write-Warning "Group Policy and Local Policy Configuration Detected"
                    Write-Warning "Group Policy can override settings for local configuration`n"

                }
            }
             
         }catch
         {
           Write-Error "Error getting the RDP Details for $Computer"

         }

        
    }

    if($IncludeHelpTips)
    {
         Write-host "RDP TROUBLESHOOTING TIPS"
         Write-host "=========================`n`n"
         Write-Host "RDP is enabled or disabled via two registry keys"
         Write-Host "Local Configuratio: $localReg"
         Write-Host "Group Policy Configuration: $GPOReg"
         Write-Host "If the value of the fDenyTSConnections key is 0, then RDP is enabled"
         Write-Host "If the value of the fDenyTSConnections key is 1, then RDP is disabled`n"

         Write-Host "To check local configuration for RDP use the following cmdlet"
         Write-Host 'gpresult /H c:\gpresult.html' + "`n"
         Write-Host "To check the Group Policy configuration on a remote computer, the command is almost the same as for a local computer"
         Write-Host "gpresult /S <computer name> /H c:\gpresult-<computer name>.html`n"
         Write-Host "In Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Connections, find the Allow users to connect remotely by using Remote Desktop Services policy`n"
         Write-Host "Refer to the link below for troubleshooting RDP"
         Write-Host "https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/troubleshoot/rdp-error-general-troubleshooting`n"
    }

}

function Get-RDPEnabledCheckMsg
{
    param(
        [Parameter(Mandatory=$True)]
        [ValidateRange(0, 2)]
        [int]$value
    )

    $Configured = @("Enabled","Disabled","Not Configured")

    return "$($Configured[$value])"
}

Get-RDPEnabled -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips 