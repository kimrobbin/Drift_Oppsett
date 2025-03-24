$domain1 = "skole"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName1 = "Elever"
$ouName2 = "Lerere"

$csvPath = ""

$users = Import-Csv -Path $csvPath


foreach ($user in $users) {
    $userFirstName = $user.FirstName
    $userLastName = $user.LastName
    $userName = "$userFirstName.$userLastName"
    $userPassword = ConvertTo-SecureString $user.Password -AsPlainText -Force
    $ouName = if ($user.Role -eq "Teacher") { $ouName2 } else { $ouName1 }

    New-ADUser -Name $userName -GivenName $userFirstName -Surname $userLastName -SamAccountName $userName -UserPrincipalName "$userName@$domain" -Path "OU=$ouName,DC=$domain1,DC=$domain2" -AccountPassword $userPassword -Enabled $true
}

