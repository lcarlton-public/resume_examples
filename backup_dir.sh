#!/bin/bash

# SUMMARY
# Simple script to backup the current user's home directory.

# DESCRIPTION
# Backs up the home directory of the logged-in user to an external drive at /mnt/backup.

# NOTES
# Author: Leron Carlton
# Contact: lcarlton@student.cscc.edu
# Creation Date: 2024-12-03

# Set the backup location
backup_location="/mnt/backup"

# Check if the backup location exists
if [ ! -d "$backup_location" ]; then
  echo "Error: The backup location '$backup_location' does not exist." >&2
  exit 1
fi

# Get the current user's home directory
user_home=$(getent passwd "$USER" | cut -d: -f6)

# Set current date variable
current_date=$(date +%Y-%m-%d)

# Create the backup filename with current date variable
backup_filename="${USER}_home_backup_${current_date}.tar.gz"

# Create the full path for the backup file
backup_filepath="${backup_location}/${backup_filename}"

# Create the backup using tar
tar -cfzv "$backup_filepath" "$user_home"

# Check for errors during backup creation
if [[ $? -ne 0 ]]; then
  echo "Error: An error occurred during backup creation." >&2
  exit 1
fi

echo "You did it! Backup completed: $backup_filepath"