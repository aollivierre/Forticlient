# # # # # # # # # # # #Unique Tracking ID: 275d6fc2-003c-4da0-9e66-16cfa045f901, Timestamp: 2024-03-20 12:25:26
# # # # # # # # # # # # Read configuration from the JSON file
# # # # # # # # # # # # $configPath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..") -ChildPath "config.json"
# # # # # # # # # # # # $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

# # # # # # # # # # # function Write-EnhancedLog {
# # # # # # # # # # #     param (
# # # # # # # # # # #         [string]$Message,
# # # # # # # # # # #         [string]$Level = 'INFO',
# # # # # # # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # # # # # # #         # [string]$CSVFilePath_1001 = "$scriptPath_1001\exports\CSV\$(Get-Date -Format 'yyyy-MM-dd')-Log.csv",
# # # # # # # # # # #         # [string]$CentralCSVFilePath = "$scriptPath_1001\exports\CSV\$Filename.csv",
# # # # # # # # # # #         [switch]$UseModule = $false,
# # # # # # # # # # #         [string]$Caller = (Get-PSCallStack)[0].Command
# # # # # # # # # # #     )
    
# # # # # # # # # # #     # Add timestamp, computer name, and log level to the message
# # # # # # # # # # #     $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [$Caller] $Message"
    
# # # # # # # # # # #     # # Set foreground color based on log level
# # # # # # # # # # #     switch ($Level) {
# # # # # # # # # # #         'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray } # Added level
# # # # # # # # # # #         'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # # # # # # #         'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan } # Added level
# # # # # # # # # # #         'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # # # # # # #         'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # # # # # # #         'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta } # Added level
# # # # # # # # # # #         default { $ForegroundColor = [ConsoleColor]::White } # Default case for unknown levels
# # # # # # # # # # #     }
    
# # # # # # # # # # #     # # Write the message with the specified colors
# # # # # # # # # # #     $currentForegroundColor = $Host.UI.RawUI.ForegroundColor
# # # # # # # # # # #     $Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # # # # # # #     Write-Host $formattedMessage
# # # # # # # # # # #     $Host.UI.RawUI.ForegroundColor = $currentForegroundColor
    
# # # # # # # # # # #     # Append to CSV file
# # # # # # # # # # #     # AppendCSVLog -Message $formattedMessage -CSVFilePath $CSVFilePath_1001
# # # # # # # # # # #     # AppendCSVLog -Message $formattedMessage -CSVFilePath $CentralCSVFilePath
    
# # # # # # # # # # #     # Potential place for Write to event log (optional)
# # # # # # # # # # #     # Depending on how you implement `Write-CustomEventLog`, you might want to handle it differently for various levels.


# # # # # # # # # # #     # Write to event log (optional)
# # # # # # # # # # #     # Write-CustomEventLog -EventMessage $formattedMessage -Level $Level

    
# # # # # # # # # # #     # Adjust this line in your script where you call the function
# # # # # # # # # # #     # Write-EventLogMessage -LogName $LogName -EventSource $EventSource -Message $formattedMessage -EventID 1001
# # # # # # # # # # # }

# # # # # # # # # # # # Note: Make sure the `AppendCSVLog` function is defined in your script or module.
# # # # # # # # # # # # It should handle the CSV file appending logic.

    
# # # # # # # # # # # #################################################################################################################################
# # # # # # # # # # # ################################################# END LOGGING ###################################################################
# # # # # # # # # # # #################################################################################################################################



















# # # # # # # # # # # function Write-EnhancedLog {
# # # # # # # # # # #     param (
# # # # # # # # # # #         [string]$Message,
# # # # # # # # # # #         [string]$Level = 'INFO',
# # # # # # # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # # # # # # #         [switch]$UseModule = $false
# # # # # # # # # # #     )

# # # # # # # # # # #     # Get the calling function and class
# # # # # # # # # # #     $callerFunction = (Get-PSCallStack)[1].Command
# # # # # # # # # # #     $callerClass = $null
# # # # # # # # # # #     if ($PSCmdlet.MyInvocation.InvocationName) {
# # # # # # # # # # #         $callerClass = $PSCmdlet.MyInvocation.MyCommand.Module.Name
# # # # # # # # # # #     }

