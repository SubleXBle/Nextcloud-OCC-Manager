#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NORMAL='\033[0m'

# Set the path to the Nextcloud installation
NEXTCLOUD_PATH="/var/www/nextcloud"

# Log files
LOGFILE="/var/log/nextcloud_maintenance.log"
ERROR_LOGFILE="/var/log/nextcloud_error.log"

# Helper functions
log_message() {
    echo -e "$1" | tee -a "$LOGFILE"
}

log_error() {
    echo -e "$1" | tee -a "$ERROR_LOGFILE"
}

# Function to run commands
run_command() {
    echo -e "${BLUE}Running command: $1${NORMAL}"
    $1
    if [ $? -eq 0 ]; then
        log_message "${GREEN}Success: Command executed successfully.${NORMAL}"
    else
        log_error "${RED}Error: Command failed.${NORMAL}"
    fi
}

# Main menu function
main_menu() {
    echo -e "${BLUE}Nextcloud OCC Manager${NORMAL}"
    echo "1. User Management"
    echo "2. App Management"
    echo "3. Configuration Management"
    echo "4. Database Operations"
    echo "5. Filesystem Operations"
    echo "6. View Logs"
    echo "7. Exit"
    read -p "Choose an option: " choice

    case $choice in
        1) user_management ;;
        2) app_management ;;
        3) config_management ;;
        4) database_operations ;;
        5) filesystem_operations ;;
        6) view_logs ;;
        7) exit 0 ;;
        *) echo "Invalid option"; main_menu ;;
    esac
}

# User management
user_management() {
    echo -e "${BLUE}User Management${NORMAL}"
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. List Users"
    echo "4. Return to main menu"
    read -p "Choose an option: " choice

    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) main_menu ;;
        *) echo "Invalid option"; user_management ;;
    esac
}

# Add user function
add_user() {
    read -p "Enter username: " username
    read -p "Enter email: " email
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ user:add $username $email"
    user_management
}

# Delete user function
delete_user() {
    read -p "Enter username to delete: " username
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ user:delete $username"
    user_management
}

# List users function
list_users() {
    echo -e "${BLUE}Listing all users:${NORMAL}"
    sudo -u www-data php $NEXTCLOUD_PATH/occ user:list
    user_management
}

# App management
app_management() {
    echo -e "${BLUE}App Management${NORMAL}"
    echo "1. Install App"
    echo "2. Remove App"
    echo "3. Update App"
    echo "4. Return to main menu"
    read -p "Choose an option: " choice

    case $choice in
        1) install_app ;;
        2) remove_app ;;
        3) update_app ;;
        4) main_menu ;;
        *) echo "Invalid option"; app_management ;;
    esac
}

# Install app function
install_app() {
    read -p "Enter app name: " app_name
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ app:install $app_name"
    app_management
}

# Remove app function
remove_app() {
    read -p "Enter app name: " app_name
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ app:remove $app_name"
    app_management
}

# Update app function
update_app() {
    read -p "Enter app name to update (or 'all' to update all apps): " app_name
    if [ "$app_name" == "all" ]; then
        run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ app:update --all"
    else
        run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ app:update $app_name"
    fi
    app_management
}

# Configuration management
config_management() {
    echo -e "${BLUE}Configuration Management${NORMAL}"
    echo "1. Set Configuration Values"
    echo "2. Upload Max Filesize"
    echo "3. Maintenance Mode"
    echo "4. Return to main menu"
    read -p "Choose an option: " choice

    case $choice in
        1) set_config_values ;;
        2) upload_max_filesize ;;
        3) maintenance_mode ;;
        4) main_menu ;;
        *) echo "Invalid option"; config_management ;;
    esac
}

# Set configuration values function
set_config_values() {
    read -p "Enter config key: " config_key
    read -p "Enter config value: " config_value
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ config:system:set $config_key --value=$config_value"
    config_management
}

# Upload max filesize function
upload_max_filesize() {
    read -p "Enter max upload size (in MB): " size
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ config:system:set php.upload_max_filesize --value=${size}M"
    config_management
}

# Toggle maintenance mode function
maintenance_mode() {
    read -p "Enable or disable maintenance mode? (enable/disable): " mode
    run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ maintenance:mode $mode"
    config_management
}

# Database operations
database_operations() {
    echo -e "${BLUE}Database Operations${NORMAL}"
    echo "1. db:add-missing-indicies"
    echo "2. db:add-missing-columns"
    echo "3. db:convert-filecache"
    echo "4. Return to main menu"
    read -p "Choose an option: " choice

    case $choice in
        1) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ db:add-missing-indicies" ;;
        2) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ db:add-missing-columns" ;;
        3) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ db:convert-filecache" ;;
        4) main_menu ;;
        *) echo "Invalid option"; database_operations ;;
    esac
}

# Filesystem operations
filesystem_operations() {
    echo -e "${BLUE}Filesystem Operations${NORMAL}"
    echo "1. files:scan --all"
    echo "2. files:scan --unscanned"
    echo "3. files:cleanup"
    echo "4. files:copy"
    echo "5. files:delete"
    echo "6. Return to main menu"
    read -p "Choose an option: " choice

    case $choice in
        1) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ files:scan --all" ;;
        2) 
            read -p "Enter user ID or type 'all' to scan for all users: " user_id
            if [ "$user_id" == "all" ]; then
                run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ files:scan --unscanned --all"
            else
                run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ files:scan --unscanned $user_id"
            fi
            ;;
        3) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ files:cleanup" ;;
        4) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ files:copy" ;;
        5) run_command "sudo -u www-data php $NEXTCLOUD_PATH/occ files:delete" ;;
        6) main_menu ;;
        *) echo "Invalid option"; filesystem_operations ;;
    esac
}


# View logs function
view_logs() {
    echo -e "${BLUE}Viewing logs:${NORMAL}"
    echo -e "${YELLOW}Nextcloud Maintenance Log:${NORMAL}"
    cat $LOGFILE
    echo -e "${YELLOW}Nextcloud Error Log:${NORMAL}"
    cat $ERROR_LOGFILE
    main_menu
}

# Start the script
main_menu
