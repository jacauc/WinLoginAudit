# Receive instant SUCCESSFUL or FAILED windows login attempt notifications on your Telegram chat app (Android/IOS/Windows/MAC)  

This is a windows scheduled task to run a powershell script whenever a successful (Event ID 4624) or failed (Event ID 4625) login event is detected in the windows event log.

The powershell script will execute and parse the event log to find the event that triggered the scheduled task.
The valuable information is then sent to a Telegram Chat Bot (Please add your own directly into the code)

You will be able to get instant Telegram messages whenever someone successfully or unsuccessfully tries to login to your Windows Computer. This allows you to improve your security posture and become aware of malicious attempts to access your resources, whether manually attempted, or done by a bot with a passwordlist to attempt brute force logins to your Windows Machine.

To install, import the XML scheduled task and allow it to run as an administrative user. Point the powershell argument to the location of where you saved the .ps1 script file.

Edit the .ps1 script directly, and add your telegram bot token and ID in the script.

Pull requests or improvement suggestions welcome as this is Beta code.

More details on creating your own Telegram bot can be found at https://api.telegram.org



Run secpol.msc on the machine and navigate to Security Settings > Local Policies > Audit Policy and change the "Audit account logon events" and "Audit logon events" policies to audit SUCCESS and FAILURE events

