function Ensure-TargetFolderExists {
    param (
        [string]$TargetFolder
    )
    
    try {
        if (-Not (Test-Path -Path $TargetFolder)) {
            Write-EnhancedLog -Message "Target folder does not exist. Creating folder: $TargetFolder" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
            New-Item -Path $TargetFolder -ItemType Directory -Force
            Write-EnhancedLog -Message "Target folder created: $TargetFolder" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        } else {
            Write-EnhancedLog -Message "Target folder already exists: $TargetFolder" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        }
    } catch {
        Write-EnhancedLog -Message "An error occurred while ensuring the target folder exists: $($_.Exception.Message)" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        Handle-Error -ErrorRecord $_
    }
}
