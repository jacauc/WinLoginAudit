# Jacques Aucamp - 30 October 2017
# Query the server for the login events. Attached this powershell script to Windows Scheduler on events 4625, and custom XML event for 4624

<#
Create a custom event filter for 4624 events to prevent login notification for the scheduled task itself as it authenticates
#############
<QueryList>
 <Query Id="0" Path="Security">
 <Select Path="Security">
  *[System[EventID=4624]
    and
    EventData[Data[@Name='LogonType'] and (Data='2' or Data='10')]
    and
    EventData[Data[@Name='TargetUserName']!='system']
    and
    EventData[Data[@Name='TargetUserName']!='ANONYMOUS LOGON']
    and
    EventData[Data[@Name='TargetUserName']!='DWM-1']
    and
    EventData[Data[@Name='TargetUserName']!='DWM-2']
    and
    EventData[Data[@Name='TargetUserName']!='DWM-3']
    and
    EventData[Data[@Name='TargetUserName']!='LOCAL SERVICE']
    and
    EventData[Data[@Name='TargetUserName']!='NETWORK SERVICE']
  ]
  </Select>
 </Query>
</QueryList>
#############
#>
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

 $result = $result |Sort-Object -Unique
 #$result
#$FailedLogin= $eventsDC."UserName"
$ip = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address
$ip = $ip.IPAddressToString

 
 curl "https://api.telegram.org/----INSERTTOKENHERE----/sendMessage?chat_id=-----INSERCHATIDHERE----&parse_mode=Markdown&text=*System Login Activity* %0A*$env:COMPUTERNAME* : $ip $result"
 



