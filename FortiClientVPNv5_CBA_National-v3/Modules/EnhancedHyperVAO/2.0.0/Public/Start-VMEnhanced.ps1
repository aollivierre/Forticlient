function Start-VMEnhanced {
    <#
    .SYNOPSIS
    Starts the specified VM if it exists and is not already running.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Start-VMEnhanced function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Validating if VM $VMName exists" -Level "INFO"
            if (-not (Validate-VMExists -VMName $VMName)) {
                Write-EnhancedLog -Message "VM $VMName does not exist. Exiting function." -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
                return
            }

            Write-EnhancedLog -Message "Checking if VM $VMName is already running" -Level "INFO"
            if (Validate-VMStarted -VMName $VMName) {
                Write-EnhancedLog -Message "VM $VMName is already running." -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)
            } else {
                Write-EnhancedLog -Message "Starting VM $VMName" -Level "INFO"
                Start-VM -Name $VMName -ErrorAction Stop
                Write-EnhancedLog -Message "VM $VMName has been started successfully." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while starting the VM $VMName. $($_.Exception.Message)" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Start-VMEnhanced function" -Level "INFO"
    }
}
