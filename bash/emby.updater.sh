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

# Get the latest version number from GitHub releases
# Add retry logic for more robust fetching
retries=3
for i in $(seq 1 $retries); do
  latest_version=$(curl -s "https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  if [[ -n "$latest_version" ]]; then
    log "Latest version found: $latest_version"
    break
  else
    log "Attempt $i failed to fetch latest version. Retrying..."
    sleep 2 
  fi
done

# Exit if version retrieval failed after retries
if [[ -z "$latest_version" ]]; then
  log "Error: Failed to fetch latest version after $retries attempts."
  exit 1
fi

# Construct the download URL
download_url="https://github.com/MediaBrowser/Emby.Releases/releases/download/$latest_version/emby-server-rpm_$latest_version\_x86_64.rpm"
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

# ... (rest of the script remains the same)
