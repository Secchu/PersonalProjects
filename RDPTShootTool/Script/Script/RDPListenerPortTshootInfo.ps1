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

Get-RDPListenerTshootInfo -ComputerName $ComputerName -IncludeHelpTips:$IncludeHelpTips