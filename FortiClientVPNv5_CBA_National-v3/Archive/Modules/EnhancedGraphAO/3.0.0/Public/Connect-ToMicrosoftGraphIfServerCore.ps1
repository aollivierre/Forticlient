function Connect-ToMicrosoftGraphIfServerCore {
    param (
        [string[]]$Scopes
    )

    if (Is-ServerCore) {
        Write-Output "Running on Windows Server Core. Using device authentication for Microsoft Graph."
        Connect-MgGraph -Scopes $Scopes -Verbose -UseDeviceAuthentication
    } else {
        Write-Output "Not running on Windows Server Core. Using default authentication for Microsoft Graph."
        Connect-MgGraph -Scopes $Scopes -Verbose
    }
}
