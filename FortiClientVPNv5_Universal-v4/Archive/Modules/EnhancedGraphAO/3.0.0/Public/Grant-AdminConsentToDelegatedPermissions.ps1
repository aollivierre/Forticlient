# function Grant-AdminConsentToDelegatedPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$AppId,
#         [Parameter(Mandatory = $true)]
#         [string]$Permissions,
#         [Parameter(Mandatory = $true)]
#         [string]$AccessToken
#     )

#     try {
#         Write-EnhancedLog -Message "Granting tenant-wide admin consent to API permissions for App ID: $AppId" -Level "INFO"

#         # Retrieve the service principal for Microsoft Graph
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id,displayName,appId,oauth2PermissionScopes

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Service principal for Microsoft Graph not found." -Level "ERROR"
#             throw "Service principal for Microsoft Graph not found"
#         }

#         Write-EnhancedLog -Message "Microsoft Graph service principal retrieved successfully." -Level "INFO"

#         # Retrieve the service principal for the client application
#         $clientServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$AppId'"

#         if ($null -eq $clientServicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for client application retrieved successfully." -Level "INFO"

#         # Grant the delegated permissions to the client enterprise application
#         $body = @{
#             clientId    = $clientServicePrincipal.Id
#             consentType = "AllPrincipals"
#             resourceId  = $graphServicePrincipal.Id
#             scope       = $Permissions
#         }

#         $headers = @{
#             "Authorization" = "Bearer $AccessToken"
#             "Content-Type"  = "application/json"
#         }

#         $response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" -Method POST -Headers $headers -Body ($body | ConvertTo-Json)

#         Write-EnhancedLog -Message "Tenant-wide admin consent granted successfully." -Level "INFO"

#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting tenant-wide admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_
#         throw $_
#     }
# }

# # Example usage
# # $accessToken = "your-access-token"
# # Grant-AdminConsentToDelegatedPermissions -AppId "08216f27-1d3d-4a9f-9406-80f957e7fca6" -Permissions "User.Read.All Group.Read.All" -AccessToken $accessToken
