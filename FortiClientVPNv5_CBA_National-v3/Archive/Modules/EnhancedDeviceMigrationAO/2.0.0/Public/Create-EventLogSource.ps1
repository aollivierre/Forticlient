function Create-EventLogSource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogName,
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    Begin {
        Write-EnhancedLog -Message "Starting Create-EventLogSource function" -Level "INFO"
        Log-Params -Params @{
            LogName = $LogName
            Source  = $Source
        }
    }

    Process {
        try {
            if (-not (Get-EventLog -LogName $LogName -Source $Source -ErrorAction SilentlyContinue)) {
                New-EventLog -LogName $LogName -Source $Source -ErrorAction Stop
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while creating the event log source: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Create-EventLogSource function" -Level "INFO"
    }
}


# $CreateEventLogSourceParams = @{
#     LogName = "Application"
#     Source  = "AAD_Migration_Script"
# }

# Create-EventLogSource @CreateEventLogSourceParams