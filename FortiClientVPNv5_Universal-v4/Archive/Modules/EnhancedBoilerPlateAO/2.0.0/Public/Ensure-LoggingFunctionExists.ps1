function Ensure-LoggingFunctionExists {
    param (
        # [string]$LoggingFunctionName = "Write-EnhancedLog"
        [string]$LoggingFunctionName
    )

    if (Get-Command $LoggingFunctionName -ErrorAction SilentlyContinue) {
        Write-EnhancedLog -Message "Logging works" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }
    else {
        throw "$LoggingFunctionName function not found. Terminating script."
    }
}

# Example of how to call the function with the default parameter
# Ensure-LoggingFunctionExists

# Example of how to call the function with a different logging function name
# Ensure-LoggingFunctionExists -LoggingFunctionName "Write-EnhancedLog"
