function Get-UnixTime {
    param (
        [Parameter(Mandatory = $true)]
        [int]$offsetMinutes
    )

    return [int]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + ($offsetMinutes * 60))
}