function Set-RegistryValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RegKeyPath,
        [Parameter(Mandatory = $true)]
        [string]$RegValueName,
        [Parameter(Mandatory = $true)]
        [string]$RegValType,
        [Parameter(Mandatory = $true)]
        [string]$RegValData
    )

    Begin {
        Write-EnhancedLog -Message "Starting Set-RegistryValue function" -Level "INFO"
        Log-Params -Params @{
            RegKeyPath = $RegKeyPath
            RegValueName = $RegValueName
            RegValType = $RegValType
            RegValData = $RegValData
        }
    }

    Process {
        try {
            # Check if registry key exists, create if it does not
            if (-not (Test-Path -Path $RegKeyPath)) {
                Write-EnhancedLog -Message "Registry key path does not exist, creating: $RegKeyPath" -Level "INFO"
                New-Item -Path $RegKeyPath -Force | Out-Null
            } else {
                Write-EnhancedLog -Message "Registry key path exists: $RegKeyPath" -Level "INFO"
            }

            # Check if registry value exists and its current value
            $currentValue = $null
            try {
                $currentValue = Get-ItemPropertyValue -Path $RegKeyPath -Name $RegValueName
            } catch {
                Write-EnhancedLog -Message "Registry value not found, setting new value: $RegValueName" -Level "INFO"
                New-ItemProperty -Path $RegKeyPath -Name $RegValueName -PropertyType $RegValType -Value $RegValData -Force
            }

            # If value exists but data is incorrect, update the value
            if ($currentValue -ne $RegValData) {
                Write-EnhancedLog -Message "Updating registry value: $RegValueName with new data: $RegValData" -Level "INFO"
                Set-ItemProperty -Path $RegKeyPath -Name $RegValueName -Value $RegValData -Force
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the Set-RegistryValue function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Set-RegistryValue function" -Level "INFO"
    }
}


# Example usage
# Set-RegistryValue -RegKeyPath "HKCU:\Software\MyApp" -RegValueName "MyValue" -RegValType "String" -RegValData "MyData"
