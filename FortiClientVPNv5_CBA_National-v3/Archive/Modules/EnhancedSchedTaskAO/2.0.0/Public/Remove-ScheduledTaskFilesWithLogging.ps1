function Remove-ScheduledTaskFilesWithLogging {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Begin {
        Write-EnhancedLog -Message "Starting Remove-ScheduledTaskFilesWithLogging function" -Level "INFO"
        Log-Params -Params @{
            Path = $Path
        }
    }

    Process {
        try {
            # Validate before removal
            $existsBefore = Validate-PathExistsWithLogging -Path $Path

            if ($existsBefore) {
                Write-EnhancedLog -Message "Calling Remove-Item for path: $Path" -Level "INFO"
                Remove-Item -Path $Path -Recurse -Force
                Write-EnhancedLog -Message "Remove-Item done for path: $Path" -Level "INFO"
            } else {
                Write-EnhancedLog -Message "Path $Path does not exist. No action taken." -Level "WARNING"
            }

            # Validate after removal
            $existsAfter = Validate-PathExistsWithLogging -Path $Path

            # $DBG

            if ($existsAfter) {
                Write-EnhancedLog -Message "Path $Path still exists after attempting to remove. Manual intervention may be required." -Level "ERROR"
            } else {
                Write-EnhancedLog -Message "Path $Path successfully removed." -Level "INFO"
            }
        } catch {
            Write-EnhancedLog -Message "Error during Remove-Item for path: $Path. Error: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-ScheduledTaskFilesWithLogging function" -Level "INFO"
    }
}


# Remove-ScheduledTaskFilesWithLogging -Path "C:\Path\To\ScheduledTaskFiles"
