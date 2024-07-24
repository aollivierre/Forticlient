function Unregister-ScheduledTaskWithLogging {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Unregister-ScheduledTaskWithLogging function" -Level "INFO"
        Log-Params -Params @{ TaskName = $TaskName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking if task '$TaskName' exists before attempting to unregister." -Level "INFO"
            $taskExistsBefore = Check-ExistingTask -taskName $TaskName
            
            if ($taskExistsBefore) {
                Write-EnhancedLog -Message "Task '$TaskName' found. Proceeding to unregister." -Level "INFO"
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
                Write-EnhancedLog -Message "Unregister-ScheduledTask done for task: $TaskName" -Level "INFO"
            } else {
                Write-EnhancedLog -Message "Task '$TaskName' not found. No action taken." -Level "INFO"
            }

            Write-EnhancedLog -Message "Checking if task '$TaskName' exists after attempting to unregister." -Level "INFO"
            $taskExistsAfter = Check-ExistingTask -taskName $TaskName
            
            if ($taskExistsAfter) {
                Write-EnhancedLog -Message "Task '$TaskName' still exists after attempting to unregister. Manual intervention may be required." -Level "ERROR"
            } else {
                Write-EnhancedLog -Message "Task '$TaskName' successfully unregistered." -Level "INFO"
            }
        } catch {
            Write-EnhancedLog -Message "Error during Unregister-ScheduledTask for task: $TaskName. Error: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Unregister-ScheduledTaskWithLogging function" -Level "INFO"
    }
}


# Unregister-ScheduledTaskWithLogging -TaskName "YourScheduledTaskName"

