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

    .PARAMETER ScriptMode
    The mode in which the script should run.

    .PARAMETER PackageExecutionContext
    The context in which the package should execute.

    .PARAMETER schtaskDescription
    The description of the scheduled task.

    .EXAMPLE
    CheckAndExecuteTask -schtaskName "MyScheduledTask" -Version 1 -Path_PR "C:\Tasks\MyTask"

    This example checks for an existing scheduled task named "MyScheduledTask" of version 1. If it exists, it executes the associated tasks; otherwise, it sets up a new environment and registers the task.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$schtaskName,

        # [Parameter(Mandatory = $true)]
        # [int]$Version,

        [Parameter(Mandatory = $true)]
        [string]$Path_PR,

        [Parameter(Mandatory = $true)]
        [string]$ScriptMode,

        [Parameter(Mandatory = $true)]
        [string]$PackageExecutionContext,

        [Parameter(Mandatory = $true)]
        [string]$schtaskDescription,


        [Parameter(Mandatory = $true)]
        [string]$RepetitionInterval,

        [Parameter(Mandatory = $true)]
        [string]$Path_VBShiddenPS
    )

    begin {
        Write-EnhancedLog -Message 'Starting CheckAndExecuteTask function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            Write-EnhancedLog -Message "Checking for existing task: $schtaskName" -Level "INFO"

            $checkParams = @{
                taskName = $schtaskName
                # version  = $Version
            }
            $taskExists = Check-ExistingTask @checkParams

            if ($taskExists) {
                Write-EnhancedLog -Message "Existing task found. Executing detection and remediation scripts." -Level "INFO"
                $executeParams = @{
                    Path_PR = $Path_PR
                }
                Execute-DetectionAndRemediation @executeParams
            }
            else {
                Write-EnhancedLog -Message "No existing task found. Setting up new task environment." -Level "INFO"
                $setupParams = @{
                    Path_PR                 = $Path_PR
                    schtaskName             = $schtaskName
                    schtaskDescription      = $schtaskDescription
                    ScriptMode              = $ScriptMode
                    PackageExecutionContext = $PackageExecutionContext
                    RepetitionInterval      = $RepetitionInterval
                    Path_VBShiddenPS        = $Path_VBShiddenPS
                }
                SetupNewTaskEnvironment @setupParams
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while checking and executing the task: $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'CheckAndExecuteTask function completed' -Level 'INFO'
    }
}




# # Example usage of CheckAndExecuteTask function with splatting
# $params = @{
#     schtaskName            = "MyScheduledTask"
#     Version                = 1
#     Path_PR                = "C:\Tasks\MyTask"
#     ScriptMode             = "Normal"
#     PackageExecutionContext = "User"
#     schtaskDescription     = "This is a scheduled task for MyTask"
# }

# # Call the CheckAndExecuteTask function using splatting
# CheckAndExecuteTask @params

