function New-SharePointFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DocumentDriveId,

        [Parameter(Mandatory = $true)]
        [string]$ParentFolderPath,

        [Parameter(Mandatory = $true)]
        [string]$FolderName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    try {
        # Check if the folder already exists
        $checkUrl = "https://graph.microsoft.com/v1.0/drives/" + $DocumentDriveId + "/root:/" + $ParentFolderPath + ":/children"
        $existingFolders = Invoke-RestMethod -Headers $Headers -Uri $checkUrl -Method GET
        $existingFolder = $existingFolders.value | Where-Object { $_.name -eq $FolderName -and $_.folder }

        if ($existingFolder) {
            Write-EnhancedLog -Message "Folder '$FolderName' already exists in '$ParentFolderPath'. Skipping folder creation." -Level "INFO"
            return $existingFolder
        }
    }
    catch {
        Write-EnhancedLog -Message "Folder '$FolderName' not found in '$ParentFolderPath'. Proceeding with folder creation." -Level "INFO"
    }

    try {
        # If the folder does not exist, create it
        $url = "https://graph.microsoft.com/v1.0/drives/" + $DocumentDriveId + "/root:/" + $ParentFolderPath + ":/children"
        $body = @{
            "@microsoft.graph.conflictBehavior" = "fail"
            "name"                              = $FolderName
            "folder"                            = @{}
        }

        Write-EnhancedLog -Message "Creating folder '$FolderName' in '$ParentFolderPath'..." -Level "INFO"
        $createdFolder = Invoke-RestMethod -Headers $Headers -Uri $url -Body ($body | ConvertTo-Json) -Method POST
        Write-EnhancedLog -Message "Folder created successfully." -Level "INFO"
        return $createdFolder
    }
    catch {
        Write-EnhancedLog -Message "Failed to create folder '$FolderName' in '$ParentFolderPath': $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw $_
    }
}

# # Example usage
# $headers = @{
#     "Authorization" = "Bearer YOUR_ACCESS_TOKEN"
#     "Content-Type"  = "application/json"
# }

# $documentDriveId = "your_document_drive_id"
# $parentFolderPath = "your/parent/folder/path"
# $folderName = "NewFolder"

# New-SharePointFolder -DocumentDriveId $documentDriveId -ParentFolderPath $parentFolderPath -FolderName $folderName -Headers $headers