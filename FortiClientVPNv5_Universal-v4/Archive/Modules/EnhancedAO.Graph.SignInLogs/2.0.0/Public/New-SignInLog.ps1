# Function to create a SignInLog object
function New-SignInLog {
    param (
        [string] $UserDisplayName,
        [string] $UserId,
        $DeviceDetail
    )
    [PSCustomObject]@{
        UserDisplayName = $UserDisplayName
        UserId = $UserId
        DeviceDetail = $DeviceDetail
    }
}