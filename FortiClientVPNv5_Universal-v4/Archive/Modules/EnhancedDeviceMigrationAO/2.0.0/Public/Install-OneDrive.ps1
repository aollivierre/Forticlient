function Install-OneDrive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MigrationPath,

        [Parameter(Mandatory = $false)]
        [bool]$OneDriveKFM = $false,

        [Parameter(Mandatory = $true)]
        [string]$ODSetupUri,

        [Parameter(Mandatory = $true)]
        [string]$ODSetupFile,

        [Parameter(Mandatory = $true)]
        [string]$ODRegKey,

        [Parameter(Mandatory = $true)]
        [string]$OneDriveExePath,

        [Parameter(Mandatory = $true)]
        [string]$ScheduledTaskName,

        [Parameter(Mandatory = $true)]
        [string]$ScheduledTaskDescription,

        [Parameter(Mandatory = $false)]
        [string]$ScheduledTaskArgumentList,

        [Parameter(Mandatory = $true)]
        [string]$SetupArgumentList
    )

    Begin {
        Write-EnhancedLog -Message "Starting Install-OneDrive function" -Level "INFO"
        Log-Params -Params @{
            MigrationPath               = $MigrationPath
            OneDriveKFM                 = $OneDriveKFM
            ODSetupUri                  = $ODSetupUri
            ODSetupFile                 = $ODSetupFile
            ODRegKey                    = $ODRegKey
            OneDriveExePath             = $OneDriveExePath
            ScheduledTaskName           = $ScheduledTaskName
            ScheduledTaskDescription    = $ScheduledTaskDescription
            # ScheduledTaskArgumentList   = $ScheduledTaskArgumentList
            SetupArgumentList           = $SetupArgumentList
        }

        $ODSetupPath = Join-Path -Path $MigrationPath -ChildPath $ODSetupFile
        $ODSetupVersion = $null
    }

    Process {
        try {
            if (Test-Path -Path $ODSetupPath) {
                $ODSetupVersion = (Get-ChildItem -Path $ODSetupPath).VersionInfo.FileVersion
            }

            if (-not $ODSetupVersion) {
                Invoke-WebRequest -Uri $ODSetupUri -OutFile $ODSetupPath
                $ODSetupVersion = (Get-ChildItem -Path $ODSetupPath).VersionInfo.FileVersion
            }

            $InstalledVer = if (Test-Path -Path $ODRegKey) {
                Get-ItemPropertyValue -Path $ODRegKey -Name Version
            } else {
                [System.Version]::new("0.0.0.0")
            }

            if (-not $InstalledVer -or ([System.Version]$InstalledVer -lt [System.Version]$ODSetupVersion)) {
                Write-EnhancedLog -Message "Installing OneDrive setup" -Level "INFO"
                Start-Process -FilePath $ODSetupPath -ArgumentList $SetupArgumentList -Wait -NoNewWindow
            } elseif ($OneDriveKFM) {
                Write-EnhancedLog -Message "OneDrive already installed, performing KFM sync if required" -Level "INFO"
                $ODProcess = Get-Process -Name OneDrive -ErrorAction SilentlyContinue

                if ($ODProcess) {
                    $ODProcess | Stop-Process -Confirm:$false -Force
                    Start-Sleep -Seconds 5

                    Unregister-ScheduledTaskWithLogging -TaskName $ScheduledTaskName

                    $CreateOneDriveRemediationTaskParams = @{
                        OneDriveExePath           = $OneDriveExePath
                        ScheduledTaskName         = $ScheduledTaskName
                        ScheduledTaskDescription  = $ScheduledTaskDescription
                        # ScheduledTaskArgumentList = $ScheduledTaskArgumentList
                    }
                    
                    Create-OneDriveRemediationTask @CreateOneDriveRemediationTaskParams
                }
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred in Install-OneDrive function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Install-OneDrive function" -Level "INFO"
    }
}


# $InstallOneDriveParams = @{
#     MigrationPath              = "C:\ProgramData\AADMigration"
#     OneDriveKFM                = $true
#     ODSetupUri                 = "https://go.microsoft.com/fwlink/?linkid=844652"
#     ODSetupFile                = "Files\OneDriveSetup.exe"
#     ODRegKey                   = "HKLM:\SOFTWARE\Microsoft\OneDrive"
#     OneDriveExePath            = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
#     ScheduledTaskName          = "OneDriveRemediation"
#     ScheduledTaskDescription   = "Restart OneDrive to kick off KFM sync"
#     ScheduledTaskArgumentList  = ""
#     SetupArgumentList          = "/allusers"
# }

# Install-OneDrive @InstallOneDriveParams
