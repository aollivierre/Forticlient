# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         # [string]$AppId,
#         [string]$clientId
#     )

#     try {



#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         # $DBG


#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve and list all service principals for debugging
#         # $allServicePrincipals = Get-MgServicePrincipal
#         # Write-Output "All Service Principals:"
#         # $allServicePrincipals | Format-Table DisplayName, AppId, Id

#         # Retrieve the service principal for the application
#         # $servicePrincipal = $allServicePrincipals | Where-Object { $_.AppId -eq $clientId }

#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         # $DBG

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Retrieve all API permissions (OAuth2PermissionGrants) for the service principal
#         $apiPermissions = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $servicePrincipalId

#         # $DBG

#         Write-EnhancedLog -Message "API permissions retrieved successfully." -Level "INFO"

#         # Grant admin consent to each permission
#         foreach ($permission in $apiPermissions) {
#             Update-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $servicePrincipalId -Id $permission.Id -ConsentType "AllPrincipals"
#         }

#         Write-EnhancedLog -Message "Admin consent granted to all API permissions." -Level "INFO"
#     }
#     catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }








# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Retrieve all API permissions (OAuth2PermissionGrants) for the service principal
#         $apiPermissions = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $servicePrincipalId

#         Write-EnhancedLog -Message "API permissions retrieved: $($apiPermissions.Count)" -Level "INFO"

#         if ($apiPermissions.Count -eq 0) {
#             Write-EnhancedLog -Message "No API permissions found for the service principal with ID: $servicePrincipalId" -Level "WARNING"
#         }

#         # Grant admin consent to each permission
#         foreach ($permission in $apiPermissions) {
#             Write-EnhancedLog -Message "Granting admin consent for permission ID: $($permission.Id) with scope: $($permission.Scope)" -Level "INFO"
#             Update-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $servicePrincipalId -Id $permission.Id -ConsentType "AllPrincipals"
#             Write-EnhancedLog -Message "Admin consent granted for permission ID: $($permission.Id) with scope: $($permission.Scope)" -Level "INFO"
#         }

        
#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# Example usage
# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"


# Example usage
# Grant-AdminConsentToApiPermissions -AppId "65a3ee49-f480-4cde-9d55-a4a952084bf7"













# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId,
#         $headers
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Define the permissions to be granted
#         $permissions = "User.Read.All Group.Read.All"  # Replace with the required permissions

#         # Retrieve the Microsoft Graph service principal
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
#             throw "Microsoft Graph service principal not found"
#         }

#         $resourceId = $graphServicePrincipal.Id

#         # Grant the permissions
#         $body = @{
#             clientId    = $servicePrincipalId
#             consentType = "AllPrincipals"
#             resourceId  = $resourceId
#             scope       = $permissions
#         }

#         # $headers = @{
#         #     "Authorization" = "Bearer $AccessToken"
#         #     "Content-Type"  = "application/json"
#         # }

#         $response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" -Method POST -Headers $headers -Body ($body | ConvertTo-Json)

#         Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# Example usage
# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"




# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Define the permissions to be granted
#         $permissions = "User.Read.All Group.Read.All"  # Replace with the required permissions

#         # Retrieve the Microsoft Graph service principal
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
#             throw "Microsoft Graph service principal not found"
#         }

#         $resourceId = $graphServicePrincipal.Id

#         # Grant the permissions
#         $body = @{
#             clientId    = $servicePrincipalId
#             consentType = "AllPrincipals"
#             resourceId  = $resourceId
#             scope       = $permissions
#         }

#         $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

#         $DBG

#         Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# # Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"




# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Define the permissions to be granted (application permissions)
#         $permissions = @("Directory.Read.All", "Directory.ReadWrite.All")  # Replace with the required permissions

#         # Retrieve the Microsoft Graph service principal
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id,appRoles

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
#             throw "Microsoft Graph service principal not found"
#         }

#         $resourceId = $graphServicePrincipal.Id
#         $appRoles = $graphServicePrincipal.AppRoles

