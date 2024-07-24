function PostRunOnce2 {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting PostRunOnce2 function" -Level "INFO"
    }

    Process {
        try {
            # Start-Transcript -Path C:\ProgramData\AADMigration\Logs\AD2AADJ-R2.txt -Append -Verbose

            # Block user input
            $code = @"
                [DllImport("user32.dll")]
                public static extern bool BlockInput(bool fBlockIt);
"@
            $userInput = Add-Type -MemberDefinition $code -Name Blocker -Namespace UserInput -PassThru
            $null = $userInput::BlockInput($true)

            # Display form with user input block message
            [void][reflection.assembly]::LoadWithPartialName("System.Drawing")
            [void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
            $file = Get-Item "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
            $img = [System.Drawing.Image]::FromFile((Get-Item $file))

            [System.Windows.Forms.Application]::EnableVisualStyles()
            $form = New-Object Windows.Forms.Form
            $form.Text = "Migration in Progress"
            $form.WindowState = 'Maximized'
            $form.BackColor = "#000000"
            $form.TopMost = $true

            $pictureBox = New-Object Windows.Forms.PictureBox
            $pictureBox.Width = $img.Size.Width
            $pictureBox.Height = $img.Size.Height
            $pictureBox.Dock = "Fill"
            $pictureBox.SizeMode = "StretchImage"
            $pictureBox.Image = $img
            $form.Controls.Add($pictureBox)
            $form.Add_Shown({ $form.Activate() })
            $form.Show()

            # Function to set registry values
            function Set-RegistryValue {
                [CmdletBinding()]
                param (
                    [string]$RegKeyPath,
                    [string]$RegValName,
                    [string]$RegValType,
                    [string]$RegValData
                )

                # Test to see if Edge key exists, if it does not exist create it
                $RegKeyPathExists = Test-Path -Path $RegKeyPath
                if (-not $RegKeyPathExists) {
                    New-Item -Path $RegKeyPath -Force | Out-Null
                }

                # Check to see if value exists
                try {
                    $CurrentValue = Get-ItemPropertyValue -Path $RegKeyPath -Name $RegValName
                }
                catch {
                    # If value does not exist an error would be thrown, catch error and create key
                    Set-ItemProperty -Path $RegKeyPath -Name $RegValName -Type $RegValType -Value $RegValData -Force
                }

                if ($CurrentValue -ne $RegValData) {
                    # If value exists but data is wrong, update the value
                    Set-ItemProperty -Path $RegKeyPath -Name $RegValName -Type $RegValType -Value $RegValData -Force
                }
            }

            Write-EnhancedLog -Message "Creating scheduled task to run PostRunOnce3" -Level "INFO"
            $TaskPath = "AAD Migration"
            $TaskName = "Run Post-migration cleanup"
            $ScriptPath = "C:\ProgramData\AADMigration\Scripts"
            $ScriptName = "PostRunOnce3.ps1"
            $arguments = "-executionpolicy Bypass -file $ScriptPath\$ScriptName"

            $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $arguments
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
            $Task = Register-ScheduledTask -Principal $principal -Action $action -Trigger $trigger -TaskName $TaskName -Description "Run post AAD Migration cleanup" -TaskPath $TaskPath

            Write-EnhancedLog -Message "Escrowing current Numeric Key" -Level "INFO"
            function Test-Bitlocker ($BitlockerDrive) {
                # Tests the drive for existing Bitlocker key protectors
                try {
                    Get-BitLockerVolume -MountPoint $BitlockerDrive -ErrorAction Stop
                }
                catch {
                    Write-Output "Bitlocker was not found protecting the $BitlockerDrive drive. Terminating script!"
                }
            }
            function Get-KeyProtectorId ($BitlockerDrive) {
                # Fetches the key protector ID of the drive
                $BitLockerVolume = Get-BitLockerVolume -MountPoint $BitlockerDrive
                $KeyProtector = $BitLockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
                return $KeyProtector.KeyProtectorId
            }
            function Invoke-BitlockerEscrow ($BitlockerDrive, $BitlockerKey) {
                # Escrow the key into Azure AD
                try {
                    BackupToAAD-BitLockerKeyProtector -MountPoint $BitlockerDrive -KeyProtectorId $BitlockerKey -ErrorAction SilentlyContinue
                    Write-Output "Attempted to escrow key in Azure AD - Please verify manually!"
                }
                catch {
                    Write-Error "Debug"
                }
            }

            $BitlockerVolumes = Get-BitLockerVolume
            $BitlockerVolumes | ForEach-Object {
                $MountPoint = $_.MountPoint
                $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
                if ($RecoveryKey.Length -gt 5) {
                    $DriveLetter = $MountPoint
                    Write-Output $DriveLetter
                    Test-Bitlocker -BitlockerDrive $DriveLetter
                    $KeyProtectorId = Get-KeyProtectorId -BitlockerDrive $DriveLetter
                    Invoke-BitlockerEscrow -BitlockerDrive $DriveLetter -BitlockerKey $KeyProtectorId
                }
            }

            Write-EnhancedLog -Message "Setting registry key to disable AutoAdminLogon" -Level "INFO"
            Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -RegValName "AutoAdminLogon" -RegValType "DWORD" -RegValData "0"

            Write-EnhancedLog -Message "Setting key to not show last logged in user" -Level "INFO"
            Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -RegValName "dontdisplaylastusername" -RegValType "DWORD" -RegValData "1"

            Write-EnhancedLog -Message "Setting legal notice caption" -Level "INFO"
            Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -RegValName "legalnoticecaption" -RegValType "String" -RegValData "Migration Completed"

            Write-EnhancedLog -Message "Setting legal notice text" -Level "INFO"
            Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -RegValName "legalnoticetext" -RegValType "String" -RegValData "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."

            Stop-Transcript

            $null = $userInput::BlockInput($false)
            $form.Close()

            Restart-Computer
        }
        catch {
            Write-EnhancedLog -Message "An error occurred in PostRunOnce2: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting PostRunOnce2 function" -Level "INFO"
    }
}

# Example usage
# PostRunOnce2