# # # # # # # # # # #     # Format the log message
# # # # # # # # # # #     $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # # # # # # # #     # Set foreground color based on log level
# # # # # # # # # # #     switch ($Level) {
# # # # # # # # # # #         'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # # # # # # # #         'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # # # # # # #         'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # # # # # # # #         'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # # # # # # #         'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # # # # # # #         'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # # # # # # # #         default { $ForegroundColor = [ConsoleColor]::White }
# # # # # # # # # # #     }

# # # # # # # # # # #     # Write the message with the specified colors
# # # # # # # # # # #     $currentForegroundColor = $Host.UI.RawUI.ForegroundColor
# # # # # # # # # # #     $Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # # # # # # #     Write-Host $formattedMessage
# # # # # # # # # # #     $Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # # # # # # # # }



# # # # # # # # # # # class Logger {
# # # # # # # # # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # # # # # # # # #         # Ensure Get-PSCallStack has enough stack depth
# # # # # # # # # # #         if ((Get-PSCallStack).Count -ge 2) {
# # # # # # # # # # #             $callerFunction = (Get-PSCallStack)[1].Command
# # # # # # # # # # #         } else {
# # # # # # # # # # #             $callerFunction = 'UnknownFunction'
# # # # # # # # # # #         }
        
# # # # # # # # # # #         $callerClass = $this.GetType().Name
# # # # # # # # # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # # # # # # # #         # Set foreground color based on log level
# # # # # # # # # # #         $ForegroundColor = [ConsoleColor]::White
# # # # # # # # # # #         switch ($Level) {
# # # # # # # # # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # # # # # # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # # # # # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # # # # # # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # # # # # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # # # # # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # # # # # # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # # # # # # # # #         }

# # # # # # # # # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # # # # # # # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # # # # # # # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # # # # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # # # # # # #             Write-Host $formattedMessage
# # # # # # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # # # # # # # #         } else {
# # # # # # # # # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # # # # # # # # #         }
# # # # # # # # # # #     }
# # # # # # # # # # # }











# # # # # # # # # # function Write-EnhancedLog {
# # # # # # # # # #     param (
# # # # # # # # # #         [string]$Message,
# # # # # # # # # #         [string]$Level = 'INFO',
# # # # # # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # # # # # #         [switch]$UseModule = $false
# # # # # # # # # #     )

# # # # # # # # # #     $logger = [Logger]::new()
# # # # # # # # # #     $logger.LogClassCall($Message, $Level)
# # # # # # # # # # }







# # # # # # # # # class Logger {
# # # # # # # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # # # # # # #         # Ensure Get-PSCallStack has enough stack depth
# # # # # # # # #         if ((Get-PSCallStack).Count -ge 2) {
# # # # # # # # #             $callerFunction = (Get-PSCallStack)[1].Command
# # # # # # # # #         } else {
# # # # # # # # #             $callerFunction = 'UnknownFunction'
# # # # # # # # #         }

# # # # # # # # #         # Attempt to get the caller's class name, if available
# # # # # # # # #         $callerClass = 'UnknownClass'
# # # # # # # # #         if ($this -ne $null) {
# # # # # # # # #             try {
# # # # # # # # #                 $callerClass = $this.GetType().Name
# # # # # # # # #             } catch {
# # # # # # # # #                 $callerClass = 'UnknownClass'
# # # # # # # # #             }
# # # # # # # # #         }

# # # # # # # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # # # # # #         # Set foreground color based on log level
# # # # # # # # #         $ForegroundColor = [ConsoleColor]::White
# # # # # # # # #         switch ($Level) {
# # # # # # # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # # # # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # # # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # # # # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # # # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # # # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # # # # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # # # # # # #         }

# # # # # # # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # # # # # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # # # # # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # # # # #             Write-Host $formattedMessage
# # # # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # # # # # #         } else {
# # # # # # # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # # # # # # #         }
# # # # # # # # #     }
# # # # # # # # # }

# # # # # # # # # function Write-EnhancedLog {
# # # # # # # # #     param (
# # # # # # # # #         [string]$Message,
# # # # # # # # #         [string]$Level = 'INFO',
# # # # # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # # # # #         [switch]$UseModule = $false
# # # # # # # # #     )

# # # # # # # # #     $logger = [Logger]::new()
# # # # # # # # #     $logger.LogClassCall($Message, $Level)
# # # # # # # # # }

# # # # # # # # # # Example usage:
# # # # # # # # # class TestClass {
# # # # # # # # #     [Logger]$logger

