
# ################################################################################################################################
# ################################################ CALLING AS SYSTEM (Uncomment for debugging) ###################################
# ################################################################################################################################

# Assuming Invoke-AsSystem and Write-EnhancedLog are already defined
# Update the path to your actual location of PsExec64.exe

# Write-EnhancedLog -Message "calling Test-RunningAsSystem" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
# if (-not (Test-RunningAsSystem)) {
#     $privateFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "private"

#     # Check if the private folder exists, and create it if it does not
#     if (-not (Test-Path -Path $privateFolderPath)) {
#         New-Item -Path $privateFolderPath -ItemType Directory | Out-Null
#     }
    
#     $PsExec64Path = Join-Path -Path $privateFolderPath -ChildPath "PsExec64.exe"
    

#     Write-EnhancedLog -Message "Current session is not running as SYSTEM. Attempting to invoke as SYSTEM..." -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)

#     $ScriptToRunAsSystem = $MyInvocation.MyCommand.Path
#     Invoke-AsSystem -PsExec64Path $PsExec64Path -ScriptPath $ScriptToRunAsSystem -TargetFolder $privateFolderPath

# }
# else {
#     Write-EnhancedLog -Message "Session is already running as SYSTEM." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
# }



# ################################################################################################################################
# ################################################ END CALLING AS SYSTEM (Uncomment for debugging) ###############################
# ################################################################################################################################