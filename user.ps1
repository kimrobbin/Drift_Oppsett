#  To make a new user
$domain1 = "kimrobbin"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName = "users"



$userFirstName = ""
$userLastName = ""
$userName = "$userFirstName.$userLastName"
$userPassword = ConvertTo-SecureString "Password-Need-To-Change-For-Use" -AsPlainText -Force

New-ADUser -Name $userName -GivenName $userFirstName -Surname $userLastName -SamAccountName $userName -UserPrincipalName "$userName@$domain" -Path "OU=$ouName,DC=$domain1,DC=$domain2" -AccountPassword $userPassword -Enabled $true