# # # # # # # # #     TestClass() {
# # # # # # # # #         $this.logger = [Logger]::new()
# # # # # # # # #     }

# # # # # # # # #     [void] TestMethod() {
# # # # # # # # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # # # # # # # #     }
# # # # # # # # # }

# # # # # # # # # $testInstance = [TestClass]::new()
# # # # # # # # # $testInstance.TestMethod()















# # # # # # # # class Logger {
# # # # # # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # # # # # #         $callerFunction = 'UnknownFunction'
# # # # # # # #         $callerClass = 'UnknownClass'
        
# # # # # # # #         if ((Get-PSCallStack).Count -ge 3) {
# # # # # # # #             $callerFunction = (Get-PSCallStack)[2].Command
# # # # # # # #         }

# # # # # # # #         # Use reflection to get the calling class
# # # # # # # #         $stackFrame = [System.Diagnostics.StackTrace]::new($true).GetFrame(2)
# # # # # # # #         if ($stackFrame -ne $null) {
# # # # # # # #             $methodBase = $stackFrame.GetMethod()
# # # # # # # #             if ($methodBase -ne $null) {
# # # # # # # #                 $callerClass = $methodBase.DeclaringType.FullName
# # # # # # # #             }
# # # # # # # #         }

# # # # # # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # # # # #         # Set foreground color based on log level
# # # # # # # #         $ForegroundColor = [ConsoleColor]::White
# # # # # # # #         switch ($Level) {
# # # # # # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # # # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # # # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # # # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # # # # # #         }

# # # # # # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # # # # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # # # # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # # # #             Write-Host $formattedMessage
# # # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # # # # #         } else {
# # # # # # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # # # # # #         }
# # # # # # # #     }
# # # # # # # # }






# # # # # # # # function Write-EnhancedLog {
# # # # # # # #     param (
# # # # # # # #         [string]$Message,
# # # # # # # #         [string]$Level = 'INFO',
# # # # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # # # #         [switch]$UseModule = $false
# # # # # # # #     )

# # # # # # # #     $logger = [Logger]::new()
# # # # # # # #     $logger.LogClassCall($Message, $Level)
# # # # # # # # }

# # # # # # # # # Example usage:
# # # # # # # # class TestClass {
# # # # # # # #     [Logger]$logger

# # # # # # # #     TestClass() {
# # # # # # # #         $this.logger = [Logger]::new()
# # # # # # # #     }

# # # # # # # #     [void] TestMethod() {
# # # # # # # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # # # # # # #     }
# # # # # # # # }

# # # # # # # # $testInstance = [TestClass]::new()
# # # # # # # # $testInstance.TestMethod()





# # # # # # # class Logger {
# # # # # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # # # # #         $callerFunction = 'UnknownFunction'
# # # # # # #         $callerClass = 'UnknownClass'

# # # # # # #         # Ensure Get-PSCallStack has enough stack depth
# # # # # # #         $callStack = Get-PSCallStack
# # # # # # #         if ($callStack.Count -ge 3) {
# # # # # # #             $callerFunction = $callStack[2].Command
# # # # # # #             # The callerClass can be derived if the call is from within a class method
# # # # # # #             if ($callStack[2].Position.Line.StartsWith('[')) {
# # # # # # #                 $callerClass = $callStack[2].Position.Line.Split()[0].Trim('[', ']')
# # # # # # #             }
# # # # # # #         }

# # # # # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # # # #         # Set foreground color based on log level
# # # # # # #         $ForegroundColor = [ConsoleColor]::White
# # # # # # #         switch ($Level) {
# # # # # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # # # # #         }

# # # # # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # # # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # # # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # # #             Write-Host $formattedMessage
# # # # # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # # # #         } else {
# # # # # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # # # # #         }
# # # # # # #     }
# # # # # # # }




# # # # # # # function Write-EnhancedLog {
# # # # # # #     param (
# # # # # # #         [string]$Message,
# # # # # # #         [string]$Level = 'INFO',
# # # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # # #         [switch]$UseModule = $false
# # # # # # #     )

# # # # # # #     $logger = [Logger]::new()
# # # # # # #     $logger.LogClassCall($Message, $Level)
# # # # # # # }

# # # # # # # # Example usage:
# # # # # # # class TestClass {
# # # # # # #     [Logger]$logger

