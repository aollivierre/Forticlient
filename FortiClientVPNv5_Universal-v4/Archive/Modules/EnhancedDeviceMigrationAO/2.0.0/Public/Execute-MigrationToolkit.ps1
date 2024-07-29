function Execute-MigrationToolkit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceUI,

        [Parameter(Mandatory = $true)]
        [string]$ExePath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Execute-MigrationToolkit function" -Level "INFO"
        Log-Params -Params @{
            ServiceUI = $ServiceUI
            ExePath   = $ExePath
        }
    }

    Process {
        try {
            $targetProcesses = @(Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)
            if ($targetProcesses.Count -eq 0) {
                Write-EnhancedLog -Message "No user logged in, running without ServiceUI" -Level "INFO"
                Start-Process -FilePath $ExePath -ArgumentList '-DeployMode "NonInteractive"' -Wait -NoNewWindow
            } else {
                foreach ($targetProcess in $targetProcesses) {
                    $Username = $targetProcess.GetOwner().User
                    Write-EnhancedLog -Message "$Username logged in, running with ServiceUI" -Level "INFO"
                }
                Start-Process -FilePath $ServiceUI -ArgumentList "-Process:explorer.exe $ExePath" -NoNewWindow
            }
        } catch {
            $ErrorMessage = $_.Exception.Message
            Write-EnhancedLog -Message "An error occurred: $ErrorMessage" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Install Exit Code = $LASTEXITCODE" -Level "INFO"
        Write-EnhancedLog -Message "Exiting Execute-MigrationToolkit function" -Level "INFO"
        Exit $LASTEXITCODE
    }
}

# # Define paths
# $ToolkitPaths = @{
#     ServiceUI = "C:\ProgramData\AADMigration\Files\ServiceUI.exe"
#     ExePath   = "C:\ProgramData\AADMigration\Toolkit\Deploy-Application.exe"
# }

# # Example usage with splatting
# Execute-MigrationToolkit @ToolkitPaths
