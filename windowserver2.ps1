# Start logging
Start-Transcript -Path "C:\Logs\windowserver2.log"

# Define variables
$computername = "MainServer"
$ip = "192.168.35.1"
$gateway = "192.168.35.1"
$length = 24

$vSwitchName = "External"
$netAdapterName = "Ethernet"
$vlanID = 335

$domain1 = "kimrobbin"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName = "users"

# DHCP Scope Variables
$scopeName = "Scope1"
$startRange = "192.168.35.100"
$endRange = "192.168.35.200"
$subnetMask = "255.255.255.0"

# Set Static IP Address
try {
    New-NetIPAddress -IPAddress $ip -PrefixLength $length -DefaultGateway $gateway -InterfaceAlias $netAdapterName
} catch {
    Write-Error "Failed to add IP address: $_"
}

# Set DNS Server
try {
    Set-DnsClientServerAddress -InterfaceAlias $netAdapterName -ServerAddresses ("8.8.8.8", "8.8.4.4")
} catch {
    Write-Error "Failed to set DNS server address: $_"
}

# Create a new virtual switch with an external connection type
try {
    New-VMSwitch -Name $vSwitchName -NetAdapterName $netAdapterName -AllowManagementOS $true
} catch {
    Write-Error "Failed to create virtual switch: $_"
}

# Set VLAN ID for the virtual switch
try {
    Set-VMNetworkAdapterVlan -AllowManagementOS -VMNetworkAdapterName $netAdapterName -Access -VlanId $vlanID
} catch {
    Write-Error "Failed to set VLAN ID: $_"
}

# Configure Active Directory Domain Services
Install-ADDSForest -DomainName $domain -InstallDNS

# Create Organizational Unit
New-ADOrganizationalUnit -Name $ouName -Path "DC=$domain1,DC=$domain2"
Set-ADDomain -Identity $domain -DefaultUserContainer "OU=$ouName,DC=$domain1,DC=$domain2"

# Configure DHCP Server
Add-DhcpServerv4Scope -Name $scopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask
Set-DhcpServerv4OptionValue -ScopeId $ip -Router $gateway -DnsServer $ip

# Authorize DHCP Server in Active Directory
try {
    Add-DhcpServerInDC -DnsName $computername -IPAddress $ip
} catch {
    Write-Error "Failed to authorize DHCP server: $_"
}

# Stop logging
Stop-Transcript