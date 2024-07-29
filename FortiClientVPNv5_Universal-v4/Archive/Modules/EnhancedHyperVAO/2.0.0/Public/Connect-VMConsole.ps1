function Connect-VMConsole {
    <#
    .SYNOPSIS
    Connects to the console of the specified VM.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $false)]
        [string]$ServerName = "localhost",

        [Parameter(Mandatory = $false)]
        [int]$Count = 1
    )

    Begin {
        Write-EnhancedLog -Message "Starting Connect-VMConsole function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName; ServerName = $ServerName; Count = $Count }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Validating if VM $VMName exists" -Level "INFO"
            if (-not (Validate-VMExists -VMName $VMName)) {
                Write-EnhancedLog -Message "VM $VMName does not exist. Exiting function." -Level "ERROR"
                return
            }

            Write-EnhancedLog -Message "Checking if VM $VMName is running" -Level "INFO"
            if (-not (Validate-VMStarted -VMName $VMName)) {
                Write-EnhancedLog -Message "VM $VMName is not running. Cannot connect to console." -Level "ERROR"
                return
            }

            $vmConnectArgs = "$ServerName `"$VMName`""
            if ($Count -gt 1) {
                $vmConnectArgs += " -C $Count"
            }

            Write-EnhancedLog -Message "VMConnect arguments: $vmConnectArgs" -Level "DEBUG"
            Start-Process -FilePath "vmconnect.exe" -ArgumentList $vmConnectArgs -ErrorAction Stop
            Write-EnhancedLog -Message "VMConnect launched for VM $VMName on $ServerName with count $Count." -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "An error occurred while launching VMConnect for VM $VMName. $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Connect-VMConsole function" -Level "INFO"
    }
}
