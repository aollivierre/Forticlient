function Stop-ProcessesUsingOneDriveLib {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OneDriveLibPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Stop-ProcessesUsingOneDriveLib function" -Level "INFO"
        Log-Params -Params @{ OneDriveLibPath = $OneDriveLibPath }
    }

    Process {
        try {
            # Validate before removal
            $initialProcesses = Validate-OneDriveLibUsage -OneDriveLibPath $OneDriveLibPath
            if ($initialProcesses.Count -eq 0) {
                Write-EnhancedLog -Message "No processes found using OneDriveLib.dll before attempting termination." -Level "INFO"
            }

            # Terminate processes
            foreach ($process in $initialProcesses) {
                Write-EnhancedLog -Message "Found process using OneDriveLib.dll: $($process.ProcessName) (ID: $($process.ProcessId)). Attempting to terminate." -Level "WARNING"
                Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
            }

            # Validate after removal
            $remainingProcesses = Validate-OneDriveLibUsage -OneDriveLibPath $OneDriveLibPath
            if ($remainingProcesses.Count -eq 0) {
                Write-EnhancedLog -Message "Successfully terminated all processes using OneDriveLib.dll." -Level "INFO"
            }
            else {
                Write-EnhancedLog -Message "Some processes could not be terminated. Manual intervention may be required." -Level "ERROR"
                foreach ($process in $remainingProcesses) {
                    Write-EnhancedLog -Message "Process still running: $($process.ProcessName) (ID: $($process.ProcessId))." -Level "ERROR"
                }
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred in Stop-ProcessesUsingOneDriveLib function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Stop-ProcessesUsingOneDriveLib function" -Level "INFO"
    }
}

# Example usage
# Stop-ProcessesUsingOneDriveLib -OneDriveLibPath "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
