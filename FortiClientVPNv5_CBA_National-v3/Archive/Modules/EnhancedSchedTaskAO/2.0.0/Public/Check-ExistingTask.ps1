function Check-ExistingTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$taskName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Check-ExistingTask function" -Level "INFO"
        Log-Params -Params @{ taskName = $taskName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking for existing scheduled task: $taskName" -Level "INFO" -ForegroundColor Magenta
            $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -eq $taskName }

            if ($tasks.Count -eq 0) {
                Write-EnhancedLog -Message "No existing task named $taskName found." -Level "INFO" -ForegroundColor Yellow
                return $false
            }

            Write-EnhancedLog -Message "Task named $taskName found." -Level "INFO" -ForegroundColor Green
            return $true
        } catch {
            Write-EnhancedLog -Message "An error occurred while checking for the scheduled task: $($_.Exception.Message)" -Level "ERROR" -ForegroundColor Red
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Check-ExistingTask function" -Level "INFO"
    }
}

# # Example usage:
# $taskExists = Check-ExistingTask -taskName "AADM Launch PSADT for Interactive Migration"
# Write-Output "Task exists: $taskExists"
