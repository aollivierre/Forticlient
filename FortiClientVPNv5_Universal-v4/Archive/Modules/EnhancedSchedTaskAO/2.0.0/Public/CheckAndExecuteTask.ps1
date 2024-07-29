
function CheckAndExecuteTask {

<#
.SYNOPSIS
Checks for an existing scheduled task and executes tasks based on conditions.

.DESCRIPTION
This function checks if a scheduled task with the specified name and version exists. If it does, it proceeds to execute detection and remediation scripts. If not, it sets up a new task environment and registers the task. It uses enhanced logging for status messages and error handling to manage potential issues.

.PARAMETER schtaskName
The name of the scheduled task to check and potentially execute.

.PARAMETER Version
The version of the task to check for. This is used to verify if the correct task version is already scheduled.

.PARAMETER Path_PR
The path to the directory containing the detection and remediation scripts, used if the task needs to be executed.

.EXAMPLE
CheckAndExecuteTask -schtaskName "MyScheduledTask" -Version 1 -Path_PR "C:\Tasks\MyTask"

This example checks for an existing scheduled task named "MyScheduledTask" of version 1. If it exists, it executes the associated tasks; otherwise, it sets up a new environment and registers the task.
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$schtaskName,

        [Parameter(Mandatory = $true)]
        [int]$Version,

        [Parameter(Mandatory = $true)]
        [string]$Path_PR,

        [Parameter(Mandatory = $true)]
        [string]$ScriptMode, # Adding ScriptMode as a parameter

        [Parameter(Mandatory = $true)]
        [string]$PackageExecutionContext

    )

    try {
        Write-EnhancedLog -Message "Checking for existing task: $schtaskName" -Level "INFO" -ForegroundColor Cyan

        $taskExists = Check-ExistingTask -taskName $schtaskName -version $Version
        if ($taskExists) {
            Write-EnhancedLog -Message "Existing task found. Executing detection and remediation scripts." -Level "INFO" -ForegroundColor Green
            Execute-DetectionAndRemediation -Path_PR $Path_PR
        }
        else {
            Write-EnhancedLog -Message "No existing task found. Setting up new task environment." -Level "INFO" -ForegroundColor Yellow
            SetupNewTaskEnvironment -Path_PR $Path_PR -schtaskName $schtaskName -schtaskDescription $schtaskDescription -ScriptMode $ScriptMode -PackageExecutionContext $PackageExecutionContext
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while checking and executing the task: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}