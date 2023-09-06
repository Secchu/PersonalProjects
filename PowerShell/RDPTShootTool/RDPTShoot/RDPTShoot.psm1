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

<#
 .Synopsis
  This script displays useful troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) on Windows Servers.

 .Description
  This script displays the RDP dependencies and their current status. It is intended to run on Windows Servers
  therefore it is not ideal for Windows clients such as Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get RDP Listeners troubleshooting information for localhost only
   Get-RDPListeners

 .Example
   # Get RDP Listeners troubleshooting information for remote computer.
   Get-RDPListeners -ComputerName NameRemoteComputer -IncludeHelpTips

 .Example
   # Display RDP Listeners troubleshooting information for multiple computers with troubleshooting tips and 
   #useful links
   Get-RDPListeners -ComputerName localhost,NameRemoteComputer -IncludeHelpTips
#>

function Get-RDPListeners {

    [CmdletBinding()]
	param (
        [Parameter()]
        [Alias("CN","MachineName","Com")]
        [string[]]$ComputerName  = @("localhost"),
        [Alias("GetHelp","GH","Help","HelpTips","IncludeTshootInfo")]
        [switch]$IncludeHelpTips
	)
    
    if($IncludeHelpTips)
    {
        Write-Host "`nRDP SERVICES TROUBLESHOOTING INFO"
        Write-Host "=================================`n"

        Write-Host "RDP depends on two services running."
        Write-Host "RDP depends on Remote Desktop Services (TermService) and Remote Desktop Services UserMode Port Redirector (UmRdpService)`n"
        Write-Host "You can either use the services console snap in to start the service and the PowerShell Start-Service cmdlet"
        Write-Host "If any RDP Listener Services are not started then start them. Below is the Start-Service Cmdlet to start the Service`n"

        Write-Host "If a service still fails to start you should check the users rights. By default you need administrative rights."
        Write-Host "There are various ways to restrict admin users to start a service listed below."
        Write-Host "1. Use Group Policy"
        Write-Host "2. Use Security Templates"
        Write-Host "3. Use Subinacl.exe`n"

        Write-Host "Troubleshoot RDP Listener"
        Write-Host "=========================`n"
        Write-Host "You can check the status of a RDP Listener by using the Starting a PSSession on remote computer"
        Write-Host "Use the qwinsta command to see the status of a RDP Listener"
        Write-Host "If the status shows Listen then RDP Listener is working`n"

        Write-Host "Enter-PSSession -ComputerName <computer name>"
        Write-Host "Enter qwinsta`n"

        Write-Host "More information can be found on the useful links below which also contains procedures to import and exporing RDP Configuration`n"
        Write-Warning "WARNING: You should backup your registry before making modifications to registry"

    }

    foreach($Computer in $ComputerName)
    {    
               
       $Services = Get-Service -ComputerName $Computer -DisplayName "Remote Desktop Service*" 
       
       $Services | select Name,DisplayName,Status | ft

        if($IncludeHelpTips)
        {

            Write-Host "RDP Services Running on $Computer"
            Write-Host "---------------------------------------`n"

            $StoppedService = $Services | Where-Object -Property Status -eq 'Stopped'
            $RunCount = ($StoppedService | measure).Count

            if($RunCount -eq 0)
                {Write-Host "No Actions to recommend for $Computer because all RDP services are running on $Computer`n"}

            else
            {
               Write-Warning "The following RDP Service is stopped and needs to be started on $Computer`n"
               $StoppedService | select Name,DisplayName,Status | fl
            }
       }
   }

       if($IncludeHelpTips)
       {
            Write-Host "Useful Links"
            Write-Host "-------------`n"
        
            Write-Host "Start-Service Cmdlet"
            Write-Host "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-service?view=powershell-7.3`n"

            Write-Host "Get-Service Cmdlet"
            Write-Host "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-service?view=powershell-7.3`n"

            Write-Host "How to grant users rights to manage services"
            Write-Host "https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/grant-users-rights-manage-service`n"

            Write-Host "How To Configure Group Policies to Set Security for System Services"
            Write-Host "https://learn.microsoft.com/en-US/troubleshoot/windows-server/group-policy/configure-group-policies-set-security`n"
        
            Write-Host "Troubleshoot RDP Listener"
            Write-Host "Troubleshoot permissions of the MachineKeys folder"
            Write-Host "permissions of the MachineKeys folder"
            Write-Host "https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/troubleshoot/rdp-error-general-troubleshooting`n"
       }
}

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

function Get-RDPCertInfo {
    
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
        }

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

<#
 .Synopsis
  This script displays troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) Listener.

 .Description
  This script displays troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) port and the process that listens to the port for incoming RDP connrections. 
  It is intended to run on Windows Servers therefore it is not ideal for Windows clients such as 
  Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get RDP listener information for localhost only
   Get-RDPListenerTshootInfo

 .Example
   # Get RDP listener information for remote computer specifying credentials to perform the 
   # operation.
   Get-RDPListenerTshootInfo -ComputerName NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips

 .Example
   # Display RDP listener information for multiple computers with troubleshooting tips and 
   # useful links specifying credentials to perform the operation.
   Get-RDPListenerTshootInfo -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips
