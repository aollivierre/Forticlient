function Fetch-UserLicense {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserId,
        [Parameter(Mandatory = $true)]
        [string]$Username,
        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    try {
        Write-EnhancedLog -Message "Fetching licenses for user: $Username with ID: $UserId" -ForegroundColor Cyan
        $userLicenses = Get-UserLicenses -userId $UserId -username $Item.userDisplayName  -Headers $Headers
        return $userLicenses
    } catch {
        Handle-Error -ErrorRecord $_
        # return $null
    }
}