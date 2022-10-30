# WinLoginAudit
# @jacauc - 09 Jan 2018 
# IMPORTANT! Please add your own Telegram Bot chat ID to the following variables.
 
$tokenID = "123456789:ABC-DEFghIJkLMNOPqrstUvWxYZ"
$chatsID = "-098765432", "-123456789"
# Note: group ID's typically start with a minus sign


# Logon Types
$LogonType = $(1 .. 12)
$LogonType[0] = "ERROR"
$LogonType[1] = "ERROR"
$LogonType[2] = "Interactive"
$LogonType[3] = "Network"
$LogonType[4] = "Batch" 
$LogonType[5] = "Service" 
$LogonType[7] = "Unlock"
$LogonType[8] = "NetworkCleartext"
$LogonType[9] = "NewCredentials"
$LogonType[10] = "RemoteInteractive"
$LogonType[11] = "CachedInteractive"


$filterXml = "
<QueryList>
  <Query Id='0' Path='Security'>
    <Select Path='Security'>
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
</QueryList>"


# Query the server for the login events. Attach this powershell script to Windows Scheduler on events  with custom XML event for 4624 and 4625 
# Create a custom event filter for 4624 events to prevent login notification for the scheduled task itself as it authenticates. See the github repo for the scheduled task to import

$colEvents = Get-WinEvent -FilterXml $filterXml 

# Iterate through the collection of login events. 
$Result = @()
Foreach ($Entry in $colEvents) 
{ 
    $EvtSourceIP = ""
	$SourceIPPresent = ""
	
	# Extract Logon Type Number
	$EvtLogonTypeNum = $Entry.Properties[8].Value
	
	# Extract "real" username
	$EvtLogonUser = $Entry.Properties[5].Value

	# Extract "real" domain	
	$EvtLogonDomain = $Entry.Properties[2].Value
	
	#extract Event ID number
	$EvtID = $Entry.Id 
   
	#Convert logontype number to string
	$EvtLogonTypeDesc = $LogonType[$EvtLogonTypeNum] 
	  	 
	#extract time event was generated and convert to standard format
	$TimeGenerated = $Entry.TimeCreated.ToString("dd-MMM-yyyy HH:mm:ss")
   
	# Filter out some of the 4624 (success) events 
	If ($EvtID -eq "4624") 
	{ 
		$EvtSourceIP = $Entry.Properties[18].Value	
		If (($EvtSourceIP -ne "") -and ($EvtSourceIP -ne "-") -and ($EvtSourceIP -ne "::1")) 
			{
				$SourceIPPresent = "*Source IP*: $EvtSourceIP`n"
		}
		$Result += @("`n*Time*: $TimeGenerated `n*User*: $EvtLogonDomain\$EvtLogonUser `n*Result*: Success ($EvtLogonTypeDesc)`n$SourceIPPresent")
	} 
   
	# Filter out some of the 4625 (failed) events  
	If ($EvtID -eq "4625") 
	{ 
		$EvtSourceIP = $Entry.Properties[19].Value
		If (($EvtSourceIP -ne "") -and ($EvtSourceIP -ne "-") -and ($EvtSourceIP -ne "::1")) 
			{
				$SourceIPPresent = "*Source IP*: $EvtSourceIP`n"
			}
		$Result += @("`n*Time*: $TimeGenerated `n*User*: $EvtLogonDomain\$EvtLogonUser `n*Result*: Fail`n$SourceIPPresent")
	} 
}

#if no results were returned, exit immediately and do not send Telegram message
#if ($result.count -eq 0) { exit }

#Remove duplicate events
$result = $result |Sort-Object -Unique

# obtain computer IP address
$ip = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address

# convert IP address to string
$ip = $ip.IPAddressToString

#output the results to Telegram using an HTTP GET request
foreach( $chatID in $chatsID) {
	curl "https://api.telegram.org/bot$tokenID/sendMessage?chat_id=$chatID&parse_mode=Markdown&text=*System Login Activity* %0A*$env:COMPUTERNAME* : $ip $result"
}
