function Remove-AppRegistrationsAndDeletedItems {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppDisplayNamePattern
    )

    try {
        Write-EnhancedLog -Message "Starting cleanup process for app registrations with display names like: $AppDisplayNamePattern" -Level "INFO"

        # Retrieve all applications with the specified display name pattern
        $apps = Get-MgApplication -Filter "startswith(DisplayName,'graphapp-test')"

        if ($apps.Count -eq 0) {
            Write-EnhancedLog -Message "No applications found with display names like: $AppDisplayNamePattern" -Level "WARNING"
            return
        }

        Write-EnhancedLog -Message "Applications to be deleted: $($apps.DisplayName -join ', ')" -Level "INFO"

        # Remove each application
        foreach ($app in $apps) {
            Remove-MgApplication -ApplicationId $app.Id -Confirm:$false
            Write-EnhancedLog -Message "Deleted application: $($app.DisplayName) with ID: $($app.Id)" -Level "INFO"
        }

        Write-EnhancedLog -Message "Cleanup process completed successfully." -Level "INFO"
    } catch {
        Write-EnhancedLog -Message "An error occurred during the cleanup process." -Level "ERROR"
        Handle-Error -ErrorRecord $_ 
        throw $_
    }
}

# # Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Remove-AppRegistrationsAndDeletedItems -AppDisplayNamePattern "*graphapp-test*"
