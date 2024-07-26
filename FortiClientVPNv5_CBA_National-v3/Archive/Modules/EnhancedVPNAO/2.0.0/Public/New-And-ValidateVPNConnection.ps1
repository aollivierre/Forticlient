function New-And-ValidateVPNConnection {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VPNConnectionName,
        [Parameter(Mandatory = $true)]
        [string]$VPNServerAddress
    )

    try {
        # Create the VPN connection
        New-VPNConnection -ConnectionName $VPNConnectionName -ServerAddress $VPNServerAddress -TunnelType 'Pptp'

        # Validate VPN connection
        if (Test-VPNConnection -ConnectionName $VPNConnectionName) {
            Write-EnhancedLog -Message "VPN connection '$VPNConnectionName' is ready for use." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        }
        else {
            Write-EnhancedLog -Message "VPN connection '$VPNConnectionName' validation failed." -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
    }
}

# # Example usage
# $vpnConnectionName = "MyVPNConnection"
# $vpnServerAddress = "vpn.example.com"
# New-And-ValidateVPNConnection -VPNConnectionName $vpnConnectionName -VPNServerAddress $vpnServerAddress
