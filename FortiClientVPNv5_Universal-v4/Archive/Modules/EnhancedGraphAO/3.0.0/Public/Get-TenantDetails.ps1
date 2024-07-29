function Get-TenantDetails {
    try {
        # Retrieve the organization details
        $organization = Get-MgOrganization

        # $DBG

        # Extract the required details
        $tenantName = $organization.DisplayName
        $tenantId = $organization.Id
        $tenantDomain = $organization.VerifiedDomains[2].Name

        # Adjust the tenant domain
        if ($tenantDomain -match '\.mail\.onmicrosoft\.com$') {
            $tenantDomain = $tenantDomain -replace '\.mail\.onmicrosoft\.com$', '.onmicrosoft.com'
        }

        # Output tenant summary
        Write-EnhancedLog -Message "Tenant Name: $tenantName" -Level "INFO" 
        Write-EnhancedLog -Message "Tenant ID: $tenantId" -Level "INFO"
        Write-EnhancedLog -Message "Tenant Domain: $tenantDomain" -Level "INFO"

        # Return the extracted details
        return @{
            TenantName = $tenantName
            TenantId = $tenantId
            TenantDomain = $tenantDomain
        }
    } catch {
        Handle-Error -ErrorRecord $_
        Write-EnhancedLog -Message "Failed to retrieve tenant details" -Level "ERROR"
        # return $null
    }
}


# # Example usage
# $tenantDetails = Get-TenantDetails

# if ($null -ne $tenantDetails) {
#     $tenantName = $tenantDetails.TenantName
#     $tenantId = $tenantDetails.TenantId
#     $tenantDomain = $tenantDetails.TenantDomain

#     # Use the tenant details as needed
#     Write-EnhancedLog -Message "Using Tenant Details outside the function" -Level "INFO"
#     Write-EnhancedLog -Message "Tenant Name: $tenantName" -Level "INFO"
#     Write-EnhancedLog -Message "Tenant ID: $tenantId" -Level "INFO"
#     Write-EnhancedLog -Message "Tenant Domain: $tenantDomain" -Level "INFO"
# } else {
#     Write-EnhancedLog -Message "Tenant details could not be retrieved." -Level "ERROR"
# }
