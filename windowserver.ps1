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

# Rename Computer
Rename-Computer -NewName $computername 

# Check if the network adapter exists
$netAdapter = Get-NetAdapter -Name $netAdapterName
if ($null -eq $netAdapter) {
    Write-Error "Network adapter '$netAdapterName' not found."
    exit
}

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
    Set-VMNetworkAdapterVlan -VMNetworkAdapterName $netAdapterName -Access -VlanId $vlanID
} catch {
    Write-Error "Failed to set VLAN ID: $_"
}

# Install required features
$features = @("AD-Domain-Services", "DHCP", "DNS", "Hyper-V")
Install-WindowsFeature -Name $features -IncludeAllSubFeature -IncludeManagementTools -Restart

# Configure Active Directory Domain Services
Install-ADDSForest -DomainName $domain -InstallDNS

# Create Organizational Unit
New-ADOrganizationalUnit -Name $ouName -Path "DC=$domain1,DC=$domain2"
Set-ADDomain -Identity $domain -DefaultUserContainer "OU=$ouName,DC=$domain1,DC=$domain2"

# Configure DHCP Server
Add-DhcpServerv4Scope -Name $scopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask
Set-DhcpServerv4OptionValue -ScopeId $ip -Router $gateway -DnsServer $ip

Restart-Computer