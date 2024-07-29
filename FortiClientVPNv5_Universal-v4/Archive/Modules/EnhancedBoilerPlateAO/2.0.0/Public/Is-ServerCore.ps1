function Is-ServerCore {
    $regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Server\ServerLevels"
    if (Test-Path $regPath) {
        $value = Get-ItemProperty -Path $regPath -Name "ServerCore"
        return $value.ServerCore -eq 1
    }
    return $false
}
