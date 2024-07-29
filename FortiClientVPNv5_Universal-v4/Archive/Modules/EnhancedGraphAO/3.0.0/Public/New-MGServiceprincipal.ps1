function Create-AndVerifyServicePrincipal {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClientId
    )

    try {
        Write-EnhancedLog -Message "Creating a new service principal for the application with Client ID: $ClientId" -Level "INFO"

        # Create a new service principal for the application
        New-MgServicePrincipal -AppId $ClientId

        Write-EnhancedLog -Message "Service principal created successfully." -Level "INFO"

        # Verify the creation
        $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$ClientId'"

        if ($null -eq $servicePrincipal) {
            Write-EnhancedLog -Message "Service principal not found after creation." -Level "ERROR"
            throw "Service principal not found after creation"
        }

        Write-EnhancedLog -Message "Service principal verified successfully." -Level "INFO"

        # Display the service principal details
        $servicePrincipal | Format-Table DisplayName, AppId, Id

        return $servicePrincipal

    } catch {
        Write-EnhancedLog -Message "An error occurred while creating or verifying the service principal." -Level "ERROR"
        Handle-Error -ErrorRecord $_
        throw $_
    }
}

# Example usage
# Create-AndVerifyServicePrincipal -ClientId "your-application-id"
