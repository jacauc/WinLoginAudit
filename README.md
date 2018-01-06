# Receive instant SUCCESSFUL or FAILED windows login attempt notifications on your Telegram chat app (Android/IOS/Windows/MAC)  
<span style="color:green;"> text goes here</span>

This is a windows scheduled task to run a powershell script whenever a successful (Event ID 4624) or failed (Event ID 4625) login event is detected in the windows event log.

The powershell script will execute and parse the event log to find the event that triggered the scheduled task.
The valuable information is then sent to a Telegram Chat Bot (Please add your own directly into the code)

You will be able to get instant Telegram messages whenever someone successfully or unsuccessfully tries to login to your Windows Computer. This allows you to improve your security posture and become aware of malicious attempts to access your resources, whether manually attempted, or done by a bot with a passwordlist to attempt brute force logins to your Windows Machine.

To install, import the XML scheduled task and allow it to run as an administrative user. Point the powershell argument to the location of where you saved the edited .ps1 script file.

Edit the .ps1 script directly, and add your telegram bot token and ID in the script.

Pull requests or improvement suggestions welcome as this is Beta code.

# Create a bot

Simple instructions for setting up the Telegram Bot https://www.forsomedefinition.com/automation/creating-telegram-bot-notifications/:

Simplified instructions:
0. Use telegram
1. Chat with @botfather
2. Type /newbot
3. Give your bot a name... e.g. mywinloginaudit
4. Give your bot a username... e.g. mywinloginauditbot
5. You will get a message like this:

![2018-01-06_15-53-12](https://user-images.githubusercontent.com/18201320/34640372-fd5d8314-f2f9-11e7-9b86-c9a30ee889b2.png)

6. RECORD THE TOKEN SHOWN IN THE MESSAGE
7. Start a chat with your bot and type /start
8. Exit aforementioned chat and create a Telegram Group conversation. Call it something like "System Notifications"
9. Invite your bot to the group.
10. Access the following page (insert your bot's TOKEN and remove the <<< and >>> characters): https://api.telegram.org/bot<<<TOKEN>>>/getUpdates
11. Look for the group's ID as shown in green below. The group ID will normally be preceded by a minus sign. Record this ID:

![2018-01-06_16-06-23](https://user-images.githubusercontent.com/18201320/34640491-4faaa5f0-f2fc-11e7-853e-72cc5b1df323.png)

12. Do a test - You should now get a hello world message in the telegram group from your bot. If this didn't work, check steps 1-11 again. 
  ```
  https://api.telegram.org/bot<<<TOKEN>>>/sendMessage?chat_id=<<<GROUPID>>>&text=Hello+World
  ```



# Edit Security Policy
Run secpol.msc on the machine and navigate to Security Settings > Local Policies > Audit Policy and change the "Audit account logon events" and "Audit logon events" policies to audit SUCCESS and FAILURE events

![2018-01-06_15-17-58](https://user-images.githubusercontent.com/18201320/34640213-21fb131a-f2f7-11e7-81a3-8254ade34998.png)
