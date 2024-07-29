function Get-AppInfoFromJson {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$jsonPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Get-AppInfoFromJson function" -Level "INFO"
        Log-Params -Params @{ jsonPath = $jsonPath }
    }

    Process {
        try {
            # Check if the file exists
            if (-Not (Test-Path -Path $jsonPath)) {
                Write-Error "The file at path '$jsonPath' does not exist."
                return
            }

            # Read the JSON content from the file
            Write-EnhancedLog -Message "Reading JSON content from file: $jsonPath" -Level "INFO"
            $jsonContent = Get-Content -Path $jsonPath -Raw

            # Check if the JSON content is empty
            if (-Not $jsonContent) {
                Write-EnhancedLog -Message "The JSON content is empty." -Level "ERROR"
                return
            }

            # Convert the JSON content to a PowerShell object
            Write-EnhancedLog -Message "Converting JSON content to PowerShell object" -Level "INFO"
            $appData = ConvertFrom-Json -InputObject $jsonContent

            # Check if the appData is empty or null
            if (-Not $appData) {
                Write-EnhancedLog -Message "The JSON content did not contain any data." -Level "ERROR"
                return
            }

            # Extract the required information
            Write-EnhancedLog -Message "Extracting required information from JSON data" -Level "INFO"
            $extractedData = $appData | ForEach-Object {
                [PSCustomObject]@{
                    Id              = $_.Id
                    DisplayName     = $_.DisplayName
                    AppId           = $_.AppId
                    SignInAudience  = $_.SignInAudience
                    PublisherDomain = $_.PublisherDomain
                }
            }

            # Return the extracted data
            return $extractedData
        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the JSON content: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Get-AppInfoFromJson function" -Level "INFO"
    }
}
