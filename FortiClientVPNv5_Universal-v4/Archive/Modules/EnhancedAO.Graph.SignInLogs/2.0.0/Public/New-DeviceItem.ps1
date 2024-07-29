# Function to create a DeviceItem object
function New-DeviceItem {
    param (
        [string] $DeviceId,
        [string] $UserId,
        [string] $UserDisplayName
    )
    [PSCustomObject]@{
        DeviceId = $DeviceId
        UserId = $UserId
        UserDisplayName = $UserDisplayName
    }
}