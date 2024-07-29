function Test-VPNConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConnectionName
    )

    try {
        # Check if the VPN connection exists
        $vpnConnection = Get-VpnConnection -Name $ConnectionName -AllUserConnection -ErrorAction SilentlyContinue
        if ($null -ne $vpnConnection) {
            Write-EnhancedLog -Message "VPN connection '$ConnectionName' exists." -Level "INFO"
            return $true
        } else {
            Write-EnhancedLog -Message "VPN connection '$ConnectionName' does not exist." -Level "INFO"
            return $false
        }
    }
    catch {
        Handle-Error -ErrorRecord $_
        Write-EnhancedLog -Message "An error occurred while checking VPN connection '$ConnectionName'." -Level "ERROR"
        throw $_
    }
}



# Test-VPNConnection -ConnectionName "ICTC VPN"