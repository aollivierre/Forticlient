function Remove-FortiSoftware {
    [CmdletBinding()]
    param (
        [string]$ScriptRoot,
        [string]$SoftwareName,
        [string]$MsiZapFileName,
        [string]$ArgumentTemplate
    )

    begin {
        Write-EnhancedLog -Message 'Starting Remove-FortiSoftware function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            $msiZapPath = Join-Path -Path $ScriptRoot -ChildPath $MsiZapFileName

            if (Test-Path $msiZapPath) {
                $identifyingNumber = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like $SoftwareName } | Select-Object -ExpandProperty IdentifyingNumber

                if ($identifyingNumber) {
                    Write-EnhancedLog -Message "Found software with IdentifyingNumber: $identifyingNumber" -Level 'INFO'
                    Write-EnhancedLog -Message "Executing MsiZap with IdentifyingNumber: $identifyingNumber" -Level 'INFO'

                    $argumentList = $ArgumentTemplate -replace '{IdentifyingNumber}', $identifyingNumber
                    Start-Process -FilePath $msiZapPath -ArgumentList $argumentList -Verb RunAs -Wait

                    Write-EnhancedLog -Message 'MsiZap process completed' -Level 'INFO'
                } else {
                    Write-EnhancedLog -Message 'No matching software found' -Level 'WARNING'
                }
            } else {
                Write-EnhancedLog -Message "MsiZap.exe not found at path: $msiZapPath" -Level 'ERROR'
            }
        } catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Remove-FortiSoftware function completed' -Level 'INFO'
    }
}

# # Example usage of Remove-FortiSoftware function with splatting
# $params = @{
#     ScriptRoot      = $PSScriptRoot
#     SoftwareName    = '*forti*'
#     MsiZapFileName  = 'MsiZap.Exe'
#     ArgumentTemplate= 'TW! {IdentifyingNumber}'
# }
# Remove-FortiSoftware @params
