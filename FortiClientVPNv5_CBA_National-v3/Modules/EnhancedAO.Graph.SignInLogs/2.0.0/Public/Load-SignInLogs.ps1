function Load-SignInLogs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$JsonFilePath
    )

    $signInLogs = [System.Collections.Generic.List[PSCustomObject]]::new()
    Write-EnhancedLog -Message "Opening file: $JsonFilePath" -Level 'Debug'
    $fileStream = [System.IO.FileStream]::new($JsonFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read, 4096, [System.IO.FileOptions]::SequentialScan)

    try {
        $jsonDoc = [System.Text.Json.JsonDocument]::Parse($fileStream)

        foreach ($element in $jsonDoc.RootElement.EnumerateArray()) {
            $deviceDetail = [PSCustomObject]@{
                DeviceId       = $element.GetProperty("deviceDetail").GetProperty("deviceId").GetString()
                DisplayName    = $element.GetProperty("deviceDetail").GetProperty("displayName").GetString()
                OperatingSystem = $element.GetProperty("deviceDetail").GetProperty("operatingSystem").GetString()
                IsCompliant    = $element.GetProperty("deviceDetail").GetProperty("isCompliant").GetBoolean()
                TrustType      = $element.GetProperty("deviceDetail").GetProperty("trustType").GetString()
            }

            $signInLog = [PSCustomObject]@{
                UserDisplayName = $element.GetProperty("userDisplayName").GetString()
                UserId          = $element.GetProperty("userId").GetString()
                DeviceDetail    = $deviceDetail
            }

            $signInLogs.Add($signInLog)
        }

        Write-EnhancedLog -Message "Sign-in logs loaded successfully from $JsonFilePath." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    } catch {
        Handle-Error -ErrorRecord $_
    } finally {
        $fileStream.Dispose()
    }

    return $signInLogs
}

# # Example usage
# $jsonFilePath = "path_to_your_json_file.json"
# $signInLogs = Load-SignInLogs -JsonFilePath $jsonFilePath
# Write-Output "Sign-In Logs: $($signInLogs | Format-Table -AutoSize)"