#>

function Get-RDPListenerTshootInfo {

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
        Write-Host "The port number used by client and server is port 3389.`n"
        Write-Warning "`nWarning: You can change the port number from the following Registry Valeue"
        Write-Warning "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\PortNumber`n"
        Write-Warning "Without good reason you should RDP on the default port 3389."
        Write-Warning "You should not change the port number."
        Write-Warning "WARNING: You should backup your registry before making modifications to registry`n"
    }

    foreach($Computer in $ComputerName)
    {
        $DefaultPort = 3389
        $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"

        Write-Host "`nRDP LISTENER TROUBLESHOOTING INFO FOR $Computer"
        Write-Host "--------------------------------------------------------`n"

        $Port = Invoke-Command -ComputerName $Computer -ScriptBlock {
            Get-ItemPropertyValue -Path $using:RegPath -ErrorAction SilentlyContinue -Name "PortNumber" 
            } -Credential $Credential
        
        if($null -eq $Port)
        {$Port = $DefaultPort}

        if($IncludeHelpTips -and ($Port -ne $Port))
        {
            Write-Warning "It is not recommended to change the default RDP Port"
            Write-Warning "You should leave the port on 3389`n"
        }

        $Connection = Get-NetTcpConnection  -LocalAddress 0.0.0.0 -LocalPort $Port

        if(!$Connection)
        {
            Write-Host "Process Listening on Port $Port" + ": No Process Detected"
            
            if($IncludeHelpTips)
            {
                Write-Warning "The RDP Listener hasn't started. Try restarting the RDP Service"
                Write-Host "Refer to Get-RDPListeners for help`n"
                Write-Host "Alternatively use the following cmdlet to try and start the service"
                Write-Host "Start-Service -DisplayName'Remote Desktop Services'"
            }
            
            continue
        }

        $Connection

        $OwningProcess = $Connection.OwningProcess
        
        $ProcessName = Get-Process -Id $OwningProcess | select ProcessName

        if($IncludeHelpTips)
        {
            if($ProcessName -ne "svchost")
            { Write-Host `n"The RDP Listener is listening on the configured port`n" }
            else
            {
                Write-Warning "A process is preventing RDP from listening on port $Port"
                Write-Host "Configure the other application or service to use a different port (recommended)."
                Write-Host "Uninstall the other application or service."
                Write-Host "Configure RDP to use a different port, and then restart the Remote Desktop Services service (not recommended).`n"
            }
        }
   }

   if($IncludeHelpTips)
   {
        Write-Host "Useful Links"
        Write-Host "-------------`n"

        Write-Host "Troubleshooting RDP Listener"
        Write-Host "https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/troubleshoot/rdp-error-general-troubleshooting`n"
   }
   
}

<#
 .Synopsis
  This script displays useful troubleshooting information tips for troubleshooting Remote Desktop 
  Protocol (RDP) Self Signed Certificate.

 .Description
  This script displays useful troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) Self Signed Certificate. It is intended to run on Windows Servers
  therefore it is not ideal for Windows clients such as Windows 10 or Windows 11. This is intended to be
  used as a troubleshooting tool for troubleshooting RDP.

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


<#
 .Synopsis
  This script displays useful troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP) Machine Keys Folder.

 .Description
  This script displays useful troubleshooting information tips for troubleshooting Remote Desktop 
  Protocol (RDP) Machine Keys Folder. It is intended to run on Windows Servers therefore it is not ideal for 
  Windows clients such as Windows 10 or Windows 11. 

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get RDP Machine Keys Folder information for localhost only with the Credentials of the user
   Get-RDPCertFolderTshootInfo

 .Example
   # Get RDP Machine Keys Folder information for remote computer with manual credentials
   Get-RDPCertFolderTshootInfo -ComputerName NameRemoteComputer YourCredentials -IncludeHelpTips

 .Example
   # Display RDP Machine Keys Folder information for multiple computers with troubleshooting tips and 
   # useful links specifying Credentials to perform the operation.
   Get-RDPCertFolderTshootInfo -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips
#>

