function Remove-ExistingServiceUI {
    [CmdletBinding()]
    param(
        [string]$TargetFolder = "$PSScriptRoot\private"
    )

    # Full path for ServiceUI.exe
    $ServiceUIPath = Join-Path -Path $TargetFolder -ChildPath "ServiceUI.exe"

    try {
        # Check if ServiceUI.exe exists
        if (Test-Path -Path $ServiceUIPath) {
            Write-EnhancedLog -Message "Removing existing ServiceUI.exe from: $TargetFolder" -Level "INFO"
            # Remove ServiceUI.exe
            Remove-Item -Path $ServiceUIPath -Force
            Write-Output "ServiceUI.exe has been removed from: $TargetFolder"
        }
        else {
            Write-EnhancedLog -Message "No ServiceUI.exe file found in: $TargetFolder" -Level "INFO"
        }
    }
    catch {
        # Handle any errors during the removal
        Write-Error "An error occurred while trying to remove ServiceUI.exe: $_"
        Write-EnhancedLog -Message "An error occurred while trying to remove ServiceUI.exe: $_" -Level "ERROR"
    }
}