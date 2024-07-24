function PostRunOnce3 {
  [CmdletBinding()]
  param ()

  Begin {
    Write-EnhancedLog -Message "Starting PostRunOnce3 function" -Level "INFO"
  }

  Process {
    try {
      # Start-Transcript -Path C:\ProgramData\AADMigration\Logs\AD2AADJ-R3.txt -Append -Force
      $MigrationConfig = Import-LocalizedData -BaseDirectory "C:\ProgramData\AADMigration\scripts" -FileName "MigrationConfig.psd1"
      $TempUser = $MigrationConfig.TempUser

      # Function to set registry values
      function Set-RegistryValue {
        [CmdletBinding()]
        param (
          [string]$RegKeyPath,
          [string]$RegValName,
          [string]$RegValType,
          [string]$RegValData
        )

        # Test to see if the registry key exists, if not, create it
        $RegKeyPathExists = Test-Path -Path $RegKeyPath
        if (-not $RegKeyPathExists) {
          New-Item -Path $RegKeyPath -Force | Out-Null
        }

        # Check to see if the value exists
        try {
          $CurrentValue = Get-ItemPropertyValue -Path $RegKeyPath -Name $RegValName
        }
        catch {
          # If the value does not exist, catch the error and create the key
          Set-ItemProperty -Path $RegKeyPath -Name $RegValName -Type $RegValType -Value $RegValData -Force
        }

        if ($CurrentValue -ne $RegValData) {
          # If the value exists but the data is wrong, update the value
          Set-ItemProperty -Path $RegKeyPath -Name $RegValName -Type $RegValType -Value $RegValData -Force
        }
      }

      # Clean up after ourselves
      # Remove local user account created for migration
      Remove-LocalUser -Name $TempUser

      # Remove autologon settings and default user and password from registry
      $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
      Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "0" -Type String
      Set-ItemProperty -Path $RegPath -Name "DefaultUsername" -Value $null -Type String
      Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value $null -Type String

      # Remove setting to not show local user
      Write-EnhancedLog -Message "Setting key to show last logged in user" -Level "INFO"
      Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -RegValName "dontdisplaylastusername" -RegValType "DWORD" -RegValData "0"

      # Clear legal notice caption
      Write-EnhancedLog -Message "Setting legal notice caption" -Level "INFO"
      Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -RegValName "legalnoticecaption" -RegValType "String" -RegValData $null

      # Clear legal notice text
      Write-EnhancedLog -Message "Setting legal notice text" -Level "INFO"
      Set-RegistryValue -RegKeyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -RegValName "legalnoticetext" -RegValType "String" -RegValData $null

      # Re-enable lock screen
      Write-EnhancedLog -Message "Re-enabling lock screen" -Level "INFO"
      Set-RegistryValue -RegKeyPath "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -RegValName "NoLockScreen" -RegValType "DWORD" -RegValData "0"

      # Enumerate local user accounts and disable them
      $Users = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Name -notlike 'default*' }
      foreach ($User in $Users) {
        Write-EnhancedLog -Message "Disabling local user account $User" -Level "INFO"
        Disable-LocalUser -Name $User.Name
      }

      # Delete scheduled tasks created for migration
      $taskPath = "AAD Migration"
      $tasks = Get-ScheduledTask -TaskPath "\$taskPath\"
      foreach ($Task in $tasks) {
        Unregister-ScheduledTask -TaskName $Task.TaskName -Confirm:$false
      }
      $scheduler = New-Object -ComObject "Schedule.Service"
      $scheduler.Connect()
      $rootFolder = $scheduler.GetFolder("\")
      $rootFolder.DeleteFolder($taskPath, $null)

      # Delete migration files, leave log folder
      # Remove PPKG files, which include nested credentials
      $FileName = "C:\ProgramData\AADMigration\Files"
      if (Test-Path -Path $FileName) {
        Remove-Item -Path $FileName -Recurse -Force
      }

      $FileName = "C:\ProgramData\AADMigration\Scripts"
      if (Test-Path -Path $FileName) {
        Remove-Item -Path $FileName -Recurse -Force
      }

      $FileName = "C:\ProgramData\AADMigration\Toolkit"
      if (Test-Path -Path $FileName) {
        Remove-Item -Path $FileName -Recurse -Force
      }

      # Launch OneDrive
      # Start-Process -FilePath "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe"

      Stop-Transcript
    }
    catch {
      Write-EnhancedLog -Message "An error occurred in PostRunOnce3: $($_.Exception.Message)" -Level "ERROR"
      Handle-Error -ErrorRecord $_
    }
  }

  End {
    Write-EnhancedLog -Message "Exiting PostRunOnce3 function" -Level "INFO"
  }
}

# Example usage
# PostRunOnce3