#         # Find the IDs of the required permissions
#         $requiredRoles = $appRoles | Where-Object { $permissions -contains $_.Value } | Select-Object -ExpandProperty Id

#         if ($requiredRoles.Count -eq 0) {
#             Write-EnhancedLog -Message "No matching app roles found for the specified permissions." -Level "ERROR"
#             throw "No matching app roles found"
#         }

#         Write-EnhancedLog -Message "App roles to be granted: $($requiredRoles -join ', ')" -Level "INFO"

#         # Grant the app roles (application permissions)
#         foreach ($roleId in $requiredRoles) {
#             $body = @{
#                 principalId = $servicePrincipalId
#                 resourceId  = $resourceId
#                 appRoleId   = $roleId
#             }

#             $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$resourceId/appRoleAssignedTo" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

            

#             Write-EnhancedLog -Message "Granted app role with ID: $roleId" -Level "INFO"
#         }

#         $DBG

#         Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_
#         throw $_
#     }
# }

# Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"







# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId,
#         [Parameter(Mandatory = $true)]
#         [string]$SPPermissionsPath
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Load permissions from JSON file
#         $permissionsFile = Join-Path -Path $SPPermissionsPath -ChildPath "SPPermissions.json"
#         if (-not (Test-Path -Path $permissionsFile)) {
#             Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
#             throw "Permissions file not found"
#         }

#         $permissionsJson = Get-Content -Path $permissionsFile -Raw | ConvertFrom-Json
#         $permissions = $permissionsJson.permissions | Where-Object { $_.granted -eq $true } | Select-Object -ExpandProperty name

#         Write-EnhancedLog -Message "Permissions to be granted: $($permissions -join ', ')" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Retrieve the Microsoft Graph service principal
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id,appRoles

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
#             throw "Microsoft Graph service principal not found"
#         }

#         $resourceId = $graphServicePrincipal.Id
#         $appRoles = $graphServicePrincipal.AppRoles

#         # Find the IDs of the required permissions
#         $requiredRoles = $appRoles | Where-Object { $permissions -contains $_.Value } | Select-Object -ExpandProperty Id

#         if ($requiredRoles.Count -eq 0) {
#             Write-EnhancedLog -Message "No matching app roles found for the specified permissions." -Level "ERROR"
#             throw "No matching app roles found"
#         }

#         Write-EnhancedLog -Message "App roles to be granted: $($requiredRoles -join ', ')" -Level "INFO"

#         # Ensure the access token has the necessary scopes
#         $context = Get-MgContext -ErrorAction Stop
#         $token = $context.AuthContext.AccessToken
#         $decodedToken = $token | ConvertFrom-Json -ErrorAction Stop
#         $tokenScopes = $decodedToken.scp.Split(' ')

#         if (-not $tokenScopes -contains "AppRoleAssignment.ReadWrite.All") {
#             Write-EnhancedLog -Message "Access token does not contain the necessary scope: AppRoleAssignment.ReadWrite.All" -Level "ERROR"
#             throw "Insufficient privileges"
#         }

#         # $DBG

#         # Grant the app roles (application permissions)
#         foreach ($roleId in $requiredRoles) {
#             $body = @{
#                 principalId = $servicePrincipalId
#                 resourceId  = $resourceId
#                 appRoleId   = $roleId
#             }

#             $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$resourceId/appRoleAssignedTo" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

#             Write-EnhancedLog -Message "Granted app role with ID: $roleId" -Level "INFO"
#         }

#         Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All", "AppRoleAssignment.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"







# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Load permissions from JSON file
#         $permissionsFile = Join-Path -Path $SPPermissionsPath -ChildPath "SPPermissions.json"
#         if (-not (Test-Path -Path $permissionsFile)) {
#             Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
#             throw "Permissions file not found"
#         }

#         $permissionsJson = Get-Content -Path $permissionsFile -Raw | ConvertFrom-Json
#         $permissions = $permissionsJson.permissions | Where-Object { $_.granted -eq $true } | Select-Object -ExpandProperty name

