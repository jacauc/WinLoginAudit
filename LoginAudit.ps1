# @jacauc - 11 December 2017
# IMPORTANT! Please add your own Telegram Bot chat ID to the end of this script, and remove the >>> and <<< characters before and after the placeholders!
# Your botID may look like this dummy example: 551850262:AAE-SCP0ttF4LD9HgcVNjvUOkyX5UlGERxw
# your Group chatID may look like this dummy example: -123456789 (note the minus sign in front)

# Then the URL should look similar to this after editing:
# curl "https://api.telegram.org/bot551850262:AAE-SCP0ttF4LD9HgcVNjvUOkyX5UlGERxw/sendMessage?chat_id=-123456789&parse_mode=Markdown&text=*System Login Activity* %0A*$env:COMPUTERNAME* : $ip $result"
 

# Query the server for the login events. Attached this powershell script to Windows Scheduler on events 4625, and custom XML event for 4624

# Create a custom event filter for 4624 events to prevent login notification for the scheduled task itself as it authenticates. See the github repo for the XML code
$colEvents = Get-EventLog -Newest 20 -LogName Security -InstanceId 4624,4625 | Where-Object { $_.TimeGenerated -ge (Get-Date).AddMinutes(-1)}
 
 
# Iterate through the collection of login events. 
$Result = @()
Foreach ($Entry in $colEvents) 
{ 
  If  (($Entry.ReplacementStrings[8]-eq "2") -and ($Entry.ReplacementStrings[5]-ne "-") -and ($Entry.ReplacementStrings[6]-ne "Window Manager")) 
  { 
    $TimeGenerated = $Entry.TimeGenerated.ToString("MMM-dd h:mm:ss")
    $Domain = $Entry.ReplacementStrings[2]
    $Username = $Entry.ReplacementStrings[5]
    $Result += @("`n*Time*: $TimeGenerated `n*User*: $Domain\$Username `n*Result*: Success`n")
    #$Result 
    
  } 
  If  (($Entry.ReplacementStrings[8]-eq "10") -and ($Entry.ReplacementStrings[5]-ne "-"))  
  { 
    $TimeGenerated = $Entry.TimeGenerated.ToString("MMM-dd h:mm:ss")
    $Domain = $Entry.ReplacementStrings[2]
    $Username = $Entry.ReplacementStrings[5]
    $Result += @("`n*Time*: $TimeGenerated `n*User*: $Domain\$Username `n*Result*: Success (RDP)`n")
    #$Result 
    
  } 
  If (($Entry.InstanceId -eq "4625") -and ($Entry.ReplacementStrings[5]-ne "-")) 
  { 
    $TimeGenerated = $Entry.TimeGenerated.ToString("MMM-dd h:mm:ss")
    $Domain = $Entry.ReplacementStrings[2]
    $Username = $Entry.ReplacementStrings[5]
    $Result += @("`n*Time*: $TimeGenerated `n*User*: $Domain\$Username `n*Result*: Fail`n")
    #$Result 
  } 
}

#if no results were returned, exit immediately and do not send Telegram message
if ($result.count -eq 0) { exit }

 $result = $result |Sort-Object -Unique
 #$result
#$FailedLogin= $eventsDC."UserName"
$ip = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address
$ip = $ip.IPAddressToString

 
 curl "https://api.telegram.org/bot<<<INSERTTOKENHERE>>>/sendMessage?chat_id=<<<INSERCHATIDHERE>>>&parse_mode=Markdown&text=*System Login Activity* %0A*$env:COMPUTERNAME* : $ip $result"
 



