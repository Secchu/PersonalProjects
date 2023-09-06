<#
 .Synopsis
  This script displays troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) Firewall Rules.

 .Description
  This script displays troubleshooting information tips for troubleshooting Remote Desktop 
  Protocol (RDP) Firewall Rules. It is intended to run on Windows Servers therefore it is not ideal for  
  Windows clients such as Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get detailed troubleshooting information for localhost only
   Get-RDPFireWallRuleTshootInfo

 .Example
   # Get detailed troubleshooting information for remote computer specifying credentials to perform the 
   # operation.
   Get-RDPFireWallRuleTshootInfo -ComputerName NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips

 .Example
   # Display detailed troubleshooting information for multiple computers with troubleshooting tips and 
   # useful links specifying credentials to perform the operation.
   Get-RDPFireWallRuleTshootInfo -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips
#>

param(
        [Parameter()]
        [Alias("CN","MachineName")]
        [string[]]$ComputerName  = @("localhost"),
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [Alias("GetHelp","GH","Help","HelpTips")]
        [switch]$IncludeHelpTips = $false
)

function Get-RDPFireWallRuleTshootInfo
{
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
        Write-Host "RDP FIREWALL RULES TROUBLESHOOTING"
        Write-Host "==================================`n"

        Write-Host "This tool checks the inbound rules for RDP is enabled."
        Write-Host "You can enable all RDP Firewall Rules using the following cmdlet"
        Write-Host 'Get-NetFirewallRule -DisplayName `"Remote `Desktop`" -CimSession <CimSession[]> | Enable-NetFirewallRule'
    }

    foreach($Computer in $ComputerName)
    {
        try
        {
        
            $Cim = New-CimSession -ComputerName $Computer -Credential $Credential -Verbose
            $FirewallRules = Get-NetFirewallRule -DisplayGroup "Remote Desktop" -CimSession $Cim

            foreach($FwRule in $FirewallRules)
            {
                $FwRule

                if(($IncludeHelpTips) -and ($FwRule.Enabled.ToString() -eq "False"))
                {
                    $DisplayName = $FwRule.DisplayName
                    Write-Warning "$DisplayName Firewall Rule is disabled."
                    Write-Host "You can use the following cmdlet to enable this firewall rule"
                    Write-Host "Enable-FirewallRule -DisplayName `"$DisplayName`" -CimSession <CimSession[]>`n" 
                }
            }

            $Cim | Remove-CimSession

        }catch
        {
            Write-Error "There is an error establishing connection to $Computer"
        }
    }

    if($IncludeHelpTips)
    {
        Write-Host "USEFUL LINKS"
        Write-Host "=============`n"

        Write-Host "Windows Defender Firewall"
        Write-Host "https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/windows-firewall-with-advanced-security`n"

        Write-Host "Get-Firewall Cmdlet"
        Write-Host "https://learn.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallrule?view=windowsserver2022-ps`n"

        Write-Host "Enable-NetFirewallRule Cmdlet"
        Write-Host "https://learn.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallrule?view=windowsserver2022-ps`n"

    }
}

Get-RDPFireWallRuleTshootInfo -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips