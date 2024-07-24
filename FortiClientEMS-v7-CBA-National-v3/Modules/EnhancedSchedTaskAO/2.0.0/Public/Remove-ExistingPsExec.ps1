
function Remove-ExistingPsExec {
    [CmdletBinding()]
    param(
        # [string]$TargetFolder = "$PSScriptRoot\private"
        [string]$TargetFolder
    )

    # Full path for PsExec64.exe
    $PsExec64Path = Join-Path -Path $TargetFolder -ChildPath "PsExec64.exe"

    try {
        # Check if PsExec64.exe exists
        if (Test-Path -Path $PsExec64Path) {
            Write-EnhancedLog -Message "Removing existing PsExec64.exe from: $TargetFolder"
            # Remove PsExec64.exe
            Remove-Item -Path $PsExec64Path -Force
            Write-EnhancedLog -Message "PsExec64.exe has been removed from: $TargetFolder"
        }
        else {
            Write-EnhancedLog -Message "No PsExec64.exe file found in: $TargetFolder"
        }
    }
    catch {
        # Handle any errors during the removal
        Write-Error "An error occurred while trying to remove PsExec64.exe: $_"
    }
}

