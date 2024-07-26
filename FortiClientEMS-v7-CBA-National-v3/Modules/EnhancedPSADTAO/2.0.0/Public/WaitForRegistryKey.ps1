function WaitForRegistryKey {
    param (
        [string[]]$RegistryPaths,
        [string]$SoftwareName,
        [version]$MinimumVersion,
        [int]$TimeoutSeconds = 120
    )


    Write-EnhancedLog -Message "Starting WaitForRegistryKey function" -Level "INFO"
    Write-EnhancedLog -Message "Checking for $SoftwareName version $MinimumVersion or later" -Level "INFO"

    $elapsedSeconds = 0

    try {
        while ($elapsedSeconds -lt $TimeoutSeconds) {
            foreach ($path in $RegistryPaths) {
                $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

                foreach ($item in $items) {
                    $app = Get-ItemProperty -Path $item.PsPath -ErrorAction SilentlyContinue
                    if ($app.DisplayName -like "*$SoftwareName*") {
                        $installedVersion = New-Object Version $app.DisplayVersion
                        if ($installedVersion -ge $MinimumVersion) {
                            Write-EnhancedLog -Message "Found $SoftwareName version $installedVersion at $item.PsPath" -Level "INFO"
                            return @{
                                IsInstalled = $true
                                Version     = $app.DisplayVersion
                                ProductCode = $app.PSChildName
                            }
                        }
                    }
                }
            }

            Start-Sleep -Seconds 1
            $elapsedSeconds++
        }

        Write-EnhancedLog -Message "Timeout reached. $SoftwareName version $MinimumVersion or later not found." -Level "WARNING"
        return @{ IsInstalled = $false }
    }
    catch {
        Handle-Error -ErrorRecord $_
    }
    finally {
        Write-EnhancedLog -Message "WaitForRegistryKey function completed" -Level "INFO"
    }
}
