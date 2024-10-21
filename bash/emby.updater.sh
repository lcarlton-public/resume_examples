#!/bin/bash

# Download the latest Emby Server for Fedora x64
wget -q $(curl -s "https://emby.media/linux-server.html" | grep -o 'https://github.com/MediaBrowser/Emby.Releases/releases/download/[^"]*rpm' | head -n 1) -O emby-server.rpm

# Install the downloaded RPM package
sudo rpm -i emby-server.rpm

# Start the Emby Server and log the output
sudo systemctl start emby-server &> /var/log/emby-server-install.log
