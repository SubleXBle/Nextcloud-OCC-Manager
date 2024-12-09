#!/bin/bash

# Nextcloud OCC Manager
# A tool for Nextcloud administrators to interact with the OCC CLI via an interactive menu.
# Use at your own risk! This script comes with no warranty.

# Color codes for output
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'

# Path to Nextcloud installation
NEXTCLOUD_PATH="/var/www/nextcloud"

# Log files
LOGFILE="/var/log/nextcloud_maintenance.log"
ERROR_LOGFILE="/var/log/nextcloud_error.log"

# Function to run OCC commands and log the output
run_occ_command() {
    COMMAND="sudo -u www-data php $NEXTCLOUD_PATH/occ $*"
    echo -e "${BLUE}Running command: ${YELLOW}$COMMAND${NORMAL}"
    OUTPUT=$($COMMAND 2>&1 | tee -a "$LOGFILE")
    EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
        log_error "Command failed: occ $*"
        echo "$OUTPUT" | tee -a "$ERROR_LOGFILE"
    else
        echo -e "${GREEN}Success:${NORMAL} Command executed successfully."
    fi
}

# Function to log errors
log_error() {
    echo -e "${RED}Error: $1${NORMAL}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" | tee -a "$ERROR_LOGFILE"
}

# Function to display logs
view_logs() {
    echo -e "${BLUE}1. View General Log${NORMAL}"
    echo -e "${BLUE}2. View Error Log${NORMAL}"
    read -p "Choose an option: " log_choice
    case $log_choice in
        1) less "$LOGFILE" ;;
        2) less "$ERROR_LOGFILE" ;;
        *) echo -e "${RED}Invalid option.${NORMAL}" ;;
    esac
}

# Main menu loop
while true; do
    clear
    echo -e "${BLUE}Nextcloud OCC Manager${NORMAL}"
    echo -e "${GREEN}1. User Management${NORMAL}"
    echo -e "${GREEN}2. App Management${NORMAL}"
    echo -e "${GREEN}3. Configuration Settings${NORMAL}"
    echo -e "${GREEN}4. Database Operations${NORMAL}"
    echo -e "${GREEN}5. Filesystem${NORMAL}"
    echo -e "${GREEN}6. View Logs${NORMAL}"
    echo -e "${GREEN}7. Exit${NORMAL}"
    read -p "Please choose an option: " choice

    case $choice in
        1)
            # User Management
            echo -e "${BLUE}User Management${NORMAL}"
            echo -e "${GREEN}1. Add User${NORMAL}"
            echo -e "${GREEN}2. Delete User${NORMAL}"
            echo -e "${GREEN}3. List Users${NORMAL}"
            read -p "Choose an option: " user_choice
            case $user_choice in
                1)
                    read -p "Enter username: " username
                    read -p "Enter email: " email
                    run_occ_command user:add --display-name "$username" --email "$email" "$username"
                    ;;
                2)
                    read -p "Enter username to delete: " username
                    run_occ_command user:delete "$username"
                    ;;
                3)
                    run_occ_command user:list
                    ;;
                *)
                    log_error "Invalid option for User Management."
                    ;;
            esac
            ;;
        2)
            # App Management
            echo -e "${BLUE}App Management${NORMAL}"
            echo -e "${GREEN}1. Install App${NORMAL}"
            echo -e "${GREEN}2. Remove App${NORMAL}"
            echo -e "${GREEN}3. Update Apps${NORMAL}"
            read -p "Choose an option: " app_choice
            case $app_choice in
                1)
                    read -p "Enter app name to install: " app_name
                    run_occ_command app:install "$app_name"
                    ;;
                2)
                    read -p "Enter app name to remove: " app_name
                    run_occ_command app:remove "$app_name"
                    ;;
                3)
                    read -p "Update all apps? (yes/no): " update_choice
                    if [[ "$update_choice" == "yes" ]]; then
                        run_occ_command app:update --all
                    else
                        read -p "Enter app name to update: " app_name
                        run_occ_command app:update "$app_name"
                    fi
                    ;;
                *)
                    log_error "Invalid option for App Management."
                    ;;
            esac
            ;;
        3)
            # Configuration Settings
            echo -e "${BLUE}Configuration Settings${NORMAL}"
            echo -e "${GREEN}1. Toggle Maintenance Mode${NORMAL}"
            echo -e "${GREEN}2. Set Upload Max Filesize${NORMAL}"
            read -p "Choose an option: " config_choice
            case $config_choice in
                1)
                    read -p "Enable maintenance mode? (yes/no): " maintenance
                    if [[ "$maintenance" == "yes" ]]; then
                        run_occ_command maintenance:mode --on
                    else
                        run_occ_command maintenance:mode --off
                    fi
                    ;;
                2)
                    read -p "Enter max upload size in MB: " size
                    run_occ_command config:system:set upload_max_filesize --value="${size}M"
                    ;;
                *)
                    log_error "Invalid option for Configuration Settings."
                    ;;
            esac
            ;;
        4)
            # Database Operations
            echo -e "${BLUE}Database Operations${NORMAL}"
            echo -e "${GREEN}1. Add Missing Indices${NORMAL}"
            read -p "Choose an option: " db_choice
            case $db_choice in
                1)
                    run_occ_command db:add-missing-indices
                    ;;
                *)
                    log_error "Invalid option for Database Operations."
                    ;;
            esac
            ;;
        5)
            # Filesystem
            echo -e "${BLUE}Filesystem Operations${NORMAL}"
            echo -e "${GREEN}1. Scan Files (--all)${NORMAL}"
            echo -e "${GREEN}2. Scan Unscanned Files${NORMAL}"
            echo -e "${GREEN}3. Cleanup File Cache${NORMAL}"
            read -p "Choose an option: " fs_choice
            case $fs_choice in
                1)
                    run_occ_command files:scan --all
                    ;;
                2)
                    run_occ_command files:scan --unscanned
                    ;;
                3)
                    run_occ_command files:cleanup
                    ;;
                *)
                    log_error "Invalid option for Filesystem Operations."
                    ;;
            esac
            ;;
        6)
            # View Logs
            view_logs
            ;;
        7)
            # Exit
            echo -e "${GREEN}Exiting...${NORMAL}"
            exit 0
            ;;
        *)
            log_error "Invalid option selected."
            ;;
    esac
    read -p "Press any key to return to the main menu..." -n 1 -s
done
