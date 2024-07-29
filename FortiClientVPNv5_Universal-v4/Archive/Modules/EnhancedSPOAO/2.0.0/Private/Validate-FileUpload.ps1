function Validate-FileUpload {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DocumentDriveId,

        [Parameter(Mandatory = $true)]
        [string]$FolderName,

        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    $url = "https://graph.microsoft.com/v1.0/drives/$DocumentDriveId/root:/$FolderName/$FileName"
    try {
        $response = Invoke-RestMethod -Headers $Headers -Uri $url -Method GET
        if ($response) {
            Write-EnhancedLog -Message "File '$FileName' exists in '$FolderName' after upload." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        } else {
            Write-EnhancedLog -Message "File '$FileName' does not exist in '$FolderName' after upload." -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            throw "File '$FileName' does not exist in '$FolderName' after upload."
        }
    }
    catch {
        Write-EnhancedLog -Message "Failed to validate file '$FileName' in '$FolderName': $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw $_
    }
}