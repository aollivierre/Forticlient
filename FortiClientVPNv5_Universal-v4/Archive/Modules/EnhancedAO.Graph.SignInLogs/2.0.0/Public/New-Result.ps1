# Function to create a Result object
function New-Result {
    param (
        [string] $DeviceName,
        [string] $UserName,
        [string] $DeviceEntraID,
        [string] $UserEntraID,
        [string] $DeviceOS,
        [string] $DeviceComplianceStatus,
        [string] $DeviceStateInIntune,
        [string] $TrustType,
        [string] $UserLicense,
        [string] $OSVersion
    )
    [PSCustomObject]@{
        DeviceName             = $DeviceName
        UserName               = $UserName
        DeviceEntraID          = $DeviceEntraID
        UserEntraID            = $UserEntraID
        DeviceOS               = $DeviceOS
        DeviceComplianceStatus = $DeviceComplianceStatus
        DeviceStateInIntune    = $DeviceStateInIntune
        TrustType              = $TrustType
        UserLicense            = $UserLicense
        OSVersion              = $OSVersion
    }
}