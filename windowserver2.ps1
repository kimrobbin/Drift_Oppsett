Start-Transcript -Path "C:\Logs\windowserver2.log"

# Define variables
$computername = "MainServer"
$ip = "192.168.35.1"
$gateway = "192.168.35.1"
$length = 24

$vSwitchName = "External"
$netAdapterName = (Get-NetAdapter | Where-Object { $_.Name -like "vEthernet*" }).Name
$vlanID = 335

$domain1 = "kimrobbin"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName = "users"

$scopeName = "Scope1"
$startRange = "192.168.35.100"
$endRange = "192.168.35.200"
$subnetMask = "255.255.255.0"

# Set DNS Server
try {
    Set-DnsClientServerAddress -InterfaceAlias $netAdapterName -ServerAddresses ("8.8.8.8", "8.8.4.4") -ErrorAction Stop
} catch {
    Write-Error "Failed to set DNS server address: $_"
}

# Create a new virtual switch with an external connection type
try {
    New-VMSwitch -Name $vSwitchName -NetAdapterName $netAdapterName -AllowManagementOS $true -ErrorAction Stop
} catch {
    Write-Error "Failed to create virtual switch: $_"
}

# Set VLAN ID Correctly
try {
    Set-VMNetworkAdapterVlan -ManagementOS -Access -VlanId $vlanID -ErrorAction Stop
} catch {
    Write-Error "Failed to set VLAN ID: $_"
}

# Ensure AD Services are running before proceeding
if (-not (Get-Service ADWS -ErrorAction SilentlyContinue)) {
    Write-Error "Active Directory Web Services is not running. Ensure AD is properly installed."
    exit 1
}

# Configure AD DS
Install-ADDSForest -DomainName $domain -InstallDNS -Force

# Create Organizational Unit if it doesn't exist
if (-not (Get-ADOrganizationalUnit -Filter { Name -eq $ouName } -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $ouName -Path "DC=$domain1,DC=$domain2"
}

# Configure DHCP
Add-DhcpServerv4Scope -Name $scopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask
Set-DhcpServerv4OptionValue -ScopeId $ip -Router $gateway -DnsServer $ip

# Authorize DHCP Server
try {
    Add-DhcpServerInDC -DnsName $computername -IPAddress $ip -ErrorAction Stop
} catch {
    Write-Error "Failed to authorize DHCP server: $_"
}

Restart-Computer  