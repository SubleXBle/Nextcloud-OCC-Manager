#!/bin/bash

# Color codes
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[33m'
BLUE='\033[34m'

# Log file paths
LOGFILE="/var/log/nextcloud_maintenance.log"
ERRORLOG="/var/log/nextcloud_error.log"

# Nextcloud installation path
NEXTCLOUD_PATH="/var/www/nextcloud"

# Function definitions
echo_success() {
    echo -e "${GREEN}$1${NORMAL}"
}

echo_error() {
    echo -e "${RED}$1${NORMAL}"
}

run_occ_command() {
    local command=$1
    local logfile=$2
    local errorlog=$3

    echo "Executing command: $command"
    sudo -u www-data php $NEXTCLOUD_PATH/occ $command >> $logfile 2>> $errorlog

    if [ $? -ne 0 ]; then
        echo_error "Error executing command: $command. See the logfile for more details."
    else
        echo_success "Command successfully executed: $command" | tee -a $logfile
    fi
}

# Display main menu
show_menu() {
    echo -e "${BLUE}Nextcloud OCC Command Menu${NORMAL}"
    echo "1) User Management"
    echo "2) App Management"
    echo "3) Set Configuration Values"
    echo "4) View Logs"
    echo "5) Exit Script"
    echo -n "Choose an option (1-5): "
}

# User management menu
user_management() {
    echo -e "${YELLOW}User Management${NORMAL}"
    echo "1) Add user"
    echo "2) Delete user"
    echo "3) List users"
    echo -n "Choose an option (1-3): "
    read user_choice

    case $user_choice in
        1)
            read -p "Enter the username: " username
            read -p "Enter the email address: " email
            command="user:add $username $email"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        2)
            read -p "Enter the username to delete: " username
            command="user:delete $username"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        3)
            command="user:list"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        *)
            echo_error "Invalid choice."
            ;;
    esac
}

# App management menu
app_management() {
    echo -e "${YELLOW}App Management${NORMAL}"
    echo "1) Install app"
    echo "2) Remove app"
    echo "3) Update app"
    echo -n "Choose an option (1-3): "
    read app_choice

    case $app_choice in
        1)
            read -p "Enter the app name: " app_name
            command="app:install $app_name"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        2)
            read -p "Enter the app name: " app_name
            command="app:remove $app_name"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        3)
            read -p "Do you want to update a specific app? (yes/no): " update_choice
            if [ "$update_choice" == "yes" ]; then
                read -p "Enter the app name: " app_name
                command="app:update $app_name"
            else
                command="app:update --all"
            fi
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        *)
            echo_error "Invalid choice."
            ;;
    esac
}

# Set configuration values menu
set_config_values() {
    echo -e "${YELLOW}Set Configuration Values${NORMAL}"
    echo "1) Storage settings"
    echo "2) System maintenance"
    echo -n "Choose an option (1-2): "
    read config_choice

    case $config_choice in
        1)
            read -p "Enter the new max upload size (in MB): " upload_size
            command="config:system:set upload_max_filesize --value=${upload_size}M"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        2)
            read -p "Enter the maintenance mode (true/false): " maintenance_mode
            command="config:system:set maintenance --value=$maintenance_mode"
            run_occ_command "$command" "$LOGFILE" "$ERRORLOG"
            ;;
        *)
            echo_error "Invalid choice."
            ;;
    esac
}

# View logs
view_logs() {
    echo -e "${YELLOW}View Logs${NORMAL}"
    tail -n 50 $LOGFILE
    tail -n 50 $ERRORLOG
}

# Main program loop
while true; do
    show_menu
    read choice

    case $choice in
        1) user_management ;;
        2) app_management ;;
        3) set_config_values ;;
        4) view_logs ;;
        5) echo "Exiting script."; exit 0 ;;
        *) echo_error "Invalid selection. Please choose a number between 1 and 5." ;;
    esac
done
