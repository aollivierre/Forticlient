function Process-SignInLogs {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[PSCustomObject]]$signInLogs,
        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    # Ensure the signInLogs variable is not null before using it
    if ($null -eq $signInLogs -or $signInLogs.Count -eq 0) {
        Write-Warning "No sign-in logs were loaded."
        exit 1
    }

    # Display the count of loaded sign-in logs
    Write-Host "Loaded $($signInLogs.Count) sign-in logs."

    # Debugging: Print the first sign-in log entry
    if ($signInLogs.Count -gt 0) {
        $firstSignInLog = $signInLogs[0]
        Write-Host "First sign-in log entry:"
        Write-Host "UserDisplayName: $($firstSignInLog.UserDisplayName)"
        Write-Host "UserId: $($firstSignInLog.UserId)"
        Write-Host "DeviceDetail:"
        Write-Host "  DeviceId: $($firstSignInLog.DeviceDetail.DeviceId)"
        Write-Host "  DisplayName: $($firstSignInLog.DeviceDetail.DisplayName)"
        Write-Host "  OperatingSystem: $($firstSignInLog.DeviceDetail.OperatingSystem)"
        Write-Host "  IsCompliant: $($firstSignInLog.DeviceDetail.IsCompliant)"
        Write-Host "  TrustType: $($firstSignInLog.DeviceDetail.TrustType)"
    }

    $context = New-ProcessingContext

    # Process each log item directly
    foreach ($log in $signInLogs) {
        # Exclude "On-Premises Directory Synchronization Service Account" user
        if ($log.UserDisplayName -ne "On-Premises Directory Synchronization Service Account" -and $null -ne $log) {
            try {
                Process-DeviceItem -Item $log -Context $context -Headers $Headers
            } catch {
                Write-Error "Error processing item: $($_.Exception.Message)"
                Handle-Error -ErrorRecord $_
            }
        }
    }

    # Remove null entries from the results list
    $context.Results = $context.Results | Where-Object { $_ -ne $null }

    # Return the results
    return $context.Results
}