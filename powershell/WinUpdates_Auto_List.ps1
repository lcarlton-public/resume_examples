<#
.SUMMARY
Install PS Module for Updates
.DESCRIPTION
Then install updates that don't need reboot. Provide a list in csv format of the updates that were just installed, and then another .csv that shows the ones that need installed that require a reboot.
.NOTES
Author: Leron Carlton
Contact: lcarlton@student.cscc.edu
#>

# Create log directory if it doesn't exist
$logDir = "C:\WINDOWS\system32\config\Logs"
if (!(Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Log file path
$logFile = Join-Path $logDir "WindowsUpdate.log"

try {
    # Install the PSWindowsUpdate module
    Install-Module PSWindowsUpdate -Force -ErrorAction Stop | Out-File $logFile -Append

    # Install updates that don't require a reboot
    $installedUpdates = Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop | Out-File $logFile -Append

    # Get the date for the filename
    $dateString = Get-Date -Format yyyyMMdd

    # Export installed updates to a CSV file
    if ($installedUpdates) {
        $installedUpdates | Export-Csv -Path ".\InstalledUpdates_$dateString.csv" -NoTypeInformation -Append
    } else {
        Write-Log -Message "No updates were installed." -LogFile $logFile
    }

    # Get updates that require a reboot
    $pendingRebootUpdates = Get-WUList -MicrosoftUpdate -Verbose | Where-Object {$_.RebootRequired -eq $true} | Out-File $logFile -Append

    # Export pending reboot updates to a CSV file
    if ($pendingRebootUpdates) {
        $pendingRebootUpdates | Export-Csv -Path ".\PendingRebootUpdates_$dateString.csv" -NoTypeInformation -Append
    } else {
        Write-Log -Message "No updates requiring a reboot were found." -LogFile $logFile
    }

    # Combine all update information into a single CSV for Grafana
    $allUpdates = @()
    if ($installedUpdates) { $allUpdates += $installedUpdates | Select-Object Title, KBArticleID, Installed, RebootRequired }
    if ($pendingRebootUpdates) { $allUpdates += $pendingRebootUpdates | Select-Object Title, KBArticleID, Installed, RebootRequired }

    if ($allUpdates) {
        $allUpdates | Export-Csv -Path ".\GrafanaUpdates_$dateString.csv" -NoTypeInformation -Append
    }

} catch {
    # Log any errors encountered
    Write-Log -Message "An error occurred: $($_.Exception.Message)" -LogFile $logFile
}

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$LogFile
    )
    $logEntry = "{0} - {1}" -f (Get-Date), $Message
    Write-Output $logEntry | Out-File $logFile -Append
}