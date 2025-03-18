# Define variables
$computername = "SchoolMainServer"
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

# Rename Computer
Rename-Computer -NewName $computername 

# Set Static IP Address
New-NetIPAddress -IPAddress $ip -PrefixLength $length -DefaultGateway $gateway -InterfaceAlias "Ethernet"


# Create a new virtual switch with an external connection type
New-VMSwitch -Name $vSwitchName -NetAdapterName $netAdapterName -AllowManagementOS $true

# Set VLAN ID for the virtual switch
Set-VMNetworkAdapterVlan  -VMNetworkAdapterName $netAdapterName -Access -VlanId $vlanID



# Install required features
$features = @("AD-Domain-Services", "DHCP", "DNS", "Hyper-V")
Install-WindowsFeature -Name $features -IncludeAllSubFeature -IncludeManagementTools -Restart

# Configure Active Directory Domain Services
Install-ADDSForest -DomainName $domain -InstallDNS

# Create Organizational Unit
New-ADOrganizationalUnit -Name $ouName -Path "DC=$domain1,DC=$domain2"
Set-ADDomain -Identity $domain -DefaultUserContainer "OU=$ouName,DC=$domain1,DC=$domain2"

Restart-Computer