function Clean-ExportsFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    if (Test-Path -Path $FolderPath) {
        # Get all files in the folder
        $files = Get-ChildItem -Path "$FolderPath\*" -Recurse

        # Remove each file and log its name
        foreach ($file in $files) {
            try {
                Remove-Item -Path $file.FullName -Recurse -Force
                Write-EnhancedLog -Message "Deleted file: $($file.FullName)" -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)
            } catch {
                Write-EnhancedLog -Message "Failed to delete file: $($file.FullName) - Error: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            }
        }

        Write-EnhancedLog -Message "Cleaned up existing folder at: $FolderPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)
    } else {
        # Create the folder if it does not exist
        New-Item -ItemType Directory -Path $FolderPath | Out-Null
        Write-EnhancedLog -Message "Created folder at: $FolderPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }
}

# Example usage
# $folderPath = "C:\path\to\exports"
# Clean-ExportsFolder -FolderPath $folderPath -LogFunction Write-EnhancedLog
