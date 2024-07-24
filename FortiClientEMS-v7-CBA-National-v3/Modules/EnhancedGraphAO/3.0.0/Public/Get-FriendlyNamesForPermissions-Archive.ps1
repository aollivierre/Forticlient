#need to the test the following first

# function Get-FriendlyNamesForPermissions {
#     param (
#         [string]$tenantId,
#         [string]$clientId,
#         [string]$clientSecret,
#         [string]$permissionsFile
#     )

#     # Function to get access token
#     function Get-MsGraphAccessToken {
#         param (
#             [string]$tenantId,
#             [string]$clientId,
#             [string]$clientSecret
#         )

#         $body = @{
#             grant_type    = "client_credentials"
#             client_id     = $clientId
#             client_secret = $clientSecret
#             scope         = "https://graph.microsoft.com/.default"
#         }

#         $response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
#         return $response.access_token
#     }

#     # Load permissions from the JSON file
#     if (Test-Path -Path $permissionsFile) {
#         $permissions = Get-Content -Path $permissionsFile | ConvertFrom-Json
#     }
#     else {
#         Write-Error "Permissions file not found: $permissionsFile"
#         throw "Permissions file not found: $permissionsFile"
#     }

#     # Get access token
#     $accessToken = Get-MsGraphAccessToken -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret

#     # Create header for Graph API requests
#     $headers = @{
#         Authorization = "Bearer $accessToken"
#     }

#     # Translate IDs to friendly names
#     foreach ($permission in $permissions) {
#         $id = $permission.Id
#         $url = "https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appRoles/id eq '$id' or oauth2PermissionScopes/id eq '$id'&$select=displayName"
#         $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
#         $friendlyName = $response.value[0].displayName
#         $permission | Add-Member -MemberType NoteProperty -Name FriendlyName -Value $friendlyName
#     }

#     return $permissions
# }

# # Example usage
# $tenantId = "your-tenant-id"
# $clientId = "your-client-id"
# $clientSecret = "your-client-secret"
# $permissionsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "permissions.json"

# $friendlyPermissions = Get-FriendlyNamesForPermissions -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret -permissionsFile $permissionsFilePath
# $friendlyPermissions | Format-Table -AutoSize
