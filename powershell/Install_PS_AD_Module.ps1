<#
.SUMMARY
Create a new VM with specified parameters.
.DESCRIPTION
This script checks to see if the powershell module is installed, and if not, then installs it.
After validating installation it then sets the execution policy to RemoteSigned.
Upon completion it installs the Active Directory Module.
.NOTES
Author: Leron Carlton
Contact: lcarlton@student.cscc.edu
#>
<# 

This script is still a Work In Progress; I'm working to get it to work consistently on varied versions of powershell.

# Check if the Active Directory module can be loaded
$module = Get-Module -ListAvailable -Name ActiveDirectory
if (-not $module) {
    try {
        Write-Host "Installing RSAT-AD-PowerShell..."

        # Get a list of available features using DISM
        $features = dism /online /get-features | Where-Object { $_ -match "RSAT" }

        # Find the relevant AD PowerShell feature
        $adFeature = $features | Where-Object { $_ -match "AD-Powershell" }

        if ($adFeature) {
            # Extract the feature name
            $featureName = ($adFeature -split ":")[1].Trim()

            Write-Host "Found feature: $featureName"

            # Install the feature using DISM
            dism /online /enable-feature /featurename:$featureName /quiet /norestart
        } else {
            Write-Error "Could not find the RSAT AD PowerShell feature."
            exit 1
        }

    }
    catch {
        Write-Error "An error occurred while installing RSAT-AD-PowerShell: $_"
        exit 1
    }
}

# Confirm execution policy change (if needed)
if ($PSCmdlet.ShouldContinue("Change the execution policy to RemoteSigned?", "Warning")) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# Import the module
Import-Module ActiveDirectory

# Get commands (optional)
Get-Command -Module ActiveDirectory
#>
