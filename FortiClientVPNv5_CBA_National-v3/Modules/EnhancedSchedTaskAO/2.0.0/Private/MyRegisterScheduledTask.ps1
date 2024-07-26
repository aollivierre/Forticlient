
# function MyRegisterScheduledTask {


#     <#
# .SYNOPSIS
# Registers a scheduled task with the system.

# .DESCRIPTION
# This function creates a new scheduled task with the specified parameters, including the name, description, VBScript path, and PowerShell script path. It sets up a basic daily trigger and runs the task as the SYSTEM account with the highest privileges. Enhanced logging is used for status messages and error handling to manage potential issues.

# .PARAMETER schtaskName
# The name of the scheduled task to register.

# .PARAMETER schtaskDescription
# A description for the scheduled task.

# .PARAMETER Path_vbs
# The path to the VBScript file used to run the PowerShell script.

# .PARAMETER Path_PSscript
# The path to the PowerShell script to execute.

# .EXAMPLE
# MyRegisterScheduledTask -schtaskName "MyTask" -schtaskDescription "Performs automated checks" -Path_vbs "C:\Scripts\run-hidden.vbs" -Path_PSscript "C:\Scripts\myScript.ps1"

# This example registers a new scheduled task named "MyTask" that executes "myScript.ps1" using "run-hidden.vbs".
# #>

#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$schtaskName,

#         [Parameter(Mandatory = $true)]
#         [string]$schtaskDescription,

#         [Parameter(Mandatory = $true)]
#         # [ValidateScript({Test-Path $_ -File})]
#         [string]$Path_vbs,

#         [Parameter(Mandatory = $true)]
#         # [ValidateScript({Test-Path $_ -File})]
#         [string]$Path_PSscript,

#         [Parameter(Mandatory = $true)]
#         # [ValidateScript({Test-Path $_ -File})]
#         [string]$PackageExecutionContext
#     )

#     try {
#         Write-EnhancedLog -Message "Registering scheduled task: $schtaskName" -Level "INFO" -ForegroundColor Magenta

#         $startTime = (Get-Date).AddMinutes(1).ToString("HH:mm")

        
#         # $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "`"$Path_vbs`" `"$Path_PSscript`""
#         # $argList = "-NoExit -ExecutionPolicy Bypass -File"
#         # $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "`"$argList`" `"$Path_PSscript`""



#         # Define the path to the PowerShell script
#         # $Path_PSscript = "C:\Path\To\Your\Script.ps1"

#         # Define the arguments for the PowerShell executable
#         # $argList = "-NoExit -ExecutionPolicy Bypass -File `"$Path_PSscript`""

#         # # Create the scheduled task action
#         # $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $argList








#         # # Load the configuration from config.json
#         # $configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
#         # $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

#         # # Define the principal for the task
#         # $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
#         # Write-EnhancedLog -Message "Principal for the task defined." -Level "INFO"

#         # Define the action based on the provided options in the config.json
#         if ($config.UsePSADT) {
#             Write-EnhancedLog -Message "setting up Schedule Task action for Service UI and PSADT" -Level "INFO" -ForegroundColor Magenta

#             # Define the path to the PowerShell Application Deployment Toolkit executable
#             # $ToolkitExecutable = "$PSScriptRoot\Private\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"
#             $ToolkitExecutable = "$Path_PR\Private\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"

#             # Define the path to the ServiceUI executable
#             # $ServiceUIExecutable = "$PSScriptRoot\Private\ServiceUI.exe"
#             $ServiceUIExecutable = "$Path_PR\Private\ServiceUI.exe"

#             # Define the deployment type
#             $DeploymentType = "install"

#             # Define the arguments for ServiceUI.exe
#             $argList = "-process:explorer.exe `"$ToolkitExecutable`" -DeploymentType $DeploymentType"

#             # Create the scheduled task action
#             $action = New-ScheduledTaskAction -Execute $ServiceUIExecutable -Argument $argList
#         }
#         else {
#             Write-EnhancedLog -Message "Setting up Scheduled Task action for wscript and VBS" -Level "INFO" -ForegroundColor Magenta

#             # Define the arguments for wscript.exe
#             $argList = "`"$Path_vbs`" `"$Path_PSscript`""

#             # Create the scheduled task action for wscript and VBS
#             $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\wscript.exe" -Argument $argList
#         }


#         # Write-EnhancedLog -Message "Scheduled Task '$($config.TaskName)' created successfully." -Level "INFO"

        


















#         #option 1 - NO PSADT but rather Wscript and VBS

#         # $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\wscript.exe" -Argument "`"$Path_vbs`" `"$Path_PSscript`""




#         # #option 2 - ServiceUI calling PSADT in the SYSTEM context
#         # Write-EnhancedLog -Message "setting up Schedule Task action for Service UI and PSADT" -Level "INFO" -ForegroundColor Magenta

