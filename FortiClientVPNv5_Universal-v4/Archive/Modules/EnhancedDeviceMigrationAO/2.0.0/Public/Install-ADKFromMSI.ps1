function Install-ADKFromMSI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OfflinePath,

        [Parameter(Mandatory = $true)]
        [string]$ICDPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86\ICD.exe"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Install-ADKFromMSI function" -Level "INFO"
        Log-Params -Params @{
            OfflinePath = $OfflinePath
            ICDPath = $ICDPath
        }

        # Ensure offline path exists
        if (-not (Test-Path -Path $OfflinePath)) {
            throw "Offline path not found: $OfflinePath"
        }
    }

    Process {
        try {
            # Get all MSI files in the offline path
            $MSIFiles = Get-ChildItem -Path $OfflinePath -Filter *.msi

            if (-not $MSIFiles) {
                throw "No MSI files found in: $OfflinePath"
            }

            # Install each MSI file
            foreach ($MSI in $MSIFiles) {
                Write-EnhancedLog -Message "Installing MSI: $($MSI.FullName)" -Level "INFO"
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($MSI.FullName)`" /quiet /norestart" -Wait -NoNewWindow
            }

            # Check if ICD.exe exists
            if (Test-Path -Path $ICDPath) {
                Write-EnhancedLog -Message "ICD.exe found at: $ICDPath" -Level "INFO"
            } else {
                throw "ICD.exe not found at: $ICDPath"
            }

        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the Install-ADKFromMSI function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Install-ADKFromMSI function" -Level "INFO"
    }
}

# # Example usage
# $installParams = @{
#     OfflinePath = "$env:TEMP\ADKOffline\Installers"
#     ICDPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86\ICD.exe"
# }

# Install-ADKFromMSI @installParams
