function Upload-FileToSharePoint {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DocumentDriveId,

        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$FolderName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    try {
        # Validate file existence before upload
        Validate-FileExists -FilePath $FilePath

        # Read the file content
        $content = Get-Content -Path $FilePath -Raw
        $filename = (Get-Item -Path $FilePath).Name

        # Construct the PUT URL
        $putUrl = "https://graph.microsoft.com/v1.0/drives/$DocumentDriveId/root:/$FolderName/$($filename):/content"

        # Upload the file
        Write-EnhancedLog -Message "Uploading file '$filename' to folder '$FolderName'..." -Level "INFO"
        $uploadResponse = Invoke-RestMethod -Headers $Headers -Uri $putUrl -Body $content -Method PUT
        Write-EnhancedLog -Message "File '$filename' uploaded successfully." -Level "INFO"

        # Validate file existence after upload
        Validate-FileUpload -DocumentDriveId $DocumentDriveId -FolderName $FolderName -FileName $filename -Headers $Headers

        return $uploadResponse
    }
    catch {
        Write-EnhancedLog -Message "Failed to upload file '$filename' to folder '$FolderName': $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw $_
    }
}
