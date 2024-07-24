function Set-RunOnce {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory = $true)]
        [string]$RunOnceKey,
        
        [Parameter(Mandatory = $true)]
        [string]$PowershellPath,
        
        [Parameter(Mandatory = $true)]
        [string]$ExecutionPolicy,
        
        [Parameter(Mandatory = $true)]
        [string]$RunOnceName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Set-RunOnce function" -Level "INFO"
        Log-Params -Params @{
            ScriptPath      = $ScriptPath
            RunOnceKey      = $RunOnceKey
            PowershellPath  = $PowershellPath
            ExecutionPolicy = $ExecutionPolicy
            RunOnceName     = $RunOnceName
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Setting RunOnce script" -Level "INFO"
            $RunOnceValue = "$PowershellPath -executionPolicy $ExecutionPolicy -File $ScriptPath"
            Set-ItemProperty -Path $RunOnceKey -Name $RunOnceName -Value $RunOnceValue -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while setting RunOnce script: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Set-RunOnce function" -Level "INFO"
    }
}

# # Example usage with splatting
# $SetRunOnceParams = @{
#     ScriptPath      = "C:\YourScriptPath.ps1"
#     RunOnceKey      = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
#     PowershellPath  = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
#     ExecutionPolicy = "Unrestricted"
#     RunOnceName     = "NextRun"
# }

# Set-RunOnce @SetRunOnceParams
