Start-Transcript -Path "C:\Logs\windowserver1.log"

# Define variables
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

# DHCP  Variables
$scopeName = "Scope1"
$startRange = "192.168.35.100"
$endRange = "192.168.35.200"
$subnetMask = "255.255.255.0"

Rename-Computer -NewName $computername

# Set Static IP Address
try {
    New-NetIPAddress -IPAddress $ip -PrefixLength $length -DefaultGateway $gateway -InterfaceAlias $netAdapterName -ErrorAction Stop
} catch {
    Write-Error "Failed to add IP address: $_"
}

# Install Windows Features
$features = @("AD-Domain-Services", "DHCP", "DNS", "Hyper-V")
Install-WindowsFeature -Name $features -IncludeAllSubFeature -IncludeManagementTools -Restart



# Stop logging
Stop-Transcript

Restart-Computer