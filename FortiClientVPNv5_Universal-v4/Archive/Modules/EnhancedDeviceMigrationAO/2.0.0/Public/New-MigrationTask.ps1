function New-MigrationTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$StartBoundary,

        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $true)]
        [string]$TaskPath,

        [Parameter(Mandatory = $true)]
        [string]$TaskName,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [string]$UserId,

        [Parameter(Mandatory = $true)]
        [string]$RunLevel,

        [Parameter(Mandatory = $true)]
        [string]$Delay,

        [Parameter(Mandatory = $true)]
        [string]$ExecutePath,

        [Parameter(Mandatory = $true)]
        [string]$Arguments
    )

    Begin {
        Write-EnhancedLog -Message "Starting New-MigrationTask function" -Level "INFO"
        Log-Params -Params @{
            StartBoundary = $StartBoundary
            ScriptPath    = $ScriptPath
            TaskPath      = $TaskPath
            TaskName      = $TaskName
            Description   = $Description
            UserId        = $UserId
            RunLevel      = $RunLevel
            Delay         = $Delay
            ExecutePath   = $ExecutePath
            Arguments     = $Arguments
        }
    }

    Process {
        try {
            $action = New-ScheduledTaskAction -Execute $ExecutePath -Argument $Arguments

            $trigger = New-ScheduledTaskTrigger -AtLogOn 
            $trigger.Delay = $Delay
            $trigger.StartBoundary = $StartBoundary

            $principal = New-ScheduledTaskPrincipal -UserId $UserId -RunLevel $RunLevel

            Register-ScheduledTask -Principal $principal -Action $action -Trigger $trigger -TaskName $TaskName -Description $Description -TaskPath $TaskPath
        } catch {
            Write-EnhancedLog -Message "An error occurred while creating the migration task: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting New-MigrationTask function" -Level "INFO"
    }
}

# Define parameters
# $MigrationTaskParams = @{
#     StartBoundary = "2024-07-11T12:00:00"
#     ScriptPath    = "C:\ProgramData\AADMigration\Scripts\Launch-DeployApplication_SchTask.ps1"
#     TaskPath      = "AAD Migration"
#     TaskName      = "AADM Launch PSADT for Interactive Migration"
#     Description   = "AADM Launch PSADT for Interactive Migration"
#     UserId        = "SYSTEM"
#     RunLevel      = "Highest"
#     Delay         = "PT1M"
#     ExecutePath   = "PowerShell.exe"
#     Arguments     = "-executionpolicy Bypass -file `"$ScriptPath`""
# }

# # Example usage with splatting
# New-MigrationTask @MigrationTaskParams
