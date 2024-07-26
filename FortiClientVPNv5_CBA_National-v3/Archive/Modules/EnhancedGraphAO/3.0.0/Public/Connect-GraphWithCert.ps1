function Connect-GraphWithCert {
    param (
        [Parameter(Mandatory = $true)]
        [string]$tenantId,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$certPath,
        [Parameter(Mandatory = $true)]
        [string]$certPassword,
        [switch]$ConnectToIntune,
        [switch]$ConnectToTeams
    )

    try {
        # Log the certificate path
        Log-Params -Params @{certPath = $certPath}

        # Load the certificate from the PFX file
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certPath, $certPassword)

        # Define the splat for Connect-MgGraph
        $GraphParams = @{
            ClientId    = $clientId
            TenantId    = $tenantId
            Certificate = $cert
        }

        # Log the parameters
        Log-Params -Params $GraphParams

        # Obtain access token (if needed separately)
        $accessToken = Get-MsGraphAccessTokenCert -tenantId $tenantId -clientId $clientId -certPath $certPath -certPassword $certPassword
        Log-Params -Params @{accessToken = $accessToken}

        # Connect to Microsoft Graph
        Write-EnhancedLog -message 'Calling Connect-MgGraph with client certificate file path and password' -Level 'INFO'
        Connect-MgGraph @GraphParams -NoWelcome

        # Conditional check for Intune connection
        if ($ConnectToIntune) {
            try {
                # Define the parameters for non-interactive connection to Intune
                $IntuneGraphconnectionParams = @{
                    ClientId    = $clientId
                    TenantId    = $tenantId
                    ClientCert  = $cert
                }

                # Log the connection attempt
                Write-EnhancedLog -Message "Calling Connect-MSIntuneGraph with connectionParams" -Level "WARNING"

                # Call the Connect-MSIntuneGraph function with splatted parameters
                $Session = Connect-MSIntuneGraph @IntuneGraphconnectionParams

                # Log the successful connection
                Write-EnhancedLog -Message "Connecting to Graph using Connect-MSIntuneGraph - done" -Level "INFO"
            } catch {
                Handle-Error -ErrorRecord $_
            }
        }

        # Conditional check for Teams connection
        if ($ConnectToTeams) {
            try {
                Write-EnhancedLog -Message "Connecting to Microsoft Teams" -Level "INFO"

                # Connect to Microsoft Teams using the certificate
                Connect-MicrosoftTeams -TenantId $tenantId -Certificate $cert -ApplicationId $clientId

                Write-EnhancedLog -Message "Connected to Microsoft Teams" -Level "INFO"
            } catch {
                Handle-Error -ErrorRecord $_
            }
        }

        return $accessToken
    } catch {
        Handle-Error -ErrorRecord $_
    }
}

#Note for Teams Connection you must add RBAC role like Teams Admin to the app as well in additon to the API permissions as mentioned below

# https://learn.microsoft.com/en-us/MicrosoftTeams/teams-powershell-application-authentication

# Setup Application-based authentication
# An initial onboarding is required for authentication using application objects. Application and service principal are used interchangeably, but an application is like a class object while a service principal is like an instance of the class. You can learn more about these objects at Application and service principal objects in Microsoft Entra ID.

# Sample steps for creating applications in Microsoft Entra ID are mentioned below. For detailed steps, refer to this article.

# 1- Register the application in Microsoft Entra ID.
# 2- Assign API permissions to the application.
# 2.1 For *-Cs cmdlets - the Microsoft Graph API permission needed is Organization.Read.All.
# 2.2 For Non *-Cs cmdlets - the Microsoft Graph API permissions needed are Organization.Read.All, User.Read.All, Group.ReadWrite.All, AppCatalog.ReadWrite.All, TeamSettings.ReadWrite.All, Channel.Delete.All, ChannelSettings.ReadWrite.All, ChannelMember.ReadWrite.All.
# 3. Generate a self-signed certificate.
# 4. Attach the certificate to the Microsoft Entra application.
# 5. Assign Microsoft Entra roles to the application. Refer to this Assign a role procedure, but search for the application instead of a user.
# The application needs to have the appropriate RBAC roles assigned. Because the apps are provisioned in Microsoft Entra ID, you can use any of the supported built-in roles.