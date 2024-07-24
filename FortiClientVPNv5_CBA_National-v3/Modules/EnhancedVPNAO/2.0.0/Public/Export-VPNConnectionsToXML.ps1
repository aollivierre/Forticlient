function Export-VPNConnectionsToXML {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExportFolder
    )

    try {
        # Get the list of current VPN connections
        $vpnConnections = Get-VpnConnection -AllUserConnection

        # Check if there are no VPN connections
        if ($vpnConnections.Count -eq 0) {
            Write-EnhancedLog -Message "NO VPN connections found." -Level "WARNING"
            return
        }

        # Generate a timestamp for the export
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $baseOutputPath = Join-Path -Path $ExportFolder -ChildPath "VPNExport_$timestamp"

        # Setup parameters for Export-Data using splatting
        $splatExportParams = @{
            Data             = $vpnConnections
            BaseOutputPath   = $baseOutputPath
            IncludeCSV       = $true
            IncludeJSON      = $true
            IncludeXML       = $true
            IncludePlainText = $true
            # IncludeExcel     = $true
            IncludeYAML      = $true
        }

        # Call the Export-Data function with splatted parameters
        Export-Data @splatExportParams
        Write-EnhancedLog -Message "Data export completed successfully." -Level "INFO"
    }
    catch {
        Handle-Error -ErrorRecord $_
        Write-EnhancedLog -Message "Failed to export VPN connections." -Level "ERROR"
    }
}