# # # # # # #     TestClass() {
# # # # # # #         $this.logger = [Logger]::new()
# # # # # # #     }

# # # # # # #     [void] TestMethod() {
# # # # # # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # # # # # #     }
# # # # # # # }

# # # # # # # $testInstance = [TestClass]::new()
# # # # # # # $testInstance.TestMethod()


# # # # # # class Logger {
# # # # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # # # #         $callerFunction = 'UnknownFunction'
# # # # # #         $callerClass = 'UnknownClass'

# # # # # #         $callStack = Get-PSCallStack

# # # # # #         # Check stack depth and capture the calling function
# # # # # #         if ($callStack.Count -ge 3) {
# # # # # #             $callerFunction = $callStack[2].Command
# # # # # #         }

# # # # # #         # Attempt to get the calling class if available
# # # # # #         $stackTrace = [System.Diagnostics.StackTrace]::new($true)
# # # # # #         for ($i = 2; $i -lt $stackTrace.FrameCount; $i++) {
# # # # # #             $frame = $stackTrace.GetFrame($i)
# # # # # #             $methodBase = $frame.GetMethod()
# # # # # #             if ($methodBase -ne $null -and $methodBase.DeclaringType -ne $null) {
# # # # # #                 $callerClass = $methodBase.DeclaringType.Name
# # # # # #                 break
# # # # # #             }
# # # # # #         }

# # # # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # # #         # Set foreground color based on log level
# # # # # #         $ForegroundColor = [ConsoleColor]::White
# # # # # #         switch ($Level) {
# # # # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # # # #         }

# # # # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # # #             Write-Host $formattedMessage
# # # # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # # #         } else {
# # # # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # # # #         }
# # # # # #     }
# # # # # # }








# # # # # # function Write-EnhancedLog {
# # # # # #     param (
# # # # # #         [string]$Message,
# # # # # #         [string]$Level = 'INFO',
# # # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # # #         [switch]$UseModule = $false
# # # # # #     )

# # # # # #     $logger = [Logger]::new()
# # # # # #     $logger.LogClassCall($Message, $Level)
# # # # # # }

# # # # # # # Example usage:
# # # # # # class TestClass {
# # # # # #     [Logger]$logger

# # # # # #     TestClass() {
# # # # # #         $this.logger = [Logger]::new()
# # # # # #     }

# # # # # #     [void] TestMethod() {
# # # # # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # # # # #     }
# # # # # # }

# # # # # # $testInstance = [TestClass]::new()
# # # # # # $testInstance.TestMethod()










# # # # # class Logger {
# # # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # # #         $callerFunction = 'UnknownFunction'
# # # # #         $callerClass = 'UnknownClass'

# # # # #         $callStack = Get-PSCallStack

# # # # #         # Check stack depth and capture the calling function
# # # # #         if ($callStack.Count -ge 3) {
# # # # #             $callerFunction = $callStack[2].Command
# # # # #         }

# # # # #         # Attempt to get the calling class if available
# # # # #         $stackTrace = [System.Diagnostics.StackTrace]::new($true)
# # # # #         for ($i = 2; $i -lt $stackTrace.FrameCount; $i++) {
# # # # #             $frame = $stackTrace.GetFrame($i)
# # # # #             $methodBase = $frame.GetMethod()
# # # # #             if ($methodBase -ne $null -and $methodBase.DeclaringType -ne $null) {
# # # # #                 # Check if the declaring type is not a PowerShell internal type
# # # # #                 if ($methodBase.DeclaringType.FullName -notmatch '^System\.Management\.Automation') {
# # # # #                     $callerClass = $methodBase.DeclaringType.FullName
# # # # #                     break
# # # # #                 }
# # # # #             }
# # # # #         }

# # # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # # #         # Set foreground color based on log level
# # # # #         $ForegroundColor = [ConsoleColor]::White
# # # # #         switch ($Level) {
# # # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # # #         }

# # # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # # #             Write-Host $formattedMessage
# # # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # # #         } else {
# # # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # # #         }
# # # # #     }
# # # # # }










# # # # # function Write-EnhancedLog {
# # # # #     param (
# # # # #         [string]$Message,
# # # # #         [string]$Level = 'INFO',
# # # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # # #         [switch]$UseModule = $false
# # # # #     )

# # # # #     $logger = [Logger]::new()
# # # # #     $logger.LogClassCall($Message, $Level)
# # # # # }

