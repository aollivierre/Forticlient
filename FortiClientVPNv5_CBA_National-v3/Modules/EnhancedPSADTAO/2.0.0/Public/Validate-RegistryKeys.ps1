function Validate-RegistryKeys {
    param (
        [string]$RegistryFilePath
    )

    Write-EnhancedLog -Message "Starting Validate-RegistryKeys function for: $RegistryFilePath" -Level 'INFO'

    try {
        $importedKeys = Get-Content -Path $RegistryFilePath | Where-Object { $_ -match '^\[.*\]$' } | ForEach-Object { $_ -replace '^\[|\]$', '' }
        $importSuccess = $true

        foreach ($key in $importedKeys) {
            if (Test-Path -Path "Registry::$key") {
                Write-EnhancedLog -Message "Validated registry key: $key" -Level 'INFO'
                Write-EnhancedLog "Validated registry key: $key" -Level 'INFO'
            }
            else {
                Write-EnhancedLog -Message "Failed to validate registry key: $key" -Level 'ERROR'
                Write-EnhancedLog "Failed to validate registry key: $key" -Level 'ERROR'
                $importSuccess = $false
            }
        }

        if ($importSuccess) {
            Write-EnhancedLog -Message "Successfully validated all registry keys for: $RegistryFilePath" -Level 'INFO'
        }
        else {
            Write-EnhancedLog -Message "Some registry keys failed to validate for: $RegistryFilePath" -Level 'ERROR'
        }
    }
    catch {
        Handle-Error -ErrorRecord $_
    }
    finally {
        Write-EnhancedLog -Message 'Validate-RegistryKeys function completed' -Level 'INFO'
    }
}
