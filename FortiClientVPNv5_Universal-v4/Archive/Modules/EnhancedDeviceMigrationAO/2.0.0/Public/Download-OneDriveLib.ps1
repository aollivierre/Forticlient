function Download-OneDriveLib {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    Begin {
        Write-EnhancedLog -Message "Starting Download-OneDriveLib function" -Level "INFO"
        Log-Params -Params @{
            Destination = $Destination
        }
    }

    Process {
        try {
            # Get the latest release info from GitHub
            $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/rodneyviana/ODSyncService/releases/latest"
            $url = $latestRelease.assets | Where-Object { $_.name -eq "OneDriveLib.dll" } | Select-Object -ExpandProperty browser_download_url

            if (-not $url) {
                throw "No matching file found for OneDriveLib.dll"
            }

            Write-EnhancedLog -Message "Downloading OneDriveLib.dll from: $url" -Level "INFO"
            
            # Download the file
            Invoke-WebRequest -Uri $url -OutFile $Destination
        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the Download-OneDriveLib function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Download-OneDriveLib function" -Level "INFO"
    }
}

# Example usage
# Download-OneDriveLib -Destination 'C:\YourPath\Files\OneDriveLib.dll'
