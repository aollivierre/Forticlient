function EnsureUntrustedGuardianExists {
    <#
    .SYNOPSIS
    Ensures that an untrusted guardian exists. If not, creates one.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$GuardianName = 'UntrustedGuardian'
    )

    Begin {
        Write-EnhancedLog -Message "Starting Ensure-UntrustedGuardianExists function" -Level "INFO"
        Log-Params -Params @{ GuardianName = $GuardianName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking for the existence of the guardian: $GuardianName" -Level "INFO"
            $guardian = Get-HgsGuardian -Name $GuardianName -ErrorAction SilentlyContinue

            if ($null -eq $guardian) {
                Write-EnhancedLog -Message "Guardian $GuardianName not found. Creating..." -Level "WARNING"
                New-HgsGuardian -Name $GuardianName -GenerateCertificates
                Write-EnhancedLog -Message "Guardian $GuardianName created successfully" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            } else {
                Write-EnhancedLog -Message "Guardian $GuardianName already exists" -Level "INFO"
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while checking or creating the guardian: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Ensure-UntrustedGuardianExists function" -Level "INFO"
    }
}
