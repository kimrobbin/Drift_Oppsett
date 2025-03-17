$computername = "MainSever"

$ip = "10.100.100.100"
$gateway = "10.0.0.1"
$length = 24

$domain1 = "kimrobbin"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName = "Elever"
$ouName2 = "Lærere"

Rename-Computer -NewName $computername -Restart

New-NetIPAddress -IPAddress $ip -PrefixLength $length -DefaultGateway $gateway

$features = @(
    "AD-Domain-Services",
    "DHCP",
    "DNS",
    "Hyper-V"
)

Install-WindowsFeature -Name $features -IncludeAllSubFeature -IncludeManagementTools -Restart

Install-ADDSForest -DomainName $domain -InstallDNS

New-ADOrganizationalUnit -Name $ouName -Path "DC=$domain1,DC=$domain2"
New-ADOrganizationalUnit -Name $ouName2 -Path "DC=$domain1,DC=$domain2"


