function New-VPNConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $true)]
        [string]$ServerAddress,

        [Parameter(Mandatory = $true)]
        # [string]$TunnelType = "Pptp"  # Default to Pptp, can be changed to Ikev2, L2tp, etc.
        [string]$TunnelType
    )

    try {
        # Validate if VPN connection already exists
        if (Test-VPNConnection -ConnectionName $ConnectionName) {
            Write-EnhancedLog -Message "VPN connection '$ConnectionName' already exists." -Level "INFO"
            return
        }

        # Create the VPN connection
        Add-VpnConnection -Name $ConnectionName -ServerAddress $ServerAddress -TunnelType $TunnelType -AuthenticationMethod MSChapv2 -EncryptionLevel Optional -Force

        # Validate if VPN connection was created successfully
        if (Test-VPNConnection -ConnectionName $ConnectionName) {
            Write-EnhancedLog -Message "VPN connection '$ConnectionName' created successfully." -Level "INFO"
        } else {
            Write-EnhancedLog -Message "Failed to create VPN connection '$ConnectionName'." -Level "ERROR"
            throw "Failed to create VPN connection '$ConnectionName'."
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while creating VPN connection '$ConnectionName': $_" -Level "ERROR"
        throw $_
    }
}
