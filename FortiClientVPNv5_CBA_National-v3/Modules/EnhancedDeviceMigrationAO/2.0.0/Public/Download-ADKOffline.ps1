function Download-ADKOffline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ADKUrl = "https://go.microsoft.com/fwlink/?linkid=2271337",

        [Parameter(Mandatory = $true)]
        [string]$DownloadPath = "$env:TEMP\adksetup.exe",

        [Parameter(Mandatory = $true)]
        [string]$OfflinePath = "$env:TEMP\ADKOffline"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Download-ADKOffline function" -Level "INFO"
        Log-Params -Params @{
            ADKUrl = $ADKUrl
            DownloadPath = $DownloadPath
            OfflinePath = $OfflinePath
        }
    }

    Process {
        try {
            # Download the ADK setup file
            Write-EnhancedLog -Message "Downloading ADK from: $ADKUrl to: $DownloadPath" -Level "INFO"
            Invoke-WebRequest -Uri $ADKUrl -OutFile $DownloadPath

            # Create offline path if it does not exist
            if (-not (Test-Path -Path $OfflinePath)) {
                New-Item -ItemType Directory -Path $OfflinePath -Force
            }

            # Download the ADK components for offline installation
            Write-EnhancedLog -Message "Downloading ADK components for offline installation to: $OfflinePath" -Level "INFO"
            Start-Process -FilePath $DownloadPath -ArgumentList "/quiet", "/layout $OfflinePath" -Wait -NoNewWindow
        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the Download-ADKOffline function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Download-ADKOffline function" -Level "INFO"
    }
}

# Example usage
# $adkParams = @{
#     ADKUrl = 'https://go.microsoft.com/fwlink/?linkid=2271337'
#     DownloadPath = "$env:TEMP\adksetup.exe"
#     OfflinePath = "$env:TEMP\ADKOffline"
# }

# Download-ADKOffline @adkParams
