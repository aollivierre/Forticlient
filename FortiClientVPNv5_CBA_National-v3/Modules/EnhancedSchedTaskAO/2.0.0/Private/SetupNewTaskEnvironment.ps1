# function SetupNewTaskEnvironment {
#     <#
#     .SYNOPSIS
#     Sets up a new task environment for scheduled task execution.

#     .DESCRIPTION
#     This function prepares the environment for a new scheduled task. It creates a specified directory, determines the PowerShell script path based on the script mode, generates a VBScript to run the PowerShell script hidden, and finally registers the scheduled task with the provided parameters. It utilizes enhanced logging for feedback and error handling to manage potential issues.

#     .PARAMETER Path_PR
#     The path where the task's scripts and support files will be stored.

#     .PARAMETER schtaskName
#     The name of the scheduled task to be created.

#     .PARAMETER schtaskDescription
#     A description for the scheduled task.

#     .PARAMETER ScriptMode
#     Determines the script type to be executed ("Remediation" or "PackageName").

#     .PARAMETER PackageExecutionContext
#     The context in which the package should execute.

#     .PARAMETER RepetitionInterval
#     The interval at which the task should repeat.

#     .PARAMETER Path_VBShiddenPS
#     The path to the VBScript file that runs the PowerShell script hidden.

#     .EXAMPLE
#     SetupNewTaskEnvironment -Path_PR "C:\Tasks\MyTask" -schtaskName "MyScheduledTask" -schtaskDescription "This task does something important" -ScriptMode "Remediation" -PackageExecutionContext "User" -RepetitionInterval "PT1H" -Path_VBShiddenPS "C:\Tasks\MyTask\run-ps-hidden.vbs"

#     This example sets up the environment for a scheduled task named "MyScheduledTask" with a specific description, intended for remediation purposes.
#     #>

#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$Path_PR,

#         [Parameter(Mandatory = $true)]
#         [string]$schtaskName,

#         [Parameter(Mandatory = $true)]
#         [string]$schtaskDescription,

#         [Parameter(Mandatory = $true)]
#         [ValidateSet("Remediation", "PackageName")]
#         [string]$ScriptMode,

#         [Parameter(Mandatory = $true)]
#         [string]$PackageExecutionContext,

#         [Parameter(Mandatory = $true)]
#         [string]$RepetitionInterval,

#         [Parameter(Mandatory = $true)]
#         [string]$Path_VBShiddenPS
#     )

#     begin {
#         Write-EnhancedLog -Message 'Starting SetupNewTaskEnvironment function' -Level 'INFO'
#         Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
#     }

#     process {
#         try {
#             Write-EnhancedLog -Message "Setting up new task environment at $Path_PR." -Level "INFO" -ForegroundColor Cyan

#             # Determine the PowerShell script path based on ScriptMode
#             $Path_PSscript = switch ($ScriptMode) {
#                 "Remediation" { Join-Path $Path_PR "remediation.ps1" }
#                 "PackageName" { Join-Path $Path_PR "$PackageName.ps1" }
#                 Default { throw "Invalid ScriptMode: $ScriptMode. Expected 'Remediation' or 'PackageName'." }
#             }

#             $scheduledTaskParams = @{
#                 schtaskName             = $schtaskName
#                 schtaskDescription      = $schtaskDescription
#                 Path_vbs                = $Path_VBShiddenPS
#                 Path_PSscript           = $Path_PSscript
#                 PackageExecutionContext = $PackageExecutionContext
#                 RepetitionInterval      = $RepetitionInterval
#             }

#             Log-Params -Params $scheduledTaskParams

#             MyRegisterScheduledTask @scheduledTaskParams

#             Write-EnhancedLog -Message "Scheduled task $schtaskName with description '$schtaskDescription' registered successfully." -Level "INFO"
#         } catch {
#             Write-EnhancedLog -Message "An error occurred during setup of new task environment: $_" -Level "ERROR"
#             Handle-Error -ErrorRecord $_
#         }
#     }

#     end {
#         Write-EnhancedLog -Message 'SetupNewTaskEnvironment function completed' -Level 'INFO'
#     }
# }
