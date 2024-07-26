function PostRunOnce {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting PostRunOnce function" -Level "INFO"
    }

    Process {
        try {
            Start-Transcript -Path C:\ProgramData\AADMigration\Logs\AD2AADJ-R1.txt -NoClobber
            $MigrationConfig = Import-LocalizedData -BaseDirectory "C:\ProgramData\AADMigration\scripts" -FileName "MigrationConfig.psd1"
            $PPKGName = $MigrationConfig.ProvisioningPack
            $MigrationPath = $MigrationConfig.MigrationPath

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

            Write-EnhancedLog -Message "Writing Run Once for Post Reboot 2" -Level "INFO"
            $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
            Set-ItemProperty -Path $RunOnceKey -Name "NextRun" -Value ("C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -executionPolicy Unrestricted -File C:\ProgramData\AADMigration\Scripts\PostRunOnce2.ps1")

            # Install Provisioning PPKG
            Write-EnhancedLog -Message "Installing Provisioning PPKG" -Level "INFO"
            Install-ProvisioningPackage -PackagePath "$MigrationPath\Files\$PPKGName" -ForceInstall -QuietInstall

            Stop-Transcript

            $null = $userInput::BlockInput($false)
            $form.Close()

            Restart-Computer
        }
        catch {
            Write-EnhancedLog -Message "An error occurred during the migration process: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting PostRunOnce function" -Level "INFO"
    }
}

# Example usage
# PostRunOnce
