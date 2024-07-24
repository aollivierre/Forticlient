# function Prepare-DeviceMigration {
#     [CmdletBinding()]
#     param ()

#     Begin {
#         Write-EnhancedLog -Message "Starting Prepare-DeviceMigration function" -Level "INFO"
#     }

#     Process {
#         try {
#             Start-Transcript -Path C:\ProgramData\AADMigration\Logs\AD2AADJ-Prep.txt -Append -Force

#             $MigrationConfig = Import-LocalizedData -BaseDirectory "." -FileName "MigrationConfig.psd1"
#             $MigrationPath = $MigrationConfig.MigrationPath
#             $TenantID = $MigrationConfig.TenantID
#             $OneDriveKFM = $MigrationConfig.UseOneDriveKFM
#             $InstallOneDrive = $MigrationConfig.InstallOneDrive
#             $StartBoundary = $MigrationConfig.StartBoundary

#             function Add-MigrationDirectory {
#                 # Expand AAD Migration zip file to ProgramData
#                 Expand-Archive -Path "$PSScriptRoot\AADMigration.zip" -DestinationPath C:\ProgramData -Force
#                 Copy-Item -Path "$PSScriptRoot\MigrationConfig.psd1" -Destination "$MigrationPath\Module"
#             }

#             function Set-RegistryValue {
#                 [CmdletBinding()]
#                 param (
#                     [string]$RegKeyPath,
#                     [string]$RegValName,
#                     [string]$RegValType,
#                     [string]$RegValData
#                 )

#                 # Test to see if the registry key exists, if it does not, create it
#                 $RegKeyPathExists = Test-Path -Path $RegKeyPath
#                 if (-not $RegKeyPathExists) {
#                     New-Item -Path $RegKeyPath -Force | Out-Null
#                 }

#                 # Check to see if the value exists
#                 try {
#                     $CurrentValue = Get-ItemPropertyValue -Path $RegKeyPath -Name $RegValName
#                 } catch {
#                     # If the value does not exist, catch the error and create the key
#                     Set-ItemProperty -Path $RegKeyPath -Name $RegValName -Type $RegValType -Value $RegValData -Force
#                 }

#                 if ($CurrentValue -ne $RegValData) {
#                     # If the value exists but the data is wrong, update the value
#                     Set-ItemProperty -Path $RegKeyPath -Name $RegValName -Type $RegValType -Value $RegValData -Force
#                 }
#             }

#             function Set-ODKFMSettings {
#                 # Set registry values for enabling KFM to set tenant
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "AllowTenantList" -RegValType "STRING" -RegValData $TenantID
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "SilentAccountConfig" -RegValType "DWORD" -RegValData "1"
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "KFMOptInWithWizard" -RegValType "STRING" -RegValData $TenantID
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "KFMSilentOptIn" -RegValType "STRING" -RegValData $TenantID
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "KFMSilentOptInDesktop" -RegValType "DWORD" -RegValData "1"
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "KFMSilentOptInDocuments" -RegValType "DWORD" -RegValData "1"
#                 Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -RegValName "KFMSilentOptInPictures" -RegValType "DWORD" -RegValData "1"

#                 # Create EventLog Source
#                 New-EventLog -LogName 'Application' -Source 'AAD_Migration_Script' -ErrorAction Stop

#                 # Create scheduled task to check OneDrive sync status
#                 $TaskPath = "AAD Migration"
#                 $TaskName = "AADM Get OneDrive Sync Status"
#                 $ScriptPath = "C:\ProgramData\AADMigration\Scripts"
#                 $ScriptName = "Check-OneDriveSyncStatus.ps1"
#                 $arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file $ScriptPath\$ScriptName"

