#!/bin/bash
# Summary
# A script to update emby media server on fedora
#
# Description
# Checks the version of emby, and release date, then downloads and installs.
# Make sure to chmod the script to make it run properly

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

# Get the latest version number from GitHub releases
latest_version=$(curl -s "https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
log "Latest version found: $latest_version"

# Construct the download URL
download_url="https://github.com/MediaBrowser/Emby.Releases/releases/download/$latest_version/emby-server-rpm_$latest_version\_x86_64.rpm"
log "Download URL: $download_url"

# Download the latest RPM
log "Downloading latest Emby Server RPM..."
curl -L -o /tmp/emby-server.rpm "$download_url"
if [[ $? -ne 0 ]]; then
  log "Error downloading Emby Server RPM."
  exit 1
fi

# Install the RPM
log "Installing Emby Server RPM..."
dnf install -y /tmp/emby-server.rpm
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
