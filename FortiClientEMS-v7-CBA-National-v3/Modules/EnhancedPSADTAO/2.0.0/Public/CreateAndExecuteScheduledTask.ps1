function CreateAndExecuteScheduledTask {
    <#
    .SYNOPSIS
    Creates and executes a scheduled task based on the provided configuration.

    .DESCRIPTION
    This function initializes variables, ensures necessary paths exist, copies files, creates a VBScript for hidden execution, and manages the execution of detection and remediation scripts. If the task does not exist, it sets up a new task environment.

    .PARAMETER ConfigPath
    The path to the JSON configuration file.

    .PARAMETER FileName
    The name of the file to be used for the VBScript.

    .EXAMPLE
    CreateAndExecuteScheduledTask -ConfigPath "C:\Tasks\Config.json" -FileName "HiddenScript.vbs"

    This example creates and executes a scheduled task based on the provided configuration file and VBScript file name.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [string]$Scriptroot

    )

    begin {
        Write-EnhancedLog -Message 'Starting CreateAndExecuteScheduledTask function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Load configuration from JSON file
            $config = Get-Content -Path $ConfigPath | ConvertFrom-Json

            # Initialize variables directly from the config
            $PackageName = $config.PackageName
            $PackageUniqueGUID = $config.PackageUniqueGUID
            $Version = $config.Version
            $ScriptMode = $config.ScriptMode
            $PackageExecutionContext = $config.PackageExecutionContext
            $RepetitionInterval = $config.RepetitionInterval
            $DataFolder = $config.DataFolder

            # Determine local path based on execution context if not provided
            if (-not $Path_local) {
                if (Test-RunningAsSystem) {
                    $Path_local = "c:\_MEM"
                }
                else {
                    $Path_local = "$ENV:LOCALAPPDATA\_MEM"
                }
            }

            $Path_PR = "$Path_local\Data\$PackageName-$PackageUniqueGUID"
            $schtaskName = "$PackageName - $PackageUniqueGUID"
            $schtaskDescription = "Version $Version"

            # Ensure script paths exist
            if (-not (Test-Path -Path $Path_local)) {
                New-Item -Path $Path_local -ItemType Directory -Force | Out-Null
                Write-EnhancedLog -Message "Created directory: $Path_local" -Level "INFO"
            }

            if (-not (Test-Path -Path $Path_PR)) {
                New-Item -Path $Path_PR -ItemType Directory -Force | Out-Null
                Write-EnhancedLog -Message "Created directory: $Path_PR" -Level "INFO"
            }

            # Copy files to path
            $CopyFilesToPathParams = @{
                SourcePath      = $Scriptroot
                DestinationPath = $Path_PR
            }
            Copy-FilesToPath @CopyFilesToPathParams

            # Ensure the script runs with administrative privileges
            if (-not (IsAdmin)) {
                Write-EnhancedLog -Message "Script requires administrative privileges." -Level "ERROR"
                exit
            }

            # Ensure the Data folder exists
            $DataFolderPath = Join-Path -Path $Path_local -ChildPath $DataFolder
            if (-not (Test-Path -Path $DataFolderPath -PathType Container)) {
                New-Item -ItemType Directory -Path $DataFolderPath -Force | Out-Null
                Write-EnhancedLog -Message "Data folder created at $DataFolderPath" -Level "INFO"
            }

            # Create the VBScript to run PowerShell script hidden
            try {
                $CreateVBShiddenPSParams = @{
                    Path_local = $Path_local
                    DataFolder = $DataFolder
                    FileName   = $FileName
                }
                $Path_VBShiddenPS = Create-VBShiddenPS @CreateVBShiddenPSParams

                # Validation of the VBScript file creation
                if (Test-Path -Path $Path_VBShiddenPS) {
                    Write-EnhancedLog -Message "Validation successful: VBScript file exists at $Path_VBShiddenPS" -Level "INFO"
                }
                else {
                    Write-EnhancedLog -Message "Validation failed: VBScript file does not exist at $Path_VBShiddenPS. Check script execution and permissions." -Level "WARNING"
                }
            }
            catch {
                Write-EnhancedLog -Message "An error occurred while creating VBScript: $_" -Level "ERROR"
            }

            # Check and execute task
            $checkTaskParams = @{
                taskName = $schtaskName
            }

            $taskExists = Check-ExistingTask @checkTaskParams

            if ($taskExists) {
                Write-EnhancedLog -Message "Existing task found. Executing detection and remediation scripts." -Level "INFO"
                
                $executeParams = @{
                    Path_PR = $Path_PR
                }
                
                Execute-DetectionAndRemediation @executeParams
            }
            else {
                Write-EnhancedLog -Message "No existing task found. Setting up new task environment." -Level "INFO"

                # Setup new task environment
                $Path_PSscript = switch ($ScriptMode) {
                    "Remediation" { Join-Path $Path_PR "remediation.ps1" }
                    "PackageName" { Join-Path $Path_PR "$PackageName.ps1" }
                    Default { throw "Invalid ScriptMode: $ScriptMode. Expected 'Remediation' or 'PackageName'." }
                }

                $scheduledTaskParams = @{
                    schtaskName             = $schtaskName
                    schtaskDescription      = $schtaskDescription
                    Path_vbs                = $Path_VBShiddenPS
                    Path_PSscript           = $Path_PSscript
                    PackageExecutionContext = $PackageExecutionContext
                    RepetitionInterval      = $RepetitionInterval
                }

                MyRegisterScheduledTask @scheduledTaskParams

                Write-EnhancedLog -Message "Scheduled task $schtaskName with description '$schtaskDescription' registered successfully." -Level "INFO"
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred: $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'CreateAndExecuteScheduledTask function completed' -Level 'INFO'
    }
}

