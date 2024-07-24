
function Get-CustomWin32AppName {
    [CmdletBinding()]
    param(
        [string]$PRGID
    )
    process {
        if (-not [string]::IsNullOrWhiteSpace($PRGID)) {
            return $PRGID  # Directly return PRGID if it's valid
        }
        else {
            return "DefaultAppName"  # Fallback if PRGID is not provided
        }
    }
}


# Get-CustomWin32AppName
