function Handle-Error {
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $fullErrorDetails = Get-Error -InputObject $ErrorRecord | Out-String
    } else {
        $fullErrorDetails = $ErrorRecord.Exception | Format-List * -Force | Out-String
    }

    Write-EnhancedLog -Message "Exception Message: $($ErrorRecord.Exception.Message)" -Level "ERROR"
    Write-EnhancedLog -Message "Full Exception: $fullErrorDetails" -Level "ERROR"
}

# # Example usage
# try {
#     # Your code that might throw an error
#     Throw "This is a test error"
# }
# catch {
#     Handle-Error -ErrorRecord $_
# }
