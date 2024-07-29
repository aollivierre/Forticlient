function Remove-CompanyPortal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppxPackageName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Remove-CompanyPortal function" -Level "INFO"
        Log-Params -Params @{ AppxPackageName = $AppxPackageName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Removing AppxPackage: $AppxPackageName" -Level "INFO"
            Get-AppxPackage -AllUsers -Name $AppxPackageName | Remove-AppxPackage -Confirm:$false
        } catch {
            Write-EnhancedLog -Message "An error occurred while removing AppxPackage: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-CompanyPortal function" -Level "INFO"
    }
}

# $RemoveCompanyPortalParams = @{
#     AppxPackageName = "Microsoft.CompanyPortal"
# }

# Remove-CompanyPortal @RemoveCompanyPortalParams
