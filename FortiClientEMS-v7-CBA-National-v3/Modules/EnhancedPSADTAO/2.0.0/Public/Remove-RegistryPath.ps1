function Remove-RegistryPath {
    param (
        [string]$RegistryPath
    )

    Write-EnhancedLog -Message "Starting Remove-RegistryPath function for: $RegistryPath" -Level 'INFO'

    try {
        if (Test-Path -Path "Registry::$RegistryPath") {
            Remove-Item -Path "Registry::$RegistryPath" -Recurse -Force
            Write-EnhancedLog -Message "Successfully removed registry path: $RegistryPath" -Level 'INFO'
            Write-Output "Successfully removed registry path: $RegistryPath"
        } else {
            Write-EnhancedLog -Message "Registry path not found: $RegistryPath" -Level 'WARNING'
            Write-Output "Registry path not found: $RegistryPath"
        }
    } catch {
        Handle-Error -ErrorRecord $_
    } finally {
        Write-EnhancedLog -Message 'Remove-RegistryPath function completed' -Level 'INFO'
    }
}