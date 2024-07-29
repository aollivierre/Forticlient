function Remove-AppListJson {
    param (
        [Parameter(Mandatory = $true)]
        [string]$jsonPath
    )

    # Check if the file exists
    if (Test-Path -Path $jsonPath) {
        try {
            # Remove the file
            Remove-Item -Path $jsonPath -Force
            Write-EnhancedLog -Message "The applist.json file has been removed successfully."
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while removing the file: $_"
            throw $_
        }
    }
    else {
        Write-EnhancedLog -Message "The file at path '$jsonPath' does not exist."
    }
}