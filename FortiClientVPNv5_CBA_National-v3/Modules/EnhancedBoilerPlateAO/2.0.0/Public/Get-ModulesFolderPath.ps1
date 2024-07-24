function Get-ModulesFolderPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$WindowsPath,
        [Parameter(Mandatory = $true)]
        [string]$UnixPath
    )

    # Auxiliary function to detect OS and set the Modules folder path
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        if ($PSVersionTable.Platform -eq 'Win32NT') {
            return $WindowsPath
        }
        elseif ($PSVersionTable.Platform -eq 'Unix') {
            return $UnixPath
        }
        else {
            throw "Unsupported operating system"
        }
    }
    else {
        $os = [System.Environment]::OSVersion.Platform
        if ($os -eq [System.PlatformID]::Win32NT) {
            return $WindowsPath
        }
        elseif ($os -eq [System.PlatformID]::Unix) {
            return $UnixPath
        }
        else {
            throw "Unsupported operating system"
        }
    }
}
