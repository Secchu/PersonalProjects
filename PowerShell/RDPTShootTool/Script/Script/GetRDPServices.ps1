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
	param (
        [Parameter()]
        [Alias("CN","MachineName","Com")]
        [string[]]$ComputerName  = @("localhost"),
        [Alias("GetHelp","GH","Help","HelpTips","IncludeTshootInfo")]
        [switch]$IncludeHelpTips
	)

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

Get-RDPListeners -ComputerName $ComputerName -IncludeHelpTips:$IncludeHelpTips