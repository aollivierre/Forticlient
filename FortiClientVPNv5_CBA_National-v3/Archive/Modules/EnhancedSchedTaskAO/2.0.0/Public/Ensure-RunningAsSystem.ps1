function Ensure-RunningAsSystem {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PsExec64Path,
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $true)]
        [string]$TargetFolder
    )

     Write-EnhancedLog -Message "Calling Test-RunningAsSystem" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    
    if (-not (Test-RunningAsSystem)) {
        # Check if the target folder exists, and create it if it does not
        if (-not (Test-Path -Path $TargetFolder)) {
            New-Item -Path $TargetFolder -ItemType Directory | Out-Null
        }

        $PsExec64Path = Join-Path -Path $TargetFolder -ChildPath "PsExec64.exe"
        
         Write-EnhancedLog -Message "Current session is not running as SYSTEM. Attempting to invoke as SYSTEM..." -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)

        Invoke-AsSystem -PsExec64Path $PsExec64Path -ScriptPath $ScriptPath -TargetFolder $TargetFolder
    }
    else {
         Write-EnhancedLog -Message "Session is already running as SYSTEM." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }
}

# # Example usage
# $privateFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "private"
# $PsExec64Path = Join-Path -Path $privateFolderPath -ChildPath "PsExec64.exe"
# $ScriptToRunAsSystem = $MyInvocation.MyCommand.Path

# Ensure-RunningAsSystem -PsExec64Path $PsExec64Path -ScriptPath $ScriptToRunAsSystem -TargetFolder $privateFolderPath
