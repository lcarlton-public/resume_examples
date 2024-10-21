#!/bin/bash

#SUMMARY
# Automated docker installation and add user. Detects package managers as well.
#
#DESCRIPTION
#
# The goal is to simplify docker installation accross multiple linux distros, and add docker user to sudo to run commands.
# Consider the security implications of this and work to remediate and harden the server running docker.
#
# NOTES
# Author: Leron Carlton
# Contact: lcarlton@student.cscc.edu
# Creation Date: 2023-03-22
# Update Date: 2024-10-21
  
# Set up logging
log_file="/var/log/docker-install.log"
exec > >(tee -a "$log_file") 2>&1

# Function to check for errors
check_error() {
  if [[ $? -ne 0 ]]; then
    echo "Error occurred during installation!"
    exit 1
  fi
}

# Detect the package manager
if command -v dnf &> /dev/null; then
  echo "Using DNF package manager..."
  sudo dnf check-update
  check_error
  sudo dnf install -y dnf-plugins-core
  check_error
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  check_error
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  check_error

elif command -v zypper &> /dev/null; then
  echo "Using Zypper package manager..."
  sudo zypper refresh
  check_error
  sudo zypper install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  check_error

elif command -v yum &> /dev/null; then
  echo "Using Yum package manager..."
  sudo yum check-update
  check_error
  sudo yum install -y yum-utils
  check_error
  sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
  check_error
  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  check_error

elif command -v apt &> /dev/null; then
  echo "Using APT package manager..."
  sudo apt-get update
  check_error
  sudo apt-get upgrade -y
  check_error
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  check_error
  echo "Adding GPG keys..."
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  check_error
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  check_error
  echo "Setting up repository..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  check_error
  sudo apt-get update
  check_error
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  check_error

else
  echo "No supported package manager found!"
  exit 1
fi

# Add the current user to the docker group
sudo usermod -aG docker $USER
check_error
echo "Added $USER to the docker group."

# Start and enable Docker service
sudo systemctl enable docker
check_error
sudo systemctl start docker
check_error

echo "Docker installation complete!"
