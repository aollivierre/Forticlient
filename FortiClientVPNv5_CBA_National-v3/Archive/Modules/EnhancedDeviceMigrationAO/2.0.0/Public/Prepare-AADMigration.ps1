function Prepare-AADMigration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MigrationPath,

        [Parameter(Mandatory = $true)]
        [string]$PSScriptbase,

        [Parameter(Mandatory = $true)]
        [string]$ConfigBaseDirectory,

        [Parameter(Mandatory = $true)]
        [string]$ConfigFileName,

        [Parameter(Mandatory = $true)]
        [string]$TenantID,

        [Parameter(Mandatory = $true)]
        [bool]$OneDriveKFM,

        [Parameter(Mandatory = $true)]
        [bool]$InstallOneDrive
    )

    Begin {
        Write-EnhancedLog -Message "Starting Prepare-AADMigration function" -Level "INFO"
        Log-Params -Params @{
            MigrationPath       = $MigrationPath
            PSScriptbase        = $PSScriptbase
            ConfigBaseDirectory = $ConfigBaseDirectory
            ConfigFileName      = $ConfigFileName
            TenantID            = $TenantID
            OneDriveKFM         = $OneDriveKFM
            InstallOneDrive     = $InstallOneDrive
        }
    }

    Process {
        try {
            # Ensure the target directory exists
            if (-not (Test-Path -Path $MigrationPath)) {
                New-Item -Path $MigrationPath -ItemType Directory -Force | Out-Null
            }

            # Copy the entire content of $PSScriptRoot to $MigrationPath
      
            # Define the source and destination paths
            $sourcePath1 = $PSScriptbase
            $sourcePath2 = "C:\code\modules"
            $destinationPath1 = $MigrationPath
            $destinationPath2 = "$MigrationPath\modules"

            # Copy files from $PSScriptRoot using the Copy-FilesToPath function
            # Copy-FilesToPath -SourcePath $sourcePath1 -DestinationPath $destinationPath1

            Stop-ProcessesUsingOneDriveLib -OneDriveLibPath "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"

            # $DBG

            Remove-ScheduledTaskFilesWithLogging -Path $destinationPath1

            Copy-FilesToPathWithKill -SourcePath $sourcePath1 -DestinationPath $destinationPath1

            # Verify the copy operation for $PSScriptRoot
            Verify-CopyOperation -SourcePath $sourcePath1 -DestinationPath $destinationPath1

            # Copy files from C:\code\modules using the Copy-FilesToPath function
            # Copy-FilesToPath -SourcePath $sourcePath2 -DestinationPath $destinationPath2

            Copy-FilesToPathWithKill -SourcePath $sourcePath2 -DestinationPath $destinationPath2

            # Verify the copy operation for C:\code\modules
            Verify-CopyOperation -SourcePath $sourcePath2 -DestinationPath $destinationPath2


            # $DBG

            Write-EnhancedLog -Message "Copied content from $PSScriptRoot to $MigrationPath" -Level "INFO"

            # $DBG

            # Import migration configuration
            $MigrationConfig = Import-LocalizedData -BaseDirectory $ConfigBaseDirectory -FileName $ConfigFileName
            $TenantID = $MigrationConfig.TenantID
            $OneDriveKFM = $MigrationConfig.UseOneDriveKFM
            $InstallOneDrive = $MigrationConfig.InstallOneDrive

            # $DBG

            # Set OneDrive KFM settings if required
            if ($OneDriveKFM) {

                # $TenantID = "YourTenantID"
                $RegistrySettings = @(
                    @{
                        RegValueName = "AllowTenantList"
                        RegValType   = "STRING"
                        RegValData   = $TenantID
                    },
                    @{
                        RegValueName = "SilentAccountConfig"
                        RegValType   = "DWORD"
                        RegValData   = "1"
                    },
                    @{
                        RegValueName = "KFMOptInWithWizard"
                        RegValType   = "STRING"
                        RegValData   = $TenantID
                    },
                    @{
                        RegValueName = "KFMSilentOptIn"
                        RegValType   = "STRING"
                        RegValData   = $TenantID
                    },
                    @{
                        RegValueName = "KFMSilentOptInDesktop"
                        RegValType   = "DWORD"
                        RegValData   = "1"
                    },
                    @{
                        RegValueName = "KFMSilentOptInDocuments"
                        RegValType   = "DWORD"
                        RegValData   = "1"
                    },
                    @{
                        RegValueName = "KFMSilentOptInPictures"
                        RegValType   = "DWORD"
                        RegValData   = "1"
                    }
                )

                $SetODKFMRegistrySettingsParams = @{
                    TenantID         = $TenantID
                    RegKeyPath       = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
                    RegistrySettings = $RegistrySettings
                }


                # $DBG

                Set-ODKFMRegistrySettings @SetODKFMRegistrySettingsParams


                # $DBG

                Unregister-ScheduledTaskWithLogging -TaskName "AADM Get OneDrive Sync Status"

                # Example usage with splatting
                $CreateOneDriveSyncStatusTaskParams = @{
                    TaskPath               = "AAD Migration"
                    TaskName               = "AADM Get OneDrive Sync Status"
                    ScriptDirectory        = "C:\ProgramData\AADMigration\Scripts"
                    ScriptName             = "Check-OneDriveSyncStatus.ps1"
                    TaskArguments          = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
                    TaskRepetitionDuration = "P1D"
                    TaskRepetitionInterval = "PT30M"
                    TaskPrincipalGroupId   = "BUILTIN\Users"
                    PowerShellPath         = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                    TaskDescription        = "Get current OneDrive Sync Status and write to event log"
                }

                Create-OneDriveSyncStatusTask @CreateOneDriveSyncStatusTaskParams



                # $DBG

            }

            # Install OneDrive if required
            if ($InstallOneDrive) {
                

                # Example usage
                $InstallOneDriveParams = @{
                    MigrationPath             = "C:\ProgramData\AADMigration"
                    OneDriveKFM               = $true
                    ODSetupUri                = "https://go.microsoft.com/fwlink/?linkid=844652"
                    ODSetupFile               = "Files\OneDriveSetup.exe"
                    ODRegKey                  = "HKLM:\SOFTWARE\Microsoft\OneDrive"
                    OneDriveExePath           = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
                    ScheduledTaskName         = "OneDriveRemediation"
                    ScheduledTaskDescription  = "Restart OneDrive to kick off KFM sync"
                    # ScheduledTaskArgumentList = ""
                    SetupArgumentList         = "/allusers"
                }

                Install-OneDrive @InstallOneDriveParams

                $DBG

            }

        }
        catch {
            Write-EnhancedLog -Message "An error occurred in Prepare-AADMigration: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Prepare-AADMigration function" -Level "INFO"
    }
}

# # Define parameters
# $PrepareAADMigrationParams = @{
#     MigrationPath       = "C:\ProgramData\AADMigration"
#     PSScriptRoot        = "C:\SourcePath"
#     ConfigBaseDirectory = "C:\ConfigDirectory\Scripts"
#     ConfigFileName      = "MigrationConfig.psd1"
#     TenantID            = "YourTenantID"
#     OneDriveKFM         = $true
#     InstallOneDrive     = $true
# }

# # Example usage with splatting
# Prepare-AADMigration @PrepareAADMigrationParams
