# Function to create a DeviceDetail object
function New-DeviceDetail {
    param (
        [string] $DeviceId,
        [string] $DisplayName,
        [string] $OperatingSystem,
        [bool] $IsCompliant,
        [string] $TrustType
    )
    [PSCustomObject]@{
        DeviceId        = $DeviceId
        DisplayName     = $DisplayName
        OperatingSystem = $OperatingSystem
        IsCompliant     = $IsCompliant
        TrustType       = $TrustType
    }
}