# Define the domain and organizational units
$domain1 = "skole"
$domain2 = "local"
$domain = "$domain1.$domain2"
$ouName1 = "Elever"
$ouName2 = "Lerere"

# The path for the CSV
$csvPath = ""

# Check if the CSV file exists
if (!(Test-Path -Path $csvPath)) {
    Write-Host "Error: CSV file not found at $csvPath"
    exit
}

# Import users from the CSV file
$users = Import-Csv -Path $csvPath

# Loop through each user in the CSV file and create the user
foreach ($user in $users) {
    $userFirstName = $user.FirstName
    $userLastName = $user.LastName
    $userName = "$userFirstName.$userLastName"
    $userPassword = ConvertTo-SecureString $user.Password -AsPlainText -Force
    $ouName = if ($user.Role -eq "Teacher") { $ouName2 } else { $ouName1 }

    New-ADUser -Name $userName -GivenName $userFirstName -Surname $userLastName -SamAccountName $userName -UserPrincipalName "$userName@$domain" -Path "OU=$ouName,DC=$domain1,DC=$domain2" -AccountPassword $userPassword -Enabled $true
}

# The format of the CSV file should be:
# FirstName,LastName,Password,Role