#         Write-EnhancedLog -Message "Permissions to be granted: $($permissions -join ', ')" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Retrieve the Microsoft Graph service principal
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id,appRoles

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
#             throw "Microsoft Graph service principal not found"
#         }

#         $resourceId = $graphServicePrincipal.Id
#         $appRoles = $graphServicePrincipal.AppRoles

#         # Find the IDs of the required permissions
#         $requiredRoles = $appRoles | Where-Object { $permissions -contains $_.Value } | Select-Object -ExpandProperty Id

#         if ($requiredRoles.Count -eq 0) {
#             Write-EnhancedLog -Message "No matching app roles found for the specified permissions." -Level "ERROR"
#             throw "No matching app roles found"
#         }

#         Write-EnhancedLog -Message "App roles to be granted: $($requiredRoles -join ', ')" -Level "INFO"

#         # # Ensure the access token has the necessary scopes
#         # $context = Get-MgContext -ErrorAction Stop
#         # if ($null -eq $context) {
#         #     Write-EnhancedLog -Message "Microsoft Graph context is null." -Level "ERROR"
#         #     throw "Microsoft Graph context is null"
#         # }

#         # $token = $context.AuthContext.AccessToken
#         # if ($null -eq $token) {
#         #     Write-EnhancedLog -Message "Access token is null." -Level "ERROR"
#         #     throw "Access token is null"
#         # }

#         # $decodedToken = $token | ConvertFrom-Json -ErrorAction Stop
#         # $tokenScopes = $decodedToken.scp.Split(' ')

#         # if (-not $tokenScopes -contains "AppRoleAssignment.ReadWrite.All") {
#         #     Write-EnhancedLog -Message "Access token does not contain the necessary scope: AppRoleAssignment.ReadWrite.All" -Level "ERROR"
#         #     throw "Insufficient privileges"
#         # }

#         # Grant the app roles (application permissions)
#         foreach ($roleId in $requiredRoles) {
#             $body = @{
#                 principalId = $servicePrincipalId
#                 resourceId  = $resourceId
#                 appRoleId   = $roleId
#             }

#             $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$resourceId/appRoleAssignedTo" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

#             Write-EnhancedLog -Message "Granted app role with ID: $roleId" -Level "INFO"
#         }

#         Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# # Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All", "AppRoleAssignment.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"








# function Grant-AdminConsentToApiPermissions {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$clientId,
#         $SPPermissionsPath
#     )

#     try {
#         Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Load permissions from JSON file
#         $permissionsFile = Join-Path -Path $SPPermissionsPath -ChildPath "SPPermissions.json"
#         if (-not (Test-Path -Path $permissionsFile)) {
#             Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
#             throw "Permissions file not found"
#         }

#         $permissionsJson = Get-Content -Path $permissionsFile -Raw | ConvertFrom-Json
#         $permissions = $permissionsJson.permissions | Where-Object { $_.granted -eq $true } | Select-Object -ExpandProperty name

#         Write-EnhancedLog -Message "Permissions to be granted: $($permissions -join ', ')" -Level "INFO"

#         # Create and verify the service principal
#         Create-AndVerifyServicePrincipal -ClientId $clientId

#         Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

#         # Retrieve the service principal for the application
#         $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

#         if ($null -eq $servicePrincipal) {
#             Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
#             throw "Service principal not found"
#         }

#         Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

#         # Retrieve the service principal ID
#         $servicePrincipalId = $servicePrincipal.Id

#         # Retrieve the Microsoft Graph service principal
#         $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id,appRoles

#         if ($null -eq $graphServicePrincipal) {
#             Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
#             throw "Microsoft Graph service principal not found"
#         }

#         $resourceId = $graphServicePrincipal.Id
#         $appRoles = $graphServicePrincipal.AppRoles

#         # Find the IDs of the required permissions
#         $requiredRoles = $appRoles | Where-Object { $permissions -contains $_.Value } | Select-Object -ExpandProperty Id

#         if ($requiredRoles.Count -eq 0) {
#             Write-EnhancedLog -Message "No matching app roles found for the specified permissions." -Level "ERROR"
#             throw "No matching app roles found"
#         }

