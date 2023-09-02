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

Get-RDPCertFolderTshootInfo -ComputerName $ComputerName -Credential $Credential -IncludeHelpTips:$IncludeHelpTips