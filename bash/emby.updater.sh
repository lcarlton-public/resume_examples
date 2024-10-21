#!/bin/bash

# Log file location
LOG_FILE="/var/log/emby-server-update.log"

# Function to log messages with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Stop Emby Server
log "Stopping Emby Server..."
systemctl stop emby-server
if [[ $? -ne 0 ]]; then
  log "Error stopping Emby Server."
  exit 1
fi

# Extract the latest version and download URL from the Emby website
log "Fetching latest version and download URL from Emby website..."
html=$(curl -s "https://emby.media/linux-server.html")
if [[ $? -ne 0 ]]; then
  log "Error fetching Emby website."
  exit 1
fi

# Extract the version number (adjust the grep/sed commands if the website structure changes)
latest_version=$(echo "$html" | grep -oE 'Fedora x64.*emby-server-rpm_[0-9.]+_x86_64.rpm' | grep -oE 'emby-server-rpm_[0-9.]+_x86_64.rpm' | sed -E 's/emby-server-rpm_([0-9.]+)_x86_64.rpm/\1/')
if [[ -z "$latest_version" ]]; then
  log "Error extracting latest version from website."
  exit 1
fi
log "Latest version found: $latest_version"

# Extract the download URL (adjust the grep/sed commands if the website structure changes)
download_url=$(echo "$html" | grep -oE 'Fedora x64.*emby-server-rpm_[0-9.]+_x86_64.rpm' | sed -E 's/.*href="([^"]+)".*/\1/')
if [[ -z "$download_url" ]]; then
  log "Error extracting download URL from website."
  exit 1
fi
log "Download URL: $download_url"

# Download the latest RPM with retry logic
log "Downloading latest Emby Server RPM..."
retries=3
for i in $(seq 1 $retries); do
  curl -L -o /tmp/emby-server.rpm "$download_url"
  if [[ $? -eq 0 ]]; then
    log "Download successful."
    break
  else
    log "Attempt $i failed to download. Retrying..."
    sleep 2
  fi
done

# Exit if download failed after retries
if [[ $? -ne 0 ]]; then
  log "Error downloading Emby Server RPM after $retries attempts."
  exit 1
fi

# Install the RPM (ensure permissions with sudo)
log "Installing Emby Server RPM..."
sudo dnf install -y /tmp/emby-server.rpm
if [[ $? -ne 0 ]]; then
  log "Error installing Emby Server RPM."
  exit 1
fi

# Validate installation (check if emby-server process is running)
log "Validating installation..."
if pgrep emby-server > /dev/null; then
  log "Emby Server installed successfully."
else
  log "Emby Server installation failed."
  exit 1
fi

# Start Emby Server
log "Starting Emby Server..."
systemctl start emby-server
if [[ $? -ne 0 ]]; then
  log "Error starting Emby Server."
  exit 1
fi

log "Emby Server update completed successfully."

# Clean up temporary file
rm /tmp/emby-server.rpm
