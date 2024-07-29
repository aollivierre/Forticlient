function Validate-RegistryRemoval {
    param (
        [string]$RegistryPath
    )

    Write-EnhancedLog -Message "Starting Validate-RegistryRemoval function for: $RegistryPath" -Level 'INFO'

    try {
        if (Test-Path -Path "Registry::$RegistryPath") {
            Write-EnhancedLog -Message "Registry path still exists: $RegistryPath" -Level 'ERROR'
            Write-Output "Registry path still exists: $RegistryPath"
        } else {
            Write-EnhancedLog -Message "Registry path successfully removed: $RegistryPath" -Level 'INFO'
            Write-Output "Registry path successfully removed: $RegistryPath"
        }
    } catch {
        Handle-Error -ErrorRecord $_
    } finally {
        Write-EnhancedLog -Message 'Validate-RegistryRemoval function completed' -Level 'INFO'
    }
}