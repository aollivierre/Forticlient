function Compile-Win32_intunewin {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory)]
        [string]$Repo_winget,

        [Parameter(Mandatory)]
        [string]$Repo_Path,

         [Parameter(Mandatory)]
        [string]$Prg_Path
    )

    Write-EnhancedLog -Message "Entering Compile-Win32_intunewin" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)



    

    # Check for application image
    $Prg_img = if (Test-Path -Path (Join-Path -Path $Prg_Path -ChildPath "$($Prg.id).png")) {
        Join-Path -Path $Prg_Path -ChildPath "$($Prg.id).png"
    }
    else {
        "$Repo_Path\resources\template\winget\winget-managed.png"
    }

    # Download the latest IntuneWinAppUtil
    # Invoke-WebRequest -Uri $IntuneWinAppUtil_online -OutFile "$Repo_Path\resources\IntuneWinAppUtil.exe" -UseBasicParsing

    # Create the .intunewin file
    # Start-Process -FilePath "$Repo_Path\resources\IntuneWinAppUtil.exe" -ArgumentList "-c `"$Prg_Path`" -s install.ps1 -o `"$Prg_Path`" -q" -Wait -WindowStyle Hidden (when used in Linux do not use windowstyle hidden)
    # Start-Process -FilePath "$Repo_Path\resources\IntuneWinAppUtil.exe" -ArgumentList "-c `"$Prg_Path`" -s install.ps1 -o `"$Prg_Path`" -q" -Wait

    Upload-Win32App -Prg $Prg -Prg_Path $Prg_Path -Prg_img $Prg_img
    # Upload-Win32App -Prg $Prg -Prg_Path $Prg_Path

    Write-EnhancedLog -Message "Exiting Compile-Win32_intunewin" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
}
