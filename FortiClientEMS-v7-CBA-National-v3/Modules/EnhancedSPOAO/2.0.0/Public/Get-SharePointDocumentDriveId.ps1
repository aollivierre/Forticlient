function Get-SharePointDocumentDriveId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteObjectId,

        [Parameter(Mandatory = $true)]
        [string]$DocumentDriveName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    try {
        # Get the subsite ID
        $url = "https://graph.microsoft.com/v1.0/groups/$SiteObjectId/sites/root"
        $subsiteID = (Invoke-RestMethod -Headers $Headers -Uri $url -Method GET).id
        Write-EnhancedLog -Message "Retrieved subsite ID: $subsiteID" -Level "INFO"

        # Get the drives
        $url = "https://graph.microsoft.com/v1.0/sites/$subsiteID/drives"
        $drives = Invoke-RestMethod -Headers $Headers -Uri $url -Method GET
        Write-EnhancedLog -Message "Retrieved drives for subsite ID: $subsiteID" -Level "INFO"

        # Find the document drive ID
        $documentDriveId = ($drives.value | Where-Object { $_.name -eq $DocumentDriveName }).id

        if ($documentDriveId) {
            Write-EnhancedLog -Message "Found document drive ID: $documentDriveId" -Level "INFO"
            return $documentDriveId
        } else {
            Write-EnhancedLog -Message "Document drive '$DocumentDriveName' not found." -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            throw "Document drive '$DocumentDriveName' not found."
        }
    }
    catch {
        Write-EnhancedLog -Message "Failed to get document drive ID: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw $_
    }
}


# # Example usage
# $headers = @{
#     "Authorization" = "Bearer YOUR_ACCESS_TOKEN"
#     "Content-Type"  = "application/json"
# }

# $siteObjectId = "your_site_object_id"
# $documentDriveName = "Documents"

# Get-SharePointDocumentDriveId -SiteObjectId $siteObjectId -DocumentDriveName $documentDriveName -Headers $headers