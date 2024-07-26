function Add-LocalUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TempUser,

        [Parameter(Mandatory = $true)]
        [string]$TempUserPassword,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [string]$Group
    )

    Begin {
        Write-EnhancedLog -Message "Starting Add-LocalUser function" -Level "INFO"
        Log-Params -Params @{ 
            TempUser         = $TempUser
            TempUserPassword = $TempUserPassword
            Description      = $Description
            Group            = $Group
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Creating Local User Account" -Level "INFO"
            $Password = ConvertTo-SecureString -AsPlainText $TempUserPassword -Force
            New-LocalUser -Name $TempUser -Password $Password -Description $Description -AccountNeverExpires
            Add-LocalGroupMember -Group $Group -Member $TempUser
        } catch {
            Write-EnhancedLog -Message "An error occurred while adding local user: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Add-LocalUser function" -Level "INFO"
    }
}

# # Define parameters
# $AddLocalUserParams = @{
#     TempUser         = "YourTempUser"
#     TempUserPassword = "YourTempUserPassword"
#     Description      = "account for autologin"
#     Group            = "Administrators"
# }

# # Example usage with splatting
# Add-LocalUser @AddLocalUserParams
