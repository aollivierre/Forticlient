function Create-OneDriveRemediationTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OneDriveExePath,

        [Parameter(Mandatory = $true)]
        [string]$ScheduledTaskName,

        [Parameter(Mandatory = $true)]
        [string]$ScheduledTaskDescription,

        [Parameter(Mandatory = $false)]
        [string]$ScheduledTaskArgumentList
    )

    Begin {
        Write-EnhancedLog -Message "Starting Create-OneDriveRemediationTask function" -Level "INFO"
        Log-Params -Params @{
            OneDriveExePath            = $OneDriveExePath
            ScheduledTaskName          = $ScheduledTaskName
            ScheduledTaskDescription   = $ScheduledTaskDescription
            ScheduledTaskArgumentList  = $ScheduledTaskArgumentList
        }
    }

    Process {
        try {
            # $userId = (Get-WmiObject -Class Win32_ComputerSystem).UserName
            $userId = $env:UserName
            if (-not $userId) {
                throw "Unable to retrieve the current user ID."
            }

            Write-EnhancedLog -Message "User ID retrieved: $userId" -Level "INFO"

            $actionParams = @{
                Execute  = $OneDriveExePath
            }
            if ($ScheduledTaskArgumentList) {
                $actionParams.Argument = $ScheduledTaskArgumentList
            }
            $action = New-ScheduledTaskAction @actionParams

            $trigger = New-ScheduledTaskTrigger -AtLogOn

            $principalParams = @{
                UserId = $userId
            }
            $principal = New-ScheduledTaskPrincipal @principalParams

            $taskParams = @{
                Action      = $action
                Trigger     = $trigger
                Principal   = $principal
                TaskName    = $ScheduledTaskName
                Description = $ScheduledTaskDescription
                Force       = $true
            }
            $task = Register-ScheduledTask @taskParams

            Start-ScheduledTask -TaskName $ScheduledTaskName

            # $DBG
            Start-Sleep -Seconds 5
            Unregister-ScheduledTask -TaskName $ScheduledTaskName -Confirm:$false
        } catch {
            Write-EnhancedLog -Message "An error occurred in Create-OneDriveRemediationTask function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Create-OneDriveRemediationTask function" -Level "INFO"
    }
}


# $CreateOneDriveRemediationTaskParams = @{
#     OneDriveExePath           = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
#     ScheduledTaskName         = "OneDriveRemediation"
#     ScheduledTaskDescription  = "Restart OneDrive to kick off KFM sync"
#     ScheduledTaskArgumentList = ""
# }

# Create-OneDriveRemediationTask @CreateOneDriveRemediationTaskParams
