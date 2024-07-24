#Unique tracking ID a39a34be-6c0e-47ac-962c-4a8fc44b1c77

$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$productCode = "{D6A52B20-063A-4BF6-8228-CDADBF8ACBCF}"
$isInstalled = $false

foreach ($key in $uninstallKeys) {
    Get-ChildItem -Path $key |
    ForEach-Object {
        $app = Get-ItemProperty -Path $_.PsPath
        if ($app.PSChildName -eq $productCode) {
            $isInstalled = $true
            break
        }
    }
    
    if ($isInstalled) {
        break
    }
}

# Conditionally proceed based on the checks
if ($isInstalled) {
    Write-Output "FortiClient VPN v7.2.3.0929 with product code $productCode is installed."
    exit 0
} else {
    # Write-Output "FortiClient v7.0.9 product code $productCode is not installed."
    exit 1
}