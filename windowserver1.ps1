Start-Transcript -Path "C:\Logs\windowserver1.log"

$computername = "MainServer"
$ip = "192.168.35.10"
$gateway = "192.168.35.1"
$length = 24




Rename-Computer -NewName $computername


New-NetIPAddress -IPAddress $ip -PrefixLength $length -DefaultGateway $gateway -InterfaceAlias $netAdapterName -ErrorAction Stop


# Install Windows Features
Install-WindowsFeature -Name $features -IncludeAllSubFeature -IncludeManagementTools -Restart



Stop-Transcript

Restart-Computer