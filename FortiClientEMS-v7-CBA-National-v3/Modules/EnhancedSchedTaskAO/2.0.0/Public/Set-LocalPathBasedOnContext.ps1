function Set-LocalPathBasedOnContext {
    Write-EnhancedLog -Message "Checking running context..." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Cyan)
    if (Test-RunningAsSystem) {
        Write-EnhancedLog -Message "Running as system, setting path to Program Files" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
        # return "$ENV:Programfiles\_MEM"
        return "C:\_MEM"
    }
    else {
        Write-EnhancedLog -Message "Running as user, setting path to Local AppData" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
        return "$ENV:LOCALAPPDATA\_MEM"
    }
}