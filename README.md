# Receive instant SUCCESSFUL or FAILED windows login attempt notifications on your Telegram chat app (Android/IOS/Windows/MAC) 

[![Donate Bitcoin](https://user-images.githubusercontent.com/18201320/42027759-bdec89d8-7aca-11e8-91b4-f36648eb0ae7.png)](https://jacauc.github.io/donate-bitcoin/)


This is a windows scheduled task to run a powershell script whenever a successful (Event ID 4624) or failed (Event ID 4625) login event is detected in the windows event log.

The powershell script will execute and parse the event log to find the event that triggered the scheduled task.
The valuable information is then sent to a Telegram Chat Bot. (Please add your own directly into the code)

You will be able to get instant Telegram messages whenever someone successfully or unsuccessfully tries to login to your Windows Computer. This allows you to improve your security posture and become aware of malicious attempts to access your resources, whether manually attempted, or done by a bot with a passwordlist to attempt brute force logins to your Windows Machine.

To install, import the XML scheduled task and allow it to run as an administrative user. Point the powershell argument to the location of where you saved the edited .ps1 script file.

Edit the .ps1 script directly, and add your telegram bot token and ID in the script.

Pull requests or improvement suggestions welcome as this is Beta code.

# Create a bot

Detailed instructions for setting up the Telegram Bot: https://www.forsomedefinition.com/automation/creating-telegram-bot-notifications/

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
8. Type a test message for the bot like "hello"
9. Exit aforementioned chat and create a Telegram Group conversation. Call it something like "System Notifications"
10. Invite your bot to the group.
11. Access the following page (insert your bot's TOKEN and remove the <<< and >>> characters): 
```
https://api.telegram.org/bot<<<TOKEN>>>/getUpdates
```
12. Look for the group's ID as shown in green below. The group ID will normally be preceded by a minus sign. RECORD THE GROUPID:

![2018-01-06_16-06-23](https://user-images.githubusercontent.com/18201320/34640491-4faaa5f0-f2fc-11e7-853e-72cc5b1df323.png)

13. Do a test - You should now get a hello world message in the telegram group from your bot. If this didn't work, check steps 1-11 again. 
  ```
  https://api.telegram.org/bot<<<TOKEN>>>/sendMessage?chat_id=<<<-GROUPID>>>&text=Hello+World
  ```
14. Keep your GROUPID and TOKEN and replace the values accordingly in the .ps1 powershell script file.

# Enable Powershell Scripts
1. Open PowerShell as an Administrator on the windows machine
2. Type:
```
set-executionpolicy remotesigned
```
3. Type A and press Enter

![2018-01-06_16-30-40](https://user-images.githubusercontent.com/18201320/34640635-0fd9e8de-f2ff-11e7-9081-e6ac47c640d2.png)



# Edit Security Policy
Run secpol.msc on the machine and navigate to Security Settings > Local Policies > Audit Policy and change the "Audit account logon events" and "Audit logon events" policies to audit SUCCESS and FAILURE events

![2018-01-06_15-17-58](https://user-images.githubusercontent.com/18201320/34640213-21fb131a-f2f7-11e7-81a3-8254ade34998.png)


# Import the Scheduled task XML
1. Open Windows Task Scheduler
2. Select "Import Task"

![2018-01-06_16-34-00](https://user-images.githubusercontent.com/18201320/34640660-78298f52-f2ff-11e7-80c8-4f2877699e52.png)

3. Import the MonitorLoginsTask.XML file
4. Change the task name if necessary
5. On the "Actions" tab, ensure the parameter of the Powershell action points to the actual location of the edited LoginAudit.ps1 file (your TOKEN and GROUPID should already be saved into this file.)
6. On the "General" tab, click on "Change User or Group" and select a local administrative user.
7. Click OK and type the correct password for aforementioned user.

NOTE: The scheduled task is created to filter out 4624 and 4625 events as follows, since a successful execution of the scheduled task itself, will generate an event in the log, thus without the filter, the task will enter into and endless loop.
```
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
	*[System[EventID=4624]
	and
	EventData[Data[@Name='LogonType'] != '4']
	and 
	EventData[Data[@Name='LogonType'] != '5']
	and
	EventData[Data[@Name='SubjectUserSid']!='S-1-0-0']
	and
	EventData[Data[@Name='TargetDomainName']!='Window Manager']
	and
	EventData[Data[@Name='TargetDomainName']!='Font Driver Host']
	and
	( System[TimeCreated[timediff(@SystemTime) &lt;= 60000]])
	]
	
	or
	
	*[System[EventID=4625] 
	and
	EventData[Data[@Name='LogonType'] != '4']
	and 
	EventData[Data[@Name='LogonType'] != '5']
	and
	( System[TimeCreated[timediff(@SystemTime) &lt;= 60000]])
	]
  </Select>
  </Query>
</QueryList>
```

# Test it out
1. Open a command prompt window and type:
```
runas /user:test cmd
```
2. Press Enter, Type any password and press Enter again
3. You should now get an instant telegram message indicating the failed login attempt

![2018-01-06_16-40-22](https://user-images.githubusercontent.com/18201320/34640711-63ec9b32-f300-11e7-8b8c-c1ce1a447d49.png)

[![Donate Bitcoin](https://user-images.githubusercontent.com/18201320/42027759-bdec89d8-7aca-11e8-91b4-f36648eb0ae7.png)](https://jacauc.github.io/donate-bitcoin/)
