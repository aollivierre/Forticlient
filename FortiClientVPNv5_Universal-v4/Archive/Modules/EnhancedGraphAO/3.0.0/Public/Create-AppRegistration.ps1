function Create-AppRegistration {
    param (
        [string]$AppName,
        # [string]$PermsFile = "$PSScriptRoot\permissions.json"
        [string]$PermsFile
    )

    try {
        if (-Not (Test-Path $PermsFile)) {
            Write-EnhancedLog -Message "Permissions file not found: $PermsFile" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            throw "Permissions file missing"
        }
    
        $permissions = Get-Content -Path $PermsFile -Raw | ConvertFrom-Json

        # Convert the JSON data to the required types
        $requiredResourceAccess = @()
        foreach ($perm in $permissions.permissions) {
            $resourceAccess = @()
            foreach ($access in $perm.ResourceAccess) {
                $resourceAccess += [Microsoft.Graph.PowerShell.Models.IMicrosoftGraphResourceAccess]@{
                    Id   = [Guid]$access.Id
                    Type = $access.Type
                }
            }
            $requiredResourceAccess += [Microsoft.Graph.PowerShell.Models.IMicrosoftGraphRequiredResourceAccess]@{
                ResourceAppId  = [Guid]$perm.ResourceAppId
                ResourceAccess = $resourceAccess
            }
        }

        # Connect to Graph interactively
        # Connect-MgGraph -Scopes "Application.ReadWrite.All"
    
        # Get tenant details
        $tenantDetails = Get-MgOrganization | Select-Object -First 1
    
        # Create the application
        $app = New-MgApplication -DisplayName $AppName -SignInAudience "AzureADMyOrg" -RequiredResourceAccess $requiredResourceAccess
    
        if ($null -eq $app) {
            Write-EnhancedLog -Message "App registration failed" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            throw "App registration failed"
        }
    
        Write-EnhancedLog -Message "App registered successfully" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
        return @{ App = $app; TenantDetails = $tenantDetails }
        
    }
    catch {
        Handle-Error -ErrorRecord $_
    }
}