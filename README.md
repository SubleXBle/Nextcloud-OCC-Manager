# Nextcloud-OCC-Manager
Tool for Nextcloud Administrators to make it easier to interact with Nextclouds OCC Command Line Interface

# ⚠️ Use on your own risk!
Even if I use it myself on the production installation, you use this script without warranty and on your own risk

This Bash script is designed to interact with Nextcloud's occ (OwnCloud Command) tool, which is used for managing various administrative tasks within a Nextcloud installation. The script provides a user-friendly, menu-driven interface that allows administrators to perform common Nextcloud tasks without directly typing OCC commands in the terminal. It automates the process by prompting users for necessary input and running the appropriate commands under the www-data user, which is the typical web server user for Nextcloud.

## Features:
### User Management:

+ Add User: Prompts the administrator to input a username and email address to create a new user in the Nextcloud system.
+ Delete User: Prompts the administrator to specify the username of the user to be deleted from Nextcloud.
+ List Users: Displays a list of all the users currently registered in the Nextcloud instance.

### App Management:

+ Install App: Prompts for the app name and installs the specified app in the Nextcloud system.
+ Remove App: Prompts for the app name and removes the specified app from the Nextcloud system.
+ Update App: Offers the option to update a specific app or all apps in the system. If updating all apps is chosen, the script runs occ app:update --all.

### Configuration Management:

+ Set Configuration Values: Allows administrators to set configuration values for the Nextcloud instance, such as adjusting upload file size limits or toggling the maintenance mode.
+ Upload Max Filesize: The administrator can set the maximum upload size for files (in MB).
+ Maintenance Mode: The administrator can toggle Nextcloud's maintenance mode on or off (useful for system upgrades or maintenance tasks).

### Log Viewing:

+ View Logs: Displays the most recent entries in both the regular and error log files. This allows administrators to quickly troubleshoot issues or check the history of commands that have been executed via the script.

## How the Script Works:

The script starts by showing a menu with various options (User Management, App Management, Set Config Values, View Logs, and Exit).
When the user selects an option, the script asks for any additional required inputs (such as app names, usernames, or configuration values) and then runs the corresponding occ command using sudo -u www-data php occ <command>.
The output of each command is logged in two files: a general log file (nextcloud_maintenance.log) for successful actions and a separate error log file (nextcloud_error.log) for failures or issues.
After executing the chosen task, the script provides feedback (success or error messages) to the user.

## Logging:
Log File Locations:
The script logs successful command executions in /var/log/nextcloud_maintenance.log.
It logs errors or issues in /var/log/nextcloud_error.log.
These logs help administrators keep track of activities and quickly diagnose any issues related to the Nextcloud instance.

## User Input Validation:
The script is designed to prompt the user for necessary input based on the selected option. For example, when adding a new user, it asks for both the username and email address, ensuring that all required fields are provided before attempting to execute the occ command.

## Color Coding:
The script uses color coding to help differentiate between different types of messages:
+ Green: Success messages (e.g., when a command is executed successfully).
+ Red: Error messages (e.g., if a command fails).
+ Yellow: Warnings or informational messages.
+ Blue: Headers or menu options for clarity.

## Installation and Usage:
```bash
wget https://raw.githubusercontent.com/SubleXBle/Nextcloud-OCC-Manager/latest/occ-tool.sh && chmod +x occ-tool.sh
```
Dependencies:
The script assumes that Nextcloud is installed and the occ tool is available.
It requires access to the Nextcloud installation directory and must be run with sudo privileges to execute commands under the www-data user (or whichever user your web server runs as).

### Run the Script:
To use the script, download or create it on your Nextcloud server, update the NEXTCLOUD_PATH variable with the correct installation path, and make the script executable (chmod +x scriptname.sh).
+ Execute the script with sudo ./scriptname.sh to start the interactive menu.
+ Choose an Action:
+ Select one of the menu options (e.g., User Management, App Management) and follow the prompts to execute commands.

### Example:
If you want to add a new user, the script will prompt you for:

+ Username: The new username for the user.
+ Email Address: The email address for the user.
After confirming the inputs, the script will run the occ user:add command under the www-data user, and the result (success or failure) will be displayed.

## Security Considerations:
+ The script uses sudo -u www-data to run occ commands as the web server user, ensuring the correct permissions for Nextcloud.
+ The script also captures the output and errors to log files for better transparency and easier troubleshooting.
+ The script should be restricted to authorized users with sufficient privileges to avoid misuse.

## Summary:
This script is a versatile tool for Nextcloud administrators, making it easier to interact with the Nextcloud occ command-line interface through an interactive, menu-driven interface. It streamlines common administrative tasks, such as managing users, installing/removing apps, and adjusting configuration values. The integration of logging and color-coded outputs enhances its usability and troubleshooting capabilities.
