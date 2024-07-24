function Create-AADGroup ($Prg) {


    # # Convert the Client Secret to a SecureString
    # $SecureClientSecret = ConvertTo-SecureString $connectionParams.ClientSecret -AsPlainText -Force

    # # Create a PSCredential object with the Client ID as the user and the Client Secret as the password
    # $ClientSecretCredential = New-Object System.Management.Automation.PSCredential ($connectionParams.ClientId, $SecureClientSecret)

    # # Connect to Microsoft Graph
    # Connect-MgGraph -TenantId $connectionParams.TenantId -ClientSecretCredential $ClientSecretCredential

    # Your code that interacts with Microsoft Graph goes here


    # Create Group
    # $grpname = "$($global:SettingsVAR.AADgrpPrefix )$($Prg.id)"
    Write-EnhancedLog -Message "setting Group Name" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    $grpname = "SG007 - Intune - Apps - Microsoft Teams - WinGet - Windows Package Manager"
    if (!$(Get-MgGroup -Filter "DisplayName eq '$grpname'")) {
        # Write-Host "  Create AAD group for assigment:  $grpname" -Foregroundcolor cyan

        Write-EnhancedLog -Message " Did not find Group $grpname " -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
        
        # $GrpObj = New-MgGroup -DisplayName "$grpname" -Description "App assigment: $($Prg.id) $($Prg.manager)" -MailEnabled:$False  -MailNickName $grpname -SecurityEnabled
    }
    else { $GrpObj = Get-MgGroup -Filter "DisplayName eq '$grpname'" }


    Write-EnhancedLog -Message " Assign Group > $grpname <  to  > $($Prg.Name)" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
  


    Write-EnhancedLog -Message " calling Get-IntuneWin32App " -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    $Win32App = Get-IntuneWin32App -DisplayName "$($Prg.Name)"


    Write-EnhancedLog -Message " calling Get-IntuneWin32App - done " -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)


    Write-EnhancedLog -Message " calling Add-IntuneWin32AppAssignmentGroup " -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    Add-IntuneWin32AppAssignmentGroup -Include -ID $Win32App.id -GroupID $GrpObj.id -Intent "available" -Notification "showAll"


    Write-EnhancedLog -Message " calling Add-IntuneWin32AppAssignmentGroup - done " -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
}