#         # # Define the path to the PowerShell Application Deployment Toolkit executable
#         # # $ToolkitExecutable = "$PSScriptRoot\Private\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"
#         # $ToolkitExecutable = "$Path_PR\Private\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"

#         # # Define the path to the ServiceUI executable
#         # # $ServiceUIExecutable = "$PSScriptRoot\Private\ServiceUI.exe"
#         # $ServiceUIExecutable = "$Path_PR\Private\ServiceUI.exe"

#         # # Define the deployment type
#         # $DeploymentType = "install"

#         # # Define the arguments for ServiceUI.exe
#         # $argList = "-process:explorer.exe `"$ToolkitExecutable`" -DeploymentType $DeploymentType"

#         # # Create the scheduled task action
#         # $action = New-ScheduledTaskAction -Execute $ServiceUIExecutable -Argument $argList



#         #option 1: Trigger - Daily Frequency

#         # $trigger = New-ScheduledTaskTrigger -Daily -At $startTime

#         #option 2: Trigger On logon of user defaultuser0 (OOBE)




#         # Load the configuration from config.json
#         # $configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
#         # $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

#         # Define the trigger based on the TriggerType
#         if ($config.TriggerType -eq "Daily") {
#             $trigger = New-ScheduledTaskTrigger -Daily -At $startTime
#             Write-EnhancedLog -Message "Trigger set to Daily at $startTime" -Level "INFO"
#         }
#         elseif ($config.TriggerType -eq "Logon") {
#             if (-not $config.LogonUserId) {
#                 throw "LogonUserId must be specified for Logon trigger type."
#             }
#             # $trigger = New-ScheduledTaskTrigger -AtLogOn -User $config.LogonUserId
#             $trigger = New-ScheduledTaskTrigger -AtLogOn
#             Write-EnhancedLog -Message "Trigger set to logon of user $($config.LogonUserId)" -Level "INFO"
#         }
#         else {
#             throw "Invalid TriggerType specified in the configuration."
#         }

#         $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

#         # $task = Register-ScheduledTask -TaskName $schtaskName -Action $action -Trigger $trigger -Principal $principal -Description $schtaskDescription -Force


  

#         # Check if the task should run on demand (Zero triggers defined)
#         if ($config.RunOnDemand -eq $true) {
#             Write-EnhancedLog -Message "calling Register-ScheduledTask with RunOnDemand set to $($config.RunOnDemand)"
#             # Task to run on demand; no trigger defined
#             $task = Register-ScheduledTask -TaskName $schtaskName -Action $action -Principal $principal -Description $schtaskDescription -Force

#             $task = Get-ScheduledTask -TaskName $schtaskName
#         }
#         else {
#             # Define your trigger here
#             Write-EnhancedLog -Message "calling Register-ScheduledTask with RunOnDemand set to $($config.RunOnDemand)"
#             $task = Register-ScheduledTask -TaskName $schtaskName -Action $action -Trigger $trigger -Principal $principal -Description $schtaskDescription -Force
#             # $DBG

#             Write-EnhancedLog -Message "calling Register-ScheduledTask done"

#             Write-EnhancedLog -Message "calling Get-ScheduledTask"
#             $task = Get-ScheduledTask -TaskName $schtaskName
#             Write-EnhancedLog -Message "calling Get-ScheduledTask done"
            
#             $task.Triggers[0].Repetition.Interval = $RepetitionInterval
#             $task | Set-ScheduledTask
#         }



#         # Updating the task to include repetition with a 5-minute interval
        

#         # Check the execution context specified in the config
#         if ($PackageExecutionContext -eq "User") {
#             # This code block will only execute if ExecutionContext is set to "User"

#             # Connect to the Task Scheduler service
#             $ShedService = New-Object -ComObject 'Schedule.Service'
#             $ShedService.Connect()

#             # Get the folder where the task is stored (root folder in this case)
#             $taskFolder = $ShedService.GetFolder("\")
    
#             # Get the existing task by name
#             $Task = $taskFolder.GetTask("$schtaskName")

#             # Update the task with a new definition
#             $taskFolder.RegisterTaskDefinition("$schtaskName", $Task.Definition, 6, 'Users', $null, 4)  # 6 is TASK_CREATE_OR_UPDATE
#         }
#         else {
#             Write-Host "Execution context is not set to 'User', skipping this block."
#         }



#         Write-EnhancedLog -Message "Scheduled task $schtaskName registered successfully." -Level "INFO" -ForegroundColor Green
#     }
#     catch {
#         Write-EnhancedLog -Message "An error occurred while registering the scheduled task: $_" -Level "ERROR" -ForegroundColor Red
#         throw $_
#     }
# }
