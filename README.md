# User Creation Script

## Overview

This script, `create_users.sh`, is designed to automate the process of creating users and groups on a Linux system. It reads a text file containing usernames and group names, where each line is formatted as `user;groups`. The script then creates users and their primary groups, assigns them to additional groups, sets up home directories with appropriate permissions and ownership, generates random passwords for the users, and logs all actions. Passwords are stored securely in `/var/secure/user_passwords.csv`.

## Requirements

- The script must be run with root privileges.
- The script expects a text file with the format: `username;group1,group2,...`
  - Example:
    ```plaintext
    john;developers,finance
    jane;designers
    alice;admin,finance,marketing
    ```

## Features

- Creates a primary group for each user.
- Creates users with their primary group and home directory.
- Adds users to additional specified groups.
- Generates and sets a random password for each user.
- Logs all actions to `/var/log/user_management.log`.
- Stores generated passwords securely in `/var/secure/user_passwords.csv`.

## Usage

1. **Clone or download the script to your local machine.**

2. **Ensure the script is executable:**
   ```bash
   chmod +x create_users.sh

3. **Prepare your input file (e.g., create_users.txt)**
4. **Run the script with sudo:**
 ```bash
   sudo bash create_users.sh <input_file>

**Logs and Password Storage**
**Log File:** All actions performed by the script are logged in /var/log/user_management.log.
**Password File:**  Generated passwords are stored in /var/secure/user_passwords.csv. Only the file owner has read permissions.