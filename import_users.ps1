# Define the domain and organizational unit
$domain1 = "kimrobbin"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName = "users"

# The path for the CSV
$csvPath = "C:\path\to\users.csv"

# Import users from the CSV file
$users = Import-Csv -Path $csvPath

# Loop through each user in the CSV file and create the user
foreach ($user in $users) {
    $userFirstName = $user.FirstName
    $userLastName = $user.LastName
    $userName = "$userFirstName.$userLastName"
    $userPassword = ConvertTo-SecureString $user.Password -AsPlainText -Force

    New-ADUser -Name $userName -GivenName $userFirstName -Surname $userLastName -SamAccountName $userName -UserPrincipalName "$userName@$domain" -Path "OU=$ouName,DC=$domain1,DC=$domain2" -AccountPassword $userPassword -Enabled $true
}

if (!(Test-Path -Path $csvPath)) {
    Write-Host "Error: CSV file not found at $csvPath"
    exit
}


# The format:
# FirstName,LastName,Password