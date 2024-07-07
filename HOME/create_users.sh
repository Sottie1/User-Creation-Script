#!/bin/bash

# Define log file and password file
LOGFILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Ensure log and password files exist and set permissions
sudo mkdir -p /var/log
sudo touch $LOGFILE
sudo chmod 666 $LOGFILE

sudo mkdir -p /var/secure
sudo touch $PASSWORD_FILE
sudo chmod 600 $PASSWORD_FILE

# Log function
log_action() {
    echo "$(date +"%Y-%m-%d %T") - $1" | sudo tee -a $LOGFILE
}

# Check if input file is provided
if [ -z "$1" ]; then
    log_action "Error: No input file provided."
    exit 1
fi

# Read input file
INPUT_FILE=$1
if [ ! -f $INPUT_FILE ]; then
    log_action "Error: Input file $INPUT_FILE not found."
    exit 1
fi

# Process each line in the input file
while IFS=';' read -r username groups; do
    # Remove whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Skip empty lines
    if [ -z "$username" ]; then
        continue
    fi

    echo "Processing user: $username"
    echo "Groups: $groups"

    # Create primary group for the user
    if ! getent group "$username" > /dev/null; then
        sudo groupadd "$username"
        if [ $? -eq 0 ]; then
            log_action "Created group $username"
        else
            log_action "Failed to create group $username"
            continue
        fi
    else
        log_action "Group $username already exists"
    fi

    # Create user with primary group and home directory
    if ! id -u "$username" > /dev/null 2>&1; then
        sudo useradd -m -g "$username" "$username"
        if [ $? -eq 0 ]; then
            log_action "Created user $username with group $username"
        else
            log_action "Failed to create user $username"
            continue
        fi

        # Set password
        password=$(openssl rand -base64 12)
        echo "$username:$password" | sudo chpasswd
        if [ $? -eq 0 ]; then
            log_action "Set password for user $username"
            echo "$username,$password" | sudo tee -a $PASSWORD_FILE
        else
            log_action "Failed to set password for user $username"
        fi
    else
        log_action "User $username already exists"
    fi

    # Process secondary groups
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo "$group" | xargs) # Remove whitespace
        if [ -z "$group" ]; then
            continue
        fi

        if ! getent group "$group" > /dev/null; then
            sudo groupadd "$group"
            if [ $? -eq 0 ]; then
                log_action "Created group $group"
            else
                log_action "Failed to create group $group"
                continue
            fi
        else
            log_action "Group $group already exists"
        fi

        sudo usermod -aG "$group" "$username"
        if [ $? -eq 0 ]; then
            log_action "Added user $username to group $group"
        else
            log_action "Failed to add user $username to group $group"
        fi
    done
done < "$INPUT_FILE"

log_action "User creation process completed."


