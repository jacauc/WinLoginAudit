# WinLoginAudit
# @jacauc - 09 Jan 2018 
# IMPORTANT! Please add your own Telegram Bot chat ID to the following variables.
 
$tokenID = "123456789:ABC-DEFghIJkLMNOPqrstUvWxYZ"
$chatID = "-098765432"
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


$ReportingEnabled = $(1 .. 12)
$ReportingEnabled[0] = "N/A"
$ReportingEnabled[1] = "N/A"
$ReportingEnabled[2] = "YES"
$ReportingEnabled[3] = "NO" #(We filter these out to prevent excessive notifications)
$ReportingEnabled[4] = "NO" #(We filter these out to prevent excessive notifications)
$ReportingEnabled[5] = "NO" #(We filter these out to prevent excessive notifications)
$ReportingEnabled[7] = "YES"
$ReportingEnabled[8] = "YES"
$ReportingEnabled[9] = "YES"
$ReportingEnabled[10] = "YES"
$ReportingEnabled[11] = "YES"

# Query the server for the login events. Attach this powershell script to Windows Scheduler on events 4625, and custom XML event for 4624
# Create a custom event filter for 4624 events to prevent login notification for the scheduled task itself as it authenticates. See the github repo for the XML code

$colEvents = Get-EventLog -Newest 20 -LogName Security -InstanceId 4624,4625 | Where-Object { $_.TimeGenerated -ge (Get-Date).AddMinutes(-1)}
 
 
# Iterate through the collection of login events. 
$Result = @()
Foreach ($Entry in $colEvents) 
{ 
	# Extract Logon Type Number
	$EvtLogonTypeNum = $Entry.ReplacementStrings[8]
	
	# If logontype is batch or service, skip this item and move to the next. 
	If (($EvtLogonTypeNum -eq "4") -or ($EvtLogonTypeNum -eq "5")){continue}
	
	# Extract "real" username
	$EvtLogonUser = $Entry.ReplacementStrings[5]

	# Extract Internal Username
	$EvtLogonUser2 = $Entry.ReplacementStrings[1]

	# If logonuser is - or SYSTEM, skip this item and move to the next. 
	If (($EvtLogonUser2 -eq "-") -or ($EvtLogonUser2 -eq "SYSTEM")) {continue}	  
	  
	# Extract "real" domain	
	$EvtLogonDomain = $Entry.ReplacementStrings[2]
	
	# Extract internal domain	
	$EvtLogonDomain2 = $Entry.ReplacementStrings[6]
	
	# If logondomain is "Window Manager" or "Font Driver Host", skip this item and move to the next. 
	If (($EvtLogonDomain2 -eq "Window Manager") -or ($EvtLogonDomain2 -eq "Font Driver Host")) {continue}
  
	#extract Event ID number
	$EvtID = $Entry.InstanceId 
   
	#Convert logontype number to string
	$EvtLogonTypeDesc = $LogonType[$EvtLogonTypeNum] 
	  	 
	#extract time event was generated and convert to standard format
	$TimeGenerated = $Entry.TimeGenerated.ToString("dd-MMM-yyyy HH:mm:ss")
   
	# Filter out some of the 4624 (success) events and logon type = 2 (Interactive)
	If ($EvtID -eq "4624") 
	{ 
		#Check if this event should be ignored
		If ($ReportingEnabled[$EvtLogonTypeNum] -ne "NO")
		{
			$Result += @("`n*Time*: $TimeGenerated `n*User*: $EvtLogonDomain\$EvtLogonUser `n*Result*: Success ($EvtLogonTypeDesc)`n")
		}
	} 
   
	# Filter out some of the 4625 (failed) events  
	If ($EvtID -eq "4625") 
	{ 
		$Result += @("`n*Time*: $TimeGenerated `n*User*: $EvtLogonDomain\$EvtLogonUser `n*Result*: Fail`n")
	} 
}

#if no results were returned, exit immediately and do not send Telegram message
if ($result.count -eq 0) { exit }

#Remove duplicate events
$result = $result |Sort-Object -Unique

# obtain computer IP address
$ip = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address

# convert IP address to string
$ip = $ip.IPAddressToString

#output the results to Telegram using an HTTP GET request
curl "https://api.telegram.org/bot$tokenID/sendMessage?chat_id=$chatID&parse_mode=Markdown&text=*System Login Activity* %0A*$env:COMPUTERNAME* : $ip $result"
 

 