# # # # # # Example usage:
# # # # # class TestClass {
# # # # #     [Logger]$logger

# # # # #     TestClass() {
# # # # #         $this.logger = [Logger]::new()
# # # # #     }

# # # # #     [void] TestMethod() {
# # # # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # # # #     }
# # # # # }

# # # # # $testInstance = [TestClass]::new()
# # # # # $testInstance.TestMethod()












# # # # class Logger {
# # # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # # #         $callerFunction = 'UnknownFunction'
# # # #         $callerClass = 'UnknownClass'

# # # #         # Get the PowerShell call stack
# # # #         $callStack = Get-PSCallStack

# # # #         # Check stack depth and capture the calling function
# # # #         if ($callStack.Count -ge 3) {
# # # #             $callerFunction = $callStack[2].Command
# # # #         }

# # # #         # Use .NET stack trace to get the calling class
# # # #         $stackTrace = [System.Diagnostics.StackTrace]::new($true)
# # # #         for ($i = 2; $i -lt $stackTrace.FrameCount; $i++) {
# # # #             $frame = $stackTrace.GetFrame($i)
# # # #             $methodBase = $frame.GetMethod()
# # # #             if ($methodBase -ne $null -and $methodBase.DeclaringType -ne $null) {
# # # #                 $declaringType = $methodBase.DeclaringType
# # # #                 # Exclude internal PowerShell and .NET infrastructure calls
# # # #                 if ($declaringType.Namespace -notmatch '^System\.|^Microsoft\.|^PSCustomObject$|^PSObject$') {
# # # #                     $callerClass = $declaringType.FullName
# # # #                     break
# # # #                 }
# # # #             }
# # # #         }

# # # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # # #         # Set foreground color based on log level
# # # #         $ForegroundColor = [ConsoleColor]::White
# # # #         switch ($Level) {
# # # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # # #             default { $ForegroundColor = [ConsoleColor]::White }
# # # #         }

# # # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # # #             Write-Host $formattedMessage
# # # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # # #         } else {
# # # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # # #         }
# # # #     }
# # # # }



# # # # function Write-EnhancedLog {
# # # #     param (
# # # #         [string]$Message,
# # # #         [string]$Level = 'INFO',
# # # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # # #         [switch]$UseModule = $false
# # # #     )

# # # #     $logger = [Logger]::new()
# # # #     $logger.LogClassCall($Message, $Level)
# # # # }

# # # # # Example usage:
# # # # class TestClass {
# # # #     [Logger]$logger

# # # #     TestClass() {
# # # #         $this.logger = [Logger]::new()
# # # #     }

# # # #     [void] TestMethod() {
# # # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # # #     }
# # # # }

# # # # $testInstance = [TestClass]::new()
# # # # $testInstance.TestMethod()





# # # class Logger {
# # #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# # #         $callerFunction = 'UnknownFunction'
# # #         $callerClass = 'UnknownClass'

# # #         # Get the PowerShell call stack
# # #         $callStack = Get-PSCallStack

# # #         # Check stack depth and capture the calling function
# # #         if ($callStack.Count -ge 3) {
# # #             $callerFunction = $callStack[2].Command
# # #         }

# # #         # Use .NET stack trace to get the calling class
# # #         $stackTrace = [System.Diagnostics.StackTrace]::new($true)
# # #         for ($i = 2; $i -lt $stackTrace.FrameCount; $i++) {
# # #             $frame = $stackTrace.GetFrame($i)
# # #             $methodBase = $frame.GetMethod()
# # #             if ($methodBase -ne $null -and $methodBase.DeclaringType -ne $null) {
# # #                 # Check if the declaring type is not a PowerShell internal type
# # #                 if ($methodBase.DeclaringType.FullName -notmatch '^System\.|^Microsoft\.') {
# # #                     $callerClass = $methodBase.DeclaringType.FullName
# # #                     break
# # #                 }
# # #             }
# # #         }

# # #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# # #         # Set foreground color based on log level
# # #         $ForegroundColor = [ConsoleColor]::White
# # #         switch ($Level) {
# # #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# # #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# # #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# # #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# # #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# # #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# # #             default { $ForegroundColor = [ConsoleColor]::White }
# # #         }

# # #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# # #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# # #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# # #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# # #             Write-Host $formattedMessage
# # #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# # #         } else {
# # #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# # #         }
# # #     }
# # # }













