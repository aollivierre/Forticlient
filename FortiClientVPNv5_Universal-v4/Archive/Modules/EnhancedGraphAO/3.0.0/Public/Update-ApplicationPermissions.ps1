# function Update-ApplicationPermissions {
#     param (
#         [string]$appId,
#         [string]$permissionsFile
#     )

#     $resourceAppId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph

#     # Load permissions from the JSON file
#     if (Test-Path -Path $permissionsFile) {
#         $permissions = Get-Content -Path $permissionsFile | ConvertFrom-Json
#     }
#     else {
#         Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
#         throw "Permissions file not found: $permissionsFile"
#     }

#     # Retrieve the existing application (optional, uncomment if needed)
#     # $app = Get-MgApplication -ApplicationId $appId

#     # Prepare the required resource access
#     $requiredResourceAccess = @(
#         @{
#             ResourceAppId = $resourceAppId
#             ResourceAccess = $permissions
#         }
#     )

#     # Update the application
#     try {
#         Update-MgApplication -ApplicationId $appId -RequiredResourceAccess $requiredResourceAccess
#         Write-EnhancedLog -Message "Successfully updated application permissions for appId: $appId" -Level "INFO"
#     }
#     catch {
#         Write-EnhancedLog -Message "Failed to update application permissions for appId: $appId. Error: $_" -Level "ERROR"
#         throw $_
#     }
# }



# function Update-ApplicationPermissions {
#     param (
#         [string]$appId,
#         [string]$permissionsFile
#     )

#     $resourceAppId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph

#     # Load permissions from the JSON file
#     if (Test-Path -Path $permissionsFile) {
#         $permissions = Get-Content -Path $permissionsFile | ConvertFrom-Json
#     }
#     else {
#         Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
#         throw "Permissions file not found: $permissionsFile"
#     }

#     # Convert permissions to the required type
#     $resourceAccess = @()
#     foreach ($permission in $permissions) {
#         $resourceAccess += [Microsoft.Graph.PowerShell.Models.IMicrosoftGraphResourceAccess]@{
#             Id = [Guid]$permission.Id
#             Type = $permission.Type
#         }
#     }

#     # Prepare the required resource access
#     $requiredResourceAccess = @(
#         [Microsoft.Graph.PowerShell.Models.IMicrosoftGraphRequiredResourceAccess]@{
#             ResourceAppId = [Guid]$resourceAppId
#             ResourceAccess = $resourceAccess
#         }
#     )

#     # Update the application
#     try {
#         Update-MgApplication -ApplicationId $appId -RequiredResourceAccess $requiredResourceAccess
#         Write-EnhancedLog -Message "Successfully updated application permissions for appId: $appId" -Level "INFO"
#     }
#     catch {
#         Write-EnhancedLog -Message "Failed to update application permissions for appId: $appId. Error: $_" -Level "ERROR"
#         throw $_
#         Handle-Error -ErrorRecord $_
#     }
# }


# function Update-ApplicationPermissions {
#     param (
#         [string]$appId,
#         [string]$permissionsFile
#     )

#     $resourceAppId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph

#     # Load permissions from the JSON file
#     if (Test-Path -Path $permissionsFile) {
#         $permissions = Get-Content -Path $permissionsFile | ConvertFrom-Json
#     }
#     else {
#         Write-EnhancedLog -Message "Permissions file not found: $permissionsFile" -Level "ERROR"
#         throw "Permissions file not found: $permissionsFile"
#     }

#     # Convert permissions to the required type
#     $resourceAccess = @()
#     foreach ($permission in $permissions) {
#         if ($null -eq $permission.Id) {
#             Write-EnhancedLog -Message "Permission Id is null. Skipping this entry." -Level "WARNING"
#             continue
#         }

#         try {
#             $resourceAccess += [Microsoft.Graph.PowerShell.Models.IMicrosoftGraphResourceAccess]@{
#                 Id = [Guid]$permission.Id
#                 Type = $permission.Type
#             }
#         }
#         catch {
#             Write-EnhancedLog -Message "Failed to convert permission Id: $($permission.Id). Error: $_" -Level "ERROR"
#             throw $_
#         }
#     }

#     if ($resourceAccess.Count -eq 0) {
#         Write-EnhancedLog -Message "No valid permissions found to update the application." -Level "ERROR"
#         throw "No valid permissions found to update the application."
#     }

#     # Prepare the required resource access
#     $requiredResourceAccess = @(
#         [Microsoft.Graph.PowerShell.Models.IMicrosoftGraphRequiredResourceAccess]@{
#             ResourceAppId = [Guid]$resourceAppId
#             ResourceAccess = $resourceAccess
#         }
#     )

#     # Update the application
#     try {
#         Update-MgApplication -ApplicationId $appId -RequiredResourceAccess $requiredResourceAccess
#         Write-EnhancedLog -Message "Successfully updated application permissions for appId: $appId" -Level "INFO"
#     }
#     catch {
#         Write-EnhancedLog -Message "Failed to update application permissions for appId: $appId. Error: $_" -Level "ERROR"
#         throw $_
#         Handle-Error -ErrorRecord $_
#     }
# }
