       # Function to find the uninstall string from the registry
       function Find-UninstallString {
        param (
            [string[]]$UninstallKeys,
            [string]$ApplicationName
        )

        try {
            foreach ($key in $UninstallKeys) {
                $items = Get-ChildItem -Path $key -ErrorAction SilentlyContinue
                foreach ($item in $items) {
                    $app = Get-ItemProperty -Path $item.PsPath
                    if ($app.DisplayName -like $ApplicationName) {
                        Write-EnhancedLog -Message "Found application: $($app.DisplayName) with product ID: $($app.PSChildName)" -Level 'INFO'
                        return $app.PSChildName.Trim('{}')
                    }
                }
            }
            Write-EnhancedLog -Message "No matching application found for: $ApplicationName" -Level 'WARNING'
        } catch {
            Handle-Error -ErrorRecord $_
        }
        return $null
    }