# # # function Write-EnhancedLog {
# # #     param (
# # #         [string]$Message,
# # #         [string]$Level = 'INFO',
# # #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# # #         [switch]$UseModule = $false
# # #     )

# # #     $logger = [Logger]::new()
# # #     $logger.LogClassCall($Message, $Level)
# # # }

# # # # Example usage:
# # # class TestClass {
# # #     [Logger]$logger

# # #     TestClass() {
# # #         $this.logger = [Logger]::new()
# # #     }

# # #     [void] TestMethod() {
# # #         Write-EnhancedLog -Message "This is a test message from TestClass."
# # #     }
# # # }

# # # $testInstance = [TestClass]::new()
# # # $testInstance.TestMethod()










# # class Logger {
# #     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
# #         $callerFunction = 'UnknownFunction'
# #         $callerClass = 'UnknownClass'

# #         # Get the PowerShell call stack
# #         $callStack = Get-PSCallStack

# #         # Check stack depth and capture the calling function
# #         if ($callStack.Count -ge 3) {
# #             $callerFunction = $callStack[2].Command
# #         }

# #         # Use .NET stack trace to get the calling class
# #         $stackTrace = [System.Diagnostics.StackTrace]::new($true)
# #         for ($i = 2; $i -lt $stackTrace.FrameCount; $i++) {
# #             $frame = $stackTrace.GetFrame($i)
# #             $methodBase = $frame.GetMethod()
# #             if ($null -ne $methodBase -and $null -ne $methodBase.DeclaringType) {
# #                 # Check if the declaring type is not a PowerShell internal type
# #                 if ($methodBase.DeclaringType.FullName -notmatch '^System\.|^Microsoft\.') {
# #                     $callerClass = $methodBase.DeclaringType.FullName
# #                     break
# #                 }
# #             }
# #         }

# #         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [Class: $callerClass] [Function: $callerFunction] $Message"

# #         # Set foreground color based on log level
# #         $ForegroundColor = [ConsoleColor]::White
# #         switch ($Level) {
# #             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
# #             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
# #             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
# #             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
# #             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
# #             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
# #             default { $ForegroundColor = [ConsoleColor]::White }
# #         }

# #         # Check if $Host.UI.RawUI.ForegroundColor is accessible
# #         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
# #             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
# #             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
# #             Write-Host $formattedMessage
# #             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
# #         } else {
# #             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
# #         }
# #     }
# # }






# # function Write-EnhancedLog {
# #     param (
# #         [string]$Message,
# #         [string]$Level = 'INFO',
# #         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
# #         [switch]$UseModule = $false
# #     )

# #     $logger = [Logger]::new()
# #     $logger.LogClassCall($Message, $Level)
# # }

# # # Example usage:
# # class TestClass {
# #     [Logger]$logger

# #     TestClass() {
# #         $this.logger = [Logger]::new()
# #     }

# #     [void] TestMethod() {
# #         Write-EnhancedLog -Message "This is a test message from TestClass."
# #     }
# # }

# # $testInstance = [TestClass]::new()
# # $testInstance.TestMethod()




# class Logger {
#     [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
#         $callerFunction = ''
#         $callerClass = ''

#         # Get the PowerShell call stack
#         $callStack = Get-PSCallStack

#         # Check stack depth and capture the calling function if it exists
#         if ($callStack.Count -ge 3) {
#             $callerFunction = $callStack[2].Command
#         }

#         # Use .NET stack trace to get the calling class if it exists
#         $stackTrace = [System.Diagnostics.StackTrace]::new($true)
#         for ($i = 2; $i -lt $stackTrace.FrameCount; $i++) {
#             $frame = $stackTrace.GetFrame($i)
#             $methodBase = $frame.GetMethod()
#             if ($methodBase -ne $null -and $methodBase.DeclaringType -ne $null) {
#                 # Check if the declaring type is not a PowerShell internal type
#                 if ($methodBase.DeclaringType.FullName -notmatch '^System\.|^Microsoft\.') {
#                     $callerClass = $methodBase.DeclaringType.FullName
#                     break
#                 }
#             }
#         }

#         $callerInfo = ''
#         if ($callerClass) {
#             $callerInfo += "[Class: $callerClass] "
#         }
#         if ($callerFunction) {
#             $callerInfo += "[Function: $callerFunction]"
#         }

#         $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] $callerInfo $Message"