function MyRegisterScheduledTask {
    param (
        [Parameter(Mandatory = $true)]
        [string]$schtaskName,

        [Parameter(Mandatory = $true)]
        [string]$schtaskDescription,

        [Parameter(Mandatory = $true)]
        [string]$Path_vbs,

        [Parameter(Mandatory = $true)]
        [string]$Path_PSscript,

        [Parameter(Mandatory = $true)]
        [string]$PackageExecutionContext,

        [Parameter(Mandatory = $true)]
        [string]$RepetitionInterval
    )

    try {
        Write-EnhancedLog -Message "Registering scheduled task: $schtaskName" -Level "INFO" -ForegroundColor Magenta

        $startTime = (Get-Date).AddMinutes(1).ToString("HH:mm")

        # Define the action based on the provided options in the config.json
        if ($config.UsePSADT) {
            Write-EnhancedLog -Message "Setting up Schedule Task action for Service UI and PSADT" -Level "INFO" -ForegroundColor Magenta

            # Define the path to the PowerShell Application Deployment Toolkit executable
            $ToolkitExecutable = "$Path_PR\Private\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"

            # Define the path to the ServiceUI executable
            $ServiceUIExecutable = "$Path_PR\Private\ServiceUI.exe"

            # Define the deployment type
            $DeploymentType = "install"

            # Define the arguments for ServiceUI.exe
            $argList = "-process:explorer.exe `"$ToolkitExecutable`" -DeploymentType $DeploymentType"

            # Create the scheduled task action
            $action = New-ScheduledTaskAction -Execute $ServiceUIExecutable -Argument $argList
        }
        else {
            Write-EnhancedLog -Message "Setting up Scheduled Task action for wscript and VBS" -Level "INFO" -ForegroundColor Magenta

            # Define the arguments for wscript.exe
            $argList = "`"$Path_vbs`" `"$Path_PSscript`""

            # Create the scheduled task action for wscript and VBS
            $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\wscript.exe" -Argument $argList
        }

        # Define the trigger based on the TriggerType
        if ($config.TriggerType -eq "Daily") {
            $trigger = New-ScheduledTaskTrigger -Daily -At $startTime
            Write-EnhancedLog -Message "Trigger set to Daily at $startTime" -Level "INFO"
        }
        elseif ($config.TriggerType -eq "Logon") {
            if (-not $config.LogonUserId) {
                throw "LogonUserId must be specified for Logon trigger type."
            }
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            Write-EnhancedLog -Message "Trigger set to logon of user $($config.LogonUserId)" -Level "INFO"
        }
        else {
            throw "Invalid TriggerType specified in the configuration."
        }

        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        # Register the scheduled task
        if ($config.RunOnDemand -eq $true) {
            Write-EnhancedLog -Message "Registering task with RunOnDemand set to $($config.RunOnDemand)" -Level "INFO"
            $task = Register-ScheduledTask -TaskName $schtaskName -Action $action -Principal $principal -Description $schtaskDescription -Force
        }
        else {
            Write-EnhancedLog -Message "Registering task with RunOnDemand set to $($config.RunOnDemand)" -Level "INFO"
            $task = Register-ScheduledTask -TaskName $schtaskName -Action $action -Trigger $trigger -Principal $principal -Description $schtaskDescription -Force
        }

        $task = Get-ScheduledTask -TaskName $schtaskName
        $task.Triggers[0].Repetition.Interval = $RepetitionInterval
        $task | Set-ScheduledTask

        if ($PackageExecutionContext -eq "User") {
            $ShedService = New-Object -ComObject 'Schedule.Service'
            $ShedService.Connect()
            $taskFolder = $ShedService.GetFolder("\")
            $Task = $taskFolder.GetTask("$schtaskName")
            $taskFolder.RegisterTaskDefinition("$schtaskName", $Task.Definition, 6, 'Users', $null, 4)
        }

        Write-EnhancedLog -Message "Scheduled task $schtaskName registered successfully." -Level "INFO" -ForegroundColor Green
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while registering the scheduled task: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}

# $configPath = Join-Path -Path $Scriptroot -ChildPath "config.json"
# $env:MYMODULE_CONFIG_PATH = $configPath

# # Define parameters for the function
# $taskParams = @{
#     ConfigPath = $configPath
#     FileName   = "HiddenScript.vbs"
# }

# # Call the function with splatted parameters
# CreateAndExecuteScheduledTask @taskParams



