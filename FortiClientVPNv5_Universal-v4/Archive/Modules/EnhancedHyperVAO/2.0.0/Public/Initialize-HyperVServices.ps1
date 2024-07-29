function Initialize-HyperVServices {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting Initialize-HyperVServices function" -Level "INFO"
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking for Hyper-V services" -Level "INFO"
            if (Get-Service -DisplayName *hyper*) {
                Write-EnhancedLog -Message "Starting Hyper-V services: vmcompute and vmms" -Level "INFO"
                Start-Service -Name vmcompute -ErrorAction SilentlyContinue
                Start-Service -Name vmms -ErrorAction SilentlyContinue
                Write-EnhancedLog -Message "Hyper-V services started" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            } else {
                Write-EnhancedLog -Message "No Hyper-V services found" -Level "WARNING"
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while starting Hyper-V services: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Initialize-HyperVServices function" -Level "INFO"
    }
}
