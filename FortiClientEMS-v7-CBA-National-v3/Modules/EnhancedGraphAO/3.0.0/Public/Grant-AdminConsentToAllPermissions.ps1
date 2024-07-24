# using namespace System.Collections.Generic
# function Grant-AdminConsentToAllPermissions {
#     param(
#         [string]$AppDisplayName
#     )

#     $App = Get-MgApplication -Filter "DisplayName eq '$AppDisplayName'"

#     $sp = Get-MgServicePrincipal -Filter "AppId eq '$($App.AppId)'"

#     # $DBG

#     foreach ($resourceAccess in $App.RequiredResourceAccess) {
#         $resourceSp = Get-MgServicePrincipal -Filter "AppId eq '$($resourceAccess.ResourceAppId)'"
#         if (!$resourceSp) {
#             throw "Please cleanup permissions in the Azure portal for the app '$App.AppId', it contains permissions for removed App."
#         }
#         $scopesIdToValue = @{}
#         $resourceSp.PublishedPermissionScopes | ForEach-Object { $scopesIdToValue[$_.Id] = $_.Value }
#         [HashSet[string]]$requiredScopes = $resourceAccess.ResourceAccess | ForEach-Object { $scopesIdToValue[$_.Id] }
#         $grant = Get-MgOauth2PermissionGrant -Filter "ClientId eq '$($sp.Id)' and ResourceId eq '$($resourceSp.Id)'"
#         $newGrantRequired = $true
#         if ($grant) {
#             [HashSet[string]]$grantedScopes = $grant.Scope.Split(" ")
#             if (!$requiredScopes.IsSubsetOf($grantedScopes)) {
#                 Write-Host "Revoking grant for '$($resourceSp.DisplayName)'"
#                 Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grant.Id
#             }
#             else {
#                 $newGrantRequired = $false
#             }
#         }
#         if ($newGrantRequired) {

#             $consentExpiry = ([datetime]::Now.AddYears(10)) 
#             $scopesToGrant = $requiredScopes -join " "
#             Write-Host "Issuing grant for '$($resourceSp.DisplayName)', scope = $scopesToGrant"
#             New-MgOauth2PermissionGrant -ClientId $sp.Id -ConsentType "AllPrincipals" `
#                 -ResourceId $resourceSp.Id -Scope $scopesToGrant `
#                 -ExpiryTime $consentExpiry | Out-Null
#         }
#     }
# }


# # Grant-AdminConsentToAllPermissions -AppDisplayName 'GraphApp-Test001-20240618142134'