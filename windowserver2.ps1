Start-Transcript -Path "C:\Logs\windowserver2.log"

# Define variables
$computername = "MainServer"
$ip = "192.168.35.10"
$gateway = "192.168.35.1"
$opnSense = "192.168.35.2"


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



New-VMSwitch -Name $vSwitchName -NetAdapterName $netAdapterName -AllowManagementOS $true -ErrorAction Stop



# Set VLAN ID 
Set-VMNetworkAdapterVlan -ManagementOS -Access -VlanId $vlanID -ErrorAction Stop

Set-DnsClientServerAddress -InterfaceAlias $netAdapterName -ServerAddresses $opnSense -ErrorAction Stop


# Ensure AD Services are running before proceeding
Get-Service ADWS -ErrorAction SilentlyContinue

# Configure AD DS
Install-ADDSForest -DomainName $domain -InstallDNS -Force

# Create OU
New-ADOrganizationalUnit -Name $ouName1 -Path "DC=$domain1,DC=$domain2"
New-ADOrganizationalUnit -Name $ouName2 -Path "DC=$domain1,DC=$domain2"

# Configure DHCP
Add-DhcpServerv4Scope -Name $scopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask
Set-DhcpServerv4OptionValue -ScopeId $ip -Router $gateway -DnsServer $opnSense

Add-DhcpServerInDC -DnsName $computername -IPAddress $ip -ErrorAction Stop




Restart-Computer