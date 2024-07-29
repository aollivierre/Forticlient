function Download-PSAppDeployToolkit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GithubRepository,

        [Parameter(Mandatory = $true)]
        [string]$FilenamePatternMatch,

        [Parameter(Mandatory = $true)]
        [string]$ZipExtractionPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Download-PSAppDeployToolkit function" -Level "INFO"
        Log-Params -Params @{
            GithubRepository = $GithubRepository
            FilenamePatternMatch = $FilenamePatternMatch
            ZipExtractionPath = $ZipExtractionPath
        }

        try {
            # Set the URI to get the latest release information from the GitHub repository
            $psadtReleaseUri = "https://api.github.com/repos/$GithubRepository/releases/latest"
            Write-EnhancedLog -Message "GitHub release URI: $psadtReleaseUri" -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "Error in begin block: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    Process {
        try {
            # Get the download URL for the matching filename pattern
            Write-EnhancedLog -Message "Fetching the latest release information from GitHub" -Level "INFO"
            $psadtDownloadUri = (Invoke-RestMethod -Method GET -Uri $psadtReleaseUri).assets | Where-Object { $_.name -like $FilenamePatternMatch } | Select-Object -ExpandProperty browser_download_url
            
            if (-not $psadtDownloadUri) {
                throw "No matching file found for pattern: $FilenamePatternMatch"
            }
            Write-EnhancedLog -Message "Found matching download URL: $psadtDownloadUri" -Level "INFO"
            
            # Set the path for the temporary download location
            $zipTempDownloadPath = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath (Split-Path -Path $psadtDownloadUri -Leaf)
            Write-EnhancedLog -Message "Temporary download path: $zipTempDownloadPath" -Level "INFO"

            # Download the file to the temporary location
            Write-EnhancedLog -Message "Downloading file from $psadtDownloadUri to $zipTempDownloadPath" -Level "INFO"
            Invoke-WebRequest -Uri $psadtDownloadUri -OutFile $zipTempDownloadPath

            # Unblock the downloaded file if necessary
            Write-EnhancedLog -Message "Unblocking file at $zipTempDownloadPath" -Level "INFO"
            Unblock-File -Path $zipTempDownloadPath

            # Extract the contents of the zip file to the specified extraction path
            Write-EnhancedLog -Message "Extracting file from $zipTempDownloadPath to $ZipExtractionPath" -Level "INFO"
            Expand-Archive -Path $zipTempDownloadPath -DestinationPath $ZipExtractionPath -Force
        } catch {
            Write-EnhancedLog -Message "Error in process block: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        try {
            Write-EnhancedLog -Message "File extracted successfully to $ZipExtractionPath" -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "Error in end block: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }

        Write-EnhancedLog -Message "Exiting Download-PSAppDeployToolkit function" -Level "INFO"
    }
}

# Example usage
# Download-PSAppDeployToolkit -GithubRepository 'PSAppDeployToolkit/PSAppDeployToolkit' -FilenamePatternMatch '*.zip' -ZipExtractionPath 'C:\YourPath\Toolkit'