#         # Set foreground color based on log level
#         $ForegroundColor = [ConsoleColor]::White
#         switch ($Level) {
#             'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
#             'INFO' { $ForegroundColor = [ConsoleColor]::Green }
#             'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
#             'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
#             'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
#             'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
#             default { $ForegroundColor = [ConsoleColor]::White }
#         }

#         # Check if $Host.UI.RawUI.ForegroundColor is accessible
#         if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
#             $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
#             $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
#             Write-Host $formattedMessage
#             $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
#         } else {
#             Write-Host $formattedMessage -ForegroundColor $ForegroundColor
#         }
#     }
# }



# function Write-EnhancedLog {
#     param (
#         [string]$Message,
#         [string]$Level = 'INFO',
#         [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
#         [switch]$UseModule = $false
#     )

#     $logger = [Logger]::new()
#     $logger.LogClassCall($Message, $Level)
# }

# # Example usage:
# class TestClass {
#     [Logger]$logger

#     TestClass() {
#         $this.logger = [Logger]::new()
#     }

#     [void] TestMethod() {
#         Write-EnhancedLog -Message "This is a test message from TestClass."
#     }
# }

# $testInstance = [TestClass]::new()
# $testInstance.TestMethod()


class Logger {
    [void] LogClassCall([string]$Message, [string]$Level = 'INFO') {
        $callerFunction = ''
        $callerClass = ''

        # Get the PowerShell call stack
        $callStack = Get-PSCallStack

        # Determine the correct index based on the call stack depth
        $stackIndex = if ($callStack.Count -ge 3) { 2 } else { 1 }

        # Capture the calling function if it exists
        if ($callStack.Count -ge $stackIndex + 1) {
            $callerFunction = $callStack[$stackIndex].Command
        }

        # Use .NET stack trace to get the calling class if it exists
        $stackTrace = [System.Diagnostics.StackTrace]::new($true)
        for ($i = $stackIndex + 1; $i -lt $stackTrace.FrameCount; $i++) {
            $frame = $stackTrace.GetFrame($i)
            $methodBase = $frame.GetMethod()
            if ($methodBase -ne $null -and $methodBase.DeclaringType -ne $null) {
                # Check if the declaring type is not a PowerShell internal type
                if ($methodBase.DeclaringType.FullName -notmatch '^System\.|^Microsoft\.') {
                    $callerClass = $methodBase.DeclaringType.FullName
                    break
                }
            }
        }

        $callerInfo = ''
        if ($callerClass) {
            $callerInfo += "[Class: $callerClass] "
        }
        if ($callerFunction) {
            $callerInfo += "[Function: $callerFunction]"
        }

        $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] $callerInfo $Message"

        # Set foreground color based on log level
        $ForegroundColor = [ConsoleColor]::White
        switch ($Level) {
            'DEBUG' { $ForegroundColor = [ConsoleColor]::Gray }
            'INFO' { $ForegroundColor = [ConsoleColor]::Green }
            'NOTICE' { $ForegroundColor = [ConsoleColor]::Cyan }
            'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
            'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
            'CRITICAL' { $ForegroundColor = [ConsoleColor]::Magenta }
            default { $ForegroundColor = [ConsoleColor]::White }
        }

        # Check if $Host.UI.RawUI.ForegroundColor is accessible
        if ($global:Host -and $global:Host.UI -and $global:Host.UI.RawUI) {
            $currentForegroundColor = $global:Host.UI.RawUI.ForegroundColor
            $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
            Write-Host $formattedMessage
            $global:Host.UI.RawUI.ForegroundColor = $currentForegroundColor
        } else {
            Write-Host $formattedMessage -ForegroundColor $ForegroundColor
        }
    }
}







function Write-EnhancedLog {
    param (
        [string]$Message,
        [string]$Level = 'INFO',
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
        [switch]$UseModule = $false
    )

    $logger = [Logger]::new()
    $logger.LogClassCall($Message, $Level)
}

# Example usage:
class TestClass {
    [Logger]$logger

    TestClass() {
        $this.logger = [Logger]::new()
    }

    [void] TestMethod() {
        Write-EnhancedLog -Message "This is a test message from TestClass."
    }
}

# Direct call to Write-EnhancedLog for testing
Write-EnhancedLog -Message "This is a direct test message."

$testInstance = [TestClass]::new()
$testInstance.TestMethod()

