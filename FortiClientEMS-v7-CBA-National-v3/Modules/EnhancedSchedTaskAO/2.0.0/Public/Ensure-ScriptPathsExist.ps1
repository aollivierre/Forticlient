

function Ensure-ScriptPathsExist {


    <#
.SYNOPSIS
Ensures that all necessary script paths exist, creating them if they do not.

.DESCRIPTION
This function checks for the existence of essential script paths and creates them if they are not found. It is designed to be called after initializing script variables to ensure the environment is correctly prepared for the script's operations.

.PARAMETER Path_local
The local path where the script's data will be stored. This path varies based on the execution context (system vs. user).

.PARAMETER Path_PR
The specific path for storing package-related files, constructed based on the package name and unique GUID.

.EXAMPLE
Ensure-ScriptPathsExist -Path_local $global:Path_local -Path_PR $global:Path_PR

This example ensures that the paths stored in the global variables $Path_local and $Path_PR exist, creating them if necessary.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path_local,

        [Parameter(Mandatory = $true)]
        [string]$Path_PR
    )

    try {
        # Ensure Path_local exists
        if (-not (Test-Path -Path $Path_local)) {
            New-Item -Path $Path_local -ItemType Directory -Force | Out-Null
            Write-EnhancedLog -Message "Created directory: $Path_local" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
        }

        # Ensure Path_PR exists
        if (-not (Test-Path -Path $Path_PR)) {
            New-Item -Path $Path_PR -ItemType Directory -Force | Out-Null
            Write-EnhancedLog -Message "Created directory: $Path_PR" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while ensuring script paths exist: $_" -Level "ERROR" -ForegroundColor ([System.ConsoleColor]::Red)
    }
}