#         Write-EnhancedLog -Message "App roles to be granted: $($requiredRoles -join ', ')" -Level "INFO"

#         # Grant the app roles (application permissions)
#         foreach ($roleId in $requiredRoles) {
#             $body = @{
#                 principalId = $servicePrincipalId
#                 resourceId  = $resourceId
#                 appRoleId   = $roleId
#             }

#             $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$resourceId/appRoleAssignedTo" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

#             Write-EnhancedLog -Message "Granted app role with ID: $roleId" -Level "INFO"
#         }

#         # $DBG

#         Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
#         return $response

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# # Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All", "AppRoleAssignment.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"










function Grant-AdminConsentToApiPermissions {
    param (
        [Parameter(Mandatory = $true)]
        [string]$clientId,

        [Parameter(Mandatory = $true)]
        [string]$SPPermissionsPath
    )

    try {
        Write-EnhancedLog -Message "Starting the process to grant admin consent to API permissions for App ID: $clientId" -Level "INFO"

        # Load permissions from JSON file
        $permissionsFile = Join-Path -Path $SPPermissionsPath -ChildPath "SPPermissions.json"
        if (-not (Test-Path -Path $permissionsFile)) {
            Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
            throw "Permissions file not found"
        }

        $permissionsJson = Get-Content -Path $permissionsFile -Raw | ConvertFrom-Json
        $permissions = $permissionsJson.permissions | Where-Object { $_.granted -eq $true } | Select-Object -ExpandProperty name

        Write-EnhancedLog -Message "Permissions to be granted: $($permissions -join ', ')" -Level "INFO"

        # Create and verify the service principal
        Create-AndVerifyServicePrincipal -ClientId $clientId

        Write-EnhancedLog -Message "Granting admin consent to API permissions for App ID: $clientId" -Level "INFO"

        # Retrieve the service principal for the application
        $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$clientId'"

        if ($null -eq $servicePrincipal) {
            Write-EnhancedLog -Message "Service principal not found for the specified application ID." -Level "ERROR"
            throw "Service principal not found"
        }

        Write-EnhancedLog -Message "Service principal for app ID: $clientId retrieved successfully." -Level "INFO"

        # Retrieve the service principal ID
        $servicePrincipalId = $servicePrincipal.Id

        # Retrieve the Microsoft Graph service principal
        $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Select id,appRoles

        if ($null -eq $graphServicePrincipal) {
            Write-EnhancedLog -Message "Microsoft Graph service principal not found." -Level "ERROR"
            throw "Microsoft Graph service principal not found"
        }

        $resourceId = $graphServicePrincipal.Id
        $appRoles = $graphServicePrincipal.AppRoles

        # Find the IDs of the required permissions
        $requiredRoles = $appRoles | Where-Object { $permissions -contains $_.Value } | Select-Object Id, Value

        if ($requiredRoles.Count -eq 0) {
            Write-EnhancedLog -Message "No matching app roles found for the specified permissions." -Level "ERROR"
            throw "No matching app roles found"
        }

        Write-EnhancedLog -Message "App roles to be granted: $($requiredRoles.Value -join ', ')" -Level "INFO"

        # Grant the app roles (application permissions)
        foreach ($role in $requiredRoles) {
            $body = @{
                principalId = $servicePrincipalId
                resourceId  = $resourceId
                appRoleId   = $role.Id
            }

            $response = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$resourceId/appRoleAssignedTo" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

            Write-EnhancedLog -Message "Granted app role: $($role.Value) with ID: $($role.Id)" -Level "INFO"
        }
        # $DBG

        Write-EnhancedLog -Message "Admin consent granted successfully." -Level "INFO"
        return $response

    } catch {
        Write-EnhancedLog -Message "An error occurred while granting admin consent." -Level "ERROR"
        Handle-Error -ErrorRecord $_ 
        throw $_
    }
}

# # Example usage
# $scopes = @("Application.ReadWrite.All", "Directory.ReadWrite.All", "AppRoleAssignment.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# Grant-AdminConsentToApiPermissions -ClientId "your-application-id"