#                 $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $arguments
#                 $trigger = New-ScheduledTaskTrigger -AtLogOn
#                 $trigger.Delay = 'PT1M'
#                 $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
#                 $Task = Register-ScheduledTask -Principal $principal -Action $action -Trigger $trigger -TaskName $TaskName -Description "Get current OneDrive Sync Status and write to event log" -TaskPath $TaskPath
#                 $Task.Triggers.Repetition.Duration = "P1D"
#                 $Task.Triggers.Repetition.Interval = "PT30M"
#                 $Task | Set-ScheduledTask
#             }

#             function Install-OneDrive {
#                 # Check for OneDrive machine-wide installer, check version number if it exists
#                 $ODSetupVersion = (Get-ChildItem -Path "$PSScriptRoot\AADMigration\Files\OneDriveSetup.exe").VersionInfo.FileVersion

#                 if (-not $ODSetupVersion) {
#                     Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=844652" -OutFile "$PSScriptRoot\Files\OneDriveSetup.exe" -Wait
#                     $ODSetupVersion = (Get-ChildItem -Path "$PSScriptRoot\Files\OneDriveSetup.exe").VersionInfo.FileVersion
#                 }

#                 $ODRegKey = "HKLM:\SOFTWARE\Microsoft\OneDrive"
#                 $InstalledVer = Get-ItemPropertyValue -Path $ODRegKey -Name Version

#                 if (-not $ODRegKey -or ([System.Version]$InstalledVer -lt [System.Version]$ODSetupVersion)) {
#                     # Install OneDrive setup
#                     $Installer = "$PSScriptRoot\Files\OneDriveSetup.exe"
#                     $Arguments = "/allusers"
#                     Start-Process -FilePath $Installer -ArgumentList $Arguments
#                 } elseif ($OneDriveKFM) {
#                     # If OneDrive is already installed, stop the process and restart to kick off KFM sync if required
#                     Get-Process -Name OneDrive | Stop-Process -Confirm:$false -Force
#                     Start-Sleep -Seconds 5

#                     $action = New-ScheduledTaskAction -Execute "C:\Program Files\Microsoft Onedrive\OneDrive.exe"
#                     $trigger = New-ScheduledTaskTrigger -AtLogOn
#                     $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
#                     $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
#                     Register-ScheduledTask -TaskName OneDriveRemediation -InputObject $task
#                     Start-ScheduledTask -TaskName OneDriveRemediation
#                     Start-Sleep -Seconds 5
#                     Unregister-ScheduledTask -TaskName OneDriveRemediation -Confirm:$false
#                 }
#             }

#             function New-MigrationTask {
#                 # Create Scheduled task to launch interactive migration task
#                 $TaskPath = "AAD Migration"
#                 $TaskName = "AADM Launch PSADT for Interactive Migration"
#                 $ScriptPath = "C:\ProgramData\AADMigration\Scripts"
#                 $ScriptName = "Launch-DeployApplication_SchTask.ps1"
#                 $arguments = "-executionpolicy Bypass -file $ScriptPath\$ScriptName"

#                 $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $arguments
#                 $trigger = New-ScheduledTaskTrigger -AtLogOn
#                 $trigger.Delay = 'PT1M'
#                 $trigger.StartBoundary = $StartBoundary
#                 $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
#                 $Task = Register-ScheduledTask -Principal $principal -Action $action -Trigger $trigger -TaskName $TaskName -Description "AADM Launch PSADT for Interactive Migration" -TaskPath $TaskPath
#             }

#             Add-MigrationDirectory
#             New-MigrationTask

#             if ($OneDriveKFM) {
#                 Set-ODKFMSettings
#             }

#             if ($InstallOneDrive) {
#                 Install-OneDrive
#             }

#             Stop-Transcript
#         } catch {
#             Write-EnhancedLog -Message "An error occurred in Prepare-DeviceMigration: $($_.Exception.Message)" -Level "ERROR"
#             Handle-Error -ErrorRecord $_
#         }
#     }

#     End {
#         Write-EnhancedLog -Message "Exiting Prepare-DeviceMigration function" -Level "INFO"
#     }
# }

# # Example usage
# # Prepare-DeviceMigration
