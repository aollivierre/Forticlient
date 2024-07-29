function Download-PsExec {
    [CmdletBinding()]
    param(
        [string]$TargetFolder
    )

    Begin {
        # Ensure the target folder exists
        Ensure-TargetFolderExists -TargetFolder $TargetFolder
        Write-EnhancedLog -Message "Removing existing PsExec from target folder: $TargetFolder" -Level "INFO"

        Remove-ExistingPsExec -TargetFolder $TargetFolder
    }

    Process {
        try {
            

            # Define the URL for PsExec download
            $url = "https://download.sysinternals.com/files/PSTools.zip"
            # Full path for the downloaded file
            $zipPath = Join-Path -Path $TargetFolder -ChildPath "PSTools.zip"

            # Download the PSTools.zip file containing PsExec
            Write-EnhancedLog -Message "Downloading PSTools.zip from: $url to: $zipPath" -Level "INFO"
            Invoke-WebRequest -Uri $url -OutFile $zipPath

            # Extract PsExec64.exe from the zip file
            Write-EnhancedLog -Message "Extracting PSTools.zip to: $TargetFolder\PStools" -Level "INFO"
            Expand-Archive -Path $zipPath -DestinationPath "$TargetFolder\PStools" -Force

            # Specific extraction of PsExec64.exe
            $extractedFolderPath = Join-Path -Path $TargetFolder -ChildPath "PSTools"
            $PsExec64Path = Join-Path -Path $extractedFolderPath -ChildPath "PsExec64.exe"
            $finalPath = Join-Path -Path $TargetFolder -ChildPath "PsExec64.exe"

            # Move PsExec64.exe to the desired location
            if (Test-Path -Path $PsExec64Path) {
                Write-EnhancedLog -Message "Moving PsExec64.exe from: $PsExec64Path to: $finalPath" -Level "INFO"
                Move-Item -Path $PsExec64Path -Destination $finalPath

                # Remove the downloaded zip file and extracted folder
                Write-EnhancedLog -Message "Removing downloaded zip file and extracted folder" -Level "INFO"
                Remove-Item -Path $zipPath -Force
                Remove-Item -Path $extractedFolderPath -Recurse -Force

                Write-EnhancedLog -Message "PsExec64.exe has been successfully downloaded and moved to: $finalPath" -Level "INFO"
            } else {
                Write-EnhancedLog -Message "PsExec64.exe not found in the extracted files." -Level "ERROR"
            }
        } catch {
            # Handle any errors during the process
            Write-EnhancedLog -Message "An error occurred during the download or extraction process: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }
}
