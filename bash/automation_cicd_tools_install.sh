#!/bin/bash

# SUMMARY
# Automated install for Jenkins, Terraform, Ansible, and Git for Linux.
#
# DESCRIPTION
#
# The goal is to simplify installation across multiple Linux distros,
# add specific users, and provide instructions.
#
# NOTES
# Author: Leron Carlton
# Contact: lcarlton@student.cscc.edu
# Creation Date: 2024-11-20  # Corrected date format

# Set up logging
log_file="/var/log/terraform_ansible_git-install.log"
exec > >(tee -a "$log_file") 2>&1

# Function to check for errors
check_error() {
  if [[ $? -ne 0 ]]; then
    echo "An error occurred. Exiting."
    exit 1
  fi
}

# Package detection variable
if command -v dnf &> /dev/null; then
  package_manager="dnf"
elif command -v zypper &> /dev/null; then
  package_manager="zypper"
elif command -v apt &> /dev/null; then
  package_manager="apt"
elif command -v yum &> /dev/null; then
  package_manager="yum"
else
  echo "Unsupported package manager."
  exit 1
fi

echo "Using ${package_manager} package manager..."

# Install Git
if [[ "${package_manager}" == "dnf" ]] || [[ "${package_manager}" == "yum" ]]; then
  sudo ${package_manager} check-update
  check_error
elif [[ "${package_manager}" == "apt" ]]; then
  sudo apt update
  check_error
elif [[ "${package_manager}" == "zypper" ]]; then
  sudo zypper refresh
  check_error
fi

sudo ${package_manager} install -y git-all
check_error

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
  echo "Installing GitHub CLI..."
  # Download the latest release for the current OS and architecture
  latest_release=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep browser_download_url | grep $(uname -s)-$(uname -m) | cut -d '"' -f 4)
  check_error

  # Download and install the GitHub CLI
  curl -Lo gh.tar.gz "$latest_release"
  check_error
  tar -xvzf gh.tar.gz
  check_error
  sudo ./gh_*_linux_amd64/install
  check_error
  rm -rf gh.tar.gz gh_*_linux_amd64
fi

echo "GitHub CLI was installed successfully!"

# Install Jenkins
if [[ "${package_manager}" == "dnf" ]]; then
  sudo dnf install -y java-17-openjdk
  check_error
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  check_error
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  check_error
  sudo dnf install -y jenkins
  check_error

elif [[ "${package_manager}" == "zypper" ]]; then
  sudo zypper install -y java-17-openjdk
  check_error
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  check_error
  sudo zypper addrepo https://pkg.jenkins.io/opensuse-stable/ jenkins
  check_error
  sudo zypper install -y jenkins
  check_error

elif [[ "${package_manager}" == "apt" ]]; then
  sudo apt-get install -y openjdk-17-jdk
  check_error
  wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  check_error
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

  check_error
  sudo apt-get update
  check_error
  sudo apt-get install -y jenkins
  check_error

elif [[ "${package_manager}" == "yum" ]]; then
  sudo yum install -y java-17-openjdk
  check_error
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  check_error
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  check_error
  sudo yum install -y jenkins
  check_error
fi

echo "Jenkins was installed successfully!"

# Enable and start Jenkins service
sudo systemctl enable jenkins
check_error
sudo systemctl start jenkins
check_error
sudo systemctl status jenkins


# Install Terraform
if [[ "${package_manager}" == "dnf" ]]; then
  sudo dnf install -y dnf-plugins-core
  check_error
  sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  check_error
elif [[ "${package_manager}" == "zypper" ]]; then
  sudo zypper addrepo --refresh https://rpm.releases.hashicorp.com/opensuse/hashicorp.repo
  check_error
elif [[ "${package_manager}" == "apt" ]]; then
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  check_error
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  check_error
  sudo apt update
  check_error
elif [[ "${package_manager}" == "yum" ]]; then
  sudo yum install -y yum-utils
  check_error
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  check_error
fi

sudo ${package_manager} install -y terraform
check_error
echo "Terraform was installed successfully!"


# Install Ansible
if [[ "${package_manager}" == "dnf" ]]; then
  sudo dnf install -y ansible ansible-collection-community-general
  check_error
elif [[ "${package_manager}" == "zypper" ]]; then
  sudo zypper install -y ansible
  check_error
elif [[ "${package_manager}" == "apt" ]]; then
  UBUNTU_CODENAME=$(lsb_release -cs)
  wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
  check_error
  echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu ${UBUNTU_CODENAME} main" | sudo tee /etc/apt/sources.list.d/ansible.list
  check_error
  sudo apt update
  check_error
  sudo apt install -y ansible
  check_error
elif [[ "${package_manager}" == "yum" ]]; then
  sudo yum install -y epel-release ansible
  check_error
fi

echo "Ansible was installed successfully!"
