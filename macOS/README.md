Based on the provided images and instructions, here is the script to uninstall FortiClient on macOS:

```bash
#!/bin/bash
# Uninstall FortiClient.sh
# This script will completely uninstall FortiClient and all supporting components

pkill FortiClientAgent
launchctl unload /Library/LaunchDaemons/com.fortinet*

rm -Rf /Applications/FortiClient.app
rm -Rf /Applications/FortiClientUninstaller.app
rm -Rf /Library/Application\ Support/Fortinet
rm -Rf /Library/Internet\ Plug-Ins/FortiClient_SSLVPN_Plugin.bundle
rm -Rf /Library/LaunchDaemons/com.fortinet.fct_launcher.plist
rm -Rf /Library/LaunchDaemons/com.fortinet.forticlient.fct_hook.plist
rm -Rf /Library/LaunchDaemons/com.fortinet.forticlient.ig.plist
rm -Rf /Library/LaunchDaemons/com.fortinet.forticlient.epctrl.plist
rm -Rf /Library/LaunchDaemons/com.fortinet.forticlient.fssoagent_launchdaemon.plist
rm -Rf /Library/LaunchDaemons/com.fortinet.forticlient.mdm.plist
rm -Rf /Library/LaunchDaemons/com.fortinet.forticlient.vpn.plist

localAccounts=$(dscl . list /Users UniqueID | awk '$2 > 500 { print $1 }')

for user in $localAccounts
do
  rm -Rf /Users/"$user"/Library/Application\ Support/Fortinet/
done
```

### Instructions for using the script:

1. **Create the Script File:**
   - Open a text editor (e.g., TextEdit).
   - Copy and paste the above script into the new document.
   - Save the document with a `.sh` extension, for example, `uninstall_forticlient.sh`. If saving with `.sh` is not allowed, save it with a `.rtf` extension first and then rename it to `.sh`.

2. **Make the Script Executable:**
   - Open Terminal on the Mac.
   - Navigate to the folder where the script is saved using the `cd` command. For example, if the script is saved on the Desktop, navigate there with:
     ```sh
     cd ~/Desktop
     ```
   - Make the script executable by running:
     ```sh
     chmod +x uninstall_forticlient.sh
     ```

3. **Run the Script:**
   - Execute the script with sudo privileges to uninstall FortiClient:
     ```sh
     sudo ./uninstall_forticlient.sh
     ```
   - Enter the admin password when prompted.

### Note:
- This script will locate and remove FortiClient application files and related configuration files.
- Use it with caution and ensure to have a backup of any important data or configurations associated with FortiClient before running the script.
