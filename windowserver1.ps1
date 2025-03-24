Start-Transcript -Path "C:\Logs\windowserver1.log"

$computername = "MainServer"
$ip = "192.168.35.10"
$gateway = "192.168.35.1"
$length = 24

$vSwitchName = "External"
$netAdapterName = "Ethernet"
$vlanID = 335

$domain1 = "skole"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName1 = "Elever"
$ouName2 = "Lerere"

  
$scopeName = "Scope1"
$startRange = "192.168.35.100"
$endRange = "192.168.35.200"
$subnetMask = "255.255.255.0"


# Feature
$features = @("AD-Domain-Services", "DHCP", "DNS", "Hyper-V")


Rename-Computer -NewName $computername


New-NetIPAddress -IPAddress $ip -PrefixLength $length -DefaultGateway $gateway -InterfaceAlias $netAdapterName -ErrorAction Stop


# Install Windows Features
Install-WindowsFeature -Name $features -IncludeAllSubFeature -IncludeManagementTools -Restart



Stop-Transcript

Restart-Computer