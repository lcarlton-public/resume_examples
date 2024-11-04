<#
.SUMMARY
Create a user based on the department, and auto create password.
Baked in password creation for ease of usage, but recommend using 
Generate-Password cmdlet if using PS 6.0 or higher
.DESCRIPTION
This
.NOTES
Author: Leron Carlton
Contact: lcarlton@student.cscc.edu
#>

# Force the script to stop if an error occurs
$ErrorActionPreference = "Stop"

# Define the new user's information
$userName = "Chris Osiris"
# Generate a random password using secure random number generator
$password = -join ((33..126) + (65..90) + (97..122) | ForEach-Object { [char]$_ } | Get-Random -Count 16)
$ouPath = "OU=Users,DC=yourdomain,DC=com" # Replace with your actual OU path

# Create the new user account
try {
    New-ADUser `
        -Path $ouPath `
        -Name $userName `
        -SamAccountName $userName.Replace(" ", "") `
        -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
        -Enabled $false `
        -GivenName "Chris" `
        -Surname "Osiris" `
        -DisplayName "Chris Osiris" `
        -Department "IT" ` # Example department
        -City "Columbus" `  # Example city
        -State "Ohio"      # Example state
} catch {
    Write-Error "Failed to create user account: $($_.Exception.Message)"
    exit 1
}

# Output the password and login information to a file
$output = @"
Username: $userName
Password: $password
"@
$output | Out-File -FilePath "C:\user_credentials.txt" -Append

# Display a success message to the console
Write-Host "User account created successfully."
Write-Host "Credentials saved to C:\user_credentials.txt"