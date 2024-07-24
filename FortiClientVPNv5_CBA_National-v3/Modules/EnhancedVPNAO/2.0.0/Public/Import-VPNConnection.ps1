function Import-VPNConnection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$XmlFilePath
    )

    try {
        Write-EnhancedLog -Message "Script starting..." -Level "INFO"

        # Load the XML file
        [xml]$vpnConfig = Get-Content -Path $XmlFilePath

        # Extract VPN connection details from the XML
        $connectionName = $vpnConfig.Objs.Obj.Props.S | Where-Object { $_.N -eq "Name" } | Select-Object -ExpandProperty '#text'
        $serverAddress = $vpnConfig.Objs.Obj.Props.S | Where-Object { $_.N -eq "ServerAddress" } | Select-Object -ExpandProperty '#text'
        $tunnelType = $vpnConfig.Objs.Obj.Props.S | Where-Object { $_.N -eq "TunnelType" } | Select-Object -ExpandProperty '#text'
        $encryptionLevel = $vpnConfig.Objs.Obj.Props.S | Where-Object { $_.N -eq "EncryptionLevel" } | Select-Object -ExpandProperty '#text'
        $splitTunneling = $vpnConfig.Objs.Obj.Props.B | Where-Object { $_.N -eq "SplitTunneling" } | Select-Object -ExpandProperty '#text'
        $rememberCredential = $vpnConfig.Objs.Obj.Props.B | Where-Object { $_.N -eq "RememberCredential" } | Select-Object -ExpandProperty '#text'
        $useWinlogonCredential = $vpnConfig.Objs.Obj.Props.B | Where-Object { $_.N -eq "UseWinlogonCredential" } | Select-Object -ExpandProperty '#text'
        $idleDisconnectSeconds = $vpnConfig.Objs.Obj.Props.U32 | Where-Object { $_.N -eq "IdleDisconnectSeconds" } | Select-Object -ExpandProperty '#text'
        # $authenticationMethod = $vpnConfig.Objs.Obj.Props.Obj.LST.S | Select-Object -ExpandProperty '#text'
        $authenticationMethod = $vpnConfig.Objs.Obj.Props.Obj | Where-Object { $_.N -eq "AuthenticationMethod" } | Select-Object -ExpandProperty LST | Select-Object -ExpandProperty S
        $l2tpPsk = $vpnConfig.Objs.Obj.Props.S | Where-Object { $_.N -eq "L2tpIPsecAuth" } | Select-Object -ExpandProperty '#text'
        # $napState = $vpnConfig.Objs.Obj.Props.S | Where-Object { $_.N -eq "NapState" } | Select-Object -ExpandProperty '#text'

        # Convert boolean values from text to actual boolean type
        $splitTunneling = [System.Convert]::ToBoolean($splitTunneling)
        $rememberCredential = [System.Convert]::ToBoolean($rememberCredential)
        $useWinlogonCredential = [System.Convert]::ToBoolean($useWinlogonCredential)

        # Validate extracted details
        if ([string]::IsNullOrWhiteSpace($connectionName) -or [string]::IsNullOrWhiteSpace($serverAddress)) {
            Write-EnhancedLog -Message "Connection name or server address could not be found in the XML file." -Level "ERROR"
            return
        }

        # Validate if VPN connection already exists
        if (Test-VPNConnection -ConnectionName $connectionName) {
            Write-EnhancedLog -Message "VPN connection '$connectionName' already exists. Removing it before re-importing." -Level "WARNING"
            Remove-VpnConnection -Name $connectionName -Force -AllUserConnection -ErrorAction SilentlyContinue

            # Verify the VPN connection is removed
            if (Test-VPNConnection -ConnectionName $connectionName) {
                Write-EnhancedLog -Message "Failed to remove existing VPN connection '$connectionName'." -Level "ERROR"
                return
            }

            Start-Sleep -Seconds 5 # Wait to ensure the connection is fully removed
        }

        # Splatting parameters for Add-VpnConnection
        $splatVpnParams = @{
            Name                  = $connectionName
            ServerAddress         = $serverAddress
            TunnelType            = $tunnelType
            EncryptionLevel       = $encryptionLevel
            SplitTunneling        = $splitTunneling
            RememberCredential    = $rememberCredential
            UseWinlogonCredential = $useWinlogonCredential
            IdleDisconnectSeconds = $idleDisconnectSeconds
            AuthenticationMethod  = $authenticationMethod
            L2tpPsk               = $l2tpPsk
            AllUserConnection     = $true
            Force                 = $true
        }

        # Remove L2tpPsk parameter if TunnelType is not L2tp
        if ($tunnelType -ne 'L2tp') {
            $splatVpnParams.Remove('L2tpPsk')
        }

        # Create the VPN connection
        Add-VpnConnection @splatVpnParams
        Write-EnhancedLog -Message "VPN connection '$connectionName' imported. Verifying the import..." -Level "INFO"

        # Introduce a brief pause to ensure the connection is fully created
        Start-Sleep -Seconds 5

        # Verify the VPN connection was created successfully
        if (Test-VPNConnection -ConnectionName $connectionName) {
            Write-EnhancedLog -Message "VPN connection '$connectionName' was successfully imported." -Level "INFO"
        } else {
            Write-EnhancedLog -Message "VPN connection '$connectionName' failed to import." -Level "ERROR"
        }
    }
    catch {
        Handle-Error -ErrorRecord $_
        Write-EnhancedLog -Message "An error occurred while importing VPN connection." -Level "ERROR"
        throw $_
    }
}