function Get-RDPCertFolderTshootInfo
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
        Write-Host "TROUBLESHOOTING MACHINEKEYS FOLDER PERMISSIONS"
        Write-Host "==============================================`n"
        Write-Warning "When troubleshooting RDP you should first check if RDP is enabled using Get-RDPEnabled cmdlet."
        Write-Warning "If RDP is enabled you should then check the RDP Listener, Certificate and then Self Signed Cert before MachineKeys Folder ACL."
        Write-Warning "Please refer to the help section of Get-RDPListeners and Get-RDPCertInfo cmdlet.`n"

        Write-Host "For the Windows to generate a self signed certificate it requires permissions to the Machine Keys Folder"
        Write-Host "The location of the MachineKeys Folder is C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
        Write-Host "The BUILTIN\Administrators Group should have Full Control permissions"
        Write-Host "The Everyone Group should have Read and Write permissions`n" 
    }

    foreach($Computer in $ComputerName)
    {
        try
        {
            $mpath = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
            $Permissions =  Invoke-Command -ComputerName $Computer -ErrorAction SilentlyContinue -ScriptBlock {
                    (Get-ACL -Path $using:mpath).Access
            } -Credential $Credential

            if(!$Permissions)
            {
                Write-Error "Cannot get ACL for $mpath on $Computer"
                Continue
            }

            $AdminRights = $Permissions | Where-Object {$_.IdentityReference -eq "BUILTIN\Administrators"} -ErrorAction SilentlyContinue
            $EveryOne = $Permissions | Where-Object {$_.IdentityReference -eq "everyone"} -ErrorAction SilentlyContinue

            if(!$AdminRights)
                {Write-Host "BUILTIN\Administrators: Not Configured"}

            if(!$EveryOne)
                {Write-Host "Everyone: Not Configured"}

            if($AdminRights)
            {
                $AdminRights | fl PSComputerName,FileSystemRights,IdentityReference,AccessControlType

                if($IncludeHelpTips)
                {
                    Write-Host "TROUBLESHOOTING TIPS"
                    Write-Host "====================`n"
                    
                    if($AdminRights.FileSystemRights -eq "FullControl" -and $AdminRights.AccessControlType -eq "Allow")
                    {
                        Write-Host "Access Rights for BUILTIN\Administrators has been configured correctly`n"
                    }
                    else
                    {
                        Write-Warning "Access Rights for BUILTIN\Administrators is not configured correctly"
                        Write-Warning "Access Rights for  BUILTIN\Administrators should be allow FullControl"
                        Write-Warning "This can cause problems generating the RDP self signed certificate`n"
                    }

                  
                }
            }

            if($EveryOne)
            {
                $EveryOne | fl PSComputerName,FileSystemRights,IdentityReference

                if($IncludeHelpTips)
                {
                    if($EveryOne.FileSystemRights -like "Write, Read*" -and $AdminRights.AccessControlType -eq "Allow")
                    {
                        Write-Host "Access Rights for the everyone group has been configured correctly`n"
                    }
                    else
                    {
                        Write-Warning "Access Rights for the everyone is not configured correctly"
                        Write-Warning "Access Rights for the everyone group should be allow Read and Write permissions"
                        Write-Warning "This can cause problems generating the RDP self signed certificate`n"
                    }
                }
            }


        }catch
        {
            Write-Error "Cannot get Admin and Everyone permissions on $mpath"
        }
    }

    if($IncludeHelpTips)
    {
        Write-Host "`nUseful Links"
        Write-Host "============`n"

        Write-Host "Troubleshooting Permissions of the MachineKeys folder"
        Write-Host "https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/troubleshoot/rdp-error-general-troubleshooting`n"
    }
}

<#
 .Synopsis
  This script displays detailed troubleshooting information and tips for troubleshooting Remote Desktop 
  Protocol (RDP).

 .Description
  This script displays detailed troubleshooting information tips for troubleshooting Remote Desktop 
  Protocol (RDP). This tool calls other RDP troubleshooting tips in the module. It is intended to run on 
  Windows Servers therefore it is not ideal for  Windows clients such as Windows 10 or Windows 11. This is 
  intended to be used as a troubleshooting tool for troubleshooting RDP on multiple Windows Servers.

 .Parameter ComputerName
  A list of Windows Server hostnames.
 
 .Parameter IncludeTshootInfo
  A Switch that if set will display troubleshooting tips based on the output and useful external help links

 .Example
   # Get detailed troubleshooting information for localhost only
   Get-RDPTShootInfo

 .Example
   # Get detailed troubleshooting information for remote computer specifying credentials to perform the 
   # operation.
   Get-RDPTShootInfo -ComputerName NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips

 .Example
   # Display detailed troubleshooting information for multiple computers with troubleshooting tips and 
   # useful links specifying credentials to perform the operation.
   Get-RDPTShootInfo -ComputerName localhost,NameRemoteComputer -Credentials YourCredentials -IncludeHelpTips
#>

function Get-RDPTShootInfo {
    
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

    Get-RDPEnabled -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
    Get-RDPListeners -ComputerName $ComputerName -IncludeHelpTips:$IncludeHelpTips
    Get-RDPFireWallRuleTshootInfo -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
    Get-RDPListenerTshootInfo  -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
    Get-RDPCertInfo -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
    Get-RDPCertFolderTshootInfo -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips
}

Export-ModuleMember -Function * -Alias *