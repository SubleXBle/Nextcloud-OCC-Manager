#!/bin/bash

# Color codes for output
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[33m'
BLUE='\033[34m'

# Path to Nextcloud installation (must be adjusted)
NEXTCLOUD_PATH="/var/www/nextcloud"

# Log files
LOGFILE="/var/log/nextcloud_maintenance.log"
ERROR_LOGFILE="/var/log/nextcloud_error.log"

# Function to execute OCC commands and display output both in the terminal and log file
run_occ_command() {
    sudo -u www-data php "$NEXTCLOUD_PATH/occ" "$@" | tee -a "$LOGFILE"
    if [[ $? -ne 0 ]]; then
        log_error "Command failed: occ $*"
    fi
}

# Function to log errors
log_error() {
    echo -e "${RED}Error: $1${NORMAL}"
    echo "$(date) - $1" | tee -a "$ERROR_LOGFILE"
}

# Menu structure
while true; do
    clear
    echo -e "${BLUE}Nextcloud OCC Command Manager by SubleXBle${NORMAL}"
    echo -e "${GREEN}1. User Management${NORMAL}"
    echo -e "${GREEN}2. App Management${NORMAL}"
    echo -e "${GREEN}3. Configuration Settings${NORMAL}"
    echo -e "${GREEN}4. Database Operations${NORMAL}"
    echo -e "${GREEN}5. Filesystem${NORMAL}"              # Neuer Menüpunkt
    echo -e "${GREEN}6. View Logs${NORMAL}"
    echo -e "${GREEN}7. Exit${NORMAL}"
    read -p "Please choose an option: " choice

    case $choice in
        1)
            # User management
            echo -e "${BLUE}User Management${NORMAL}"
            echo -e "${GREEN}1. Add User${NORMAL}"
            echo -e "${GREEN}2. Delete User${NORMAL}"
            echo -e "${GREEN}3. List Users${NORMAL}"
            read -p "Please choose an option: " user_choice
            case $user_choice in
                1)
                    read -p "Enter the username: " username
                    read -p "Enter the email address: " email
                    run_occ_command user:add "$username" "$email"
                    ;;
                2)
                    read -p "Enter the username to delete: " username
                    run_occ_command user:delete "$username"
                    ;;
                3)
                    run_occ_command user:list
                    ;;
                *)
                    log_error "Invalid option selected for User Management."
                    ;;
            esac
            ;;
        2)
            # App management
            echo -e "${BLUE}App Management${NORMAL}"
            echo -e "${GREEN}1. Install App${NORMAL}"
            echo -e "${GREEN}2. Remove App${NORMAL}"
            echo -e "${GREEN}3. Update App${NORMAL}"
            read -p "Please choose an option: " app_choice
            case $app_choice in
                1)
                    read -p "Enter the app name to install: " app_name
                    run_occ_command app:install "$app_name"
                    ;;
                2)
                    read -p "Enter the app name to remove: " app_name
                    run_occ_command app:remove "$app_name"
                    ;;
                3)
                    echo -e "${GREEN}1. Update a specific app${NORMAL}"
                    echo -e "${GREEN}2. Update all apps${NORMAL}"
                    read -p "Please choose an option: " app_update_choice
                    case $app_update_choice in
                        1)
                            read -p "Enter the app name to update: " app_name
                            run_occ_command app:update "$app_name"
                            ;;
                        2)
                            run_occ_command app:update --all
                            ;;
                        *)
                            log_error "Invalid option selected for App Update."
                            ;;
                    esac
                    ;;
                *)
                    log_error "Invalid option selected for App Management."
                    ;;
            esac
            ;;
        3)
            # Configuration settings
            echo -e "${BLUE}Configuration Settings${NORMAL}"
            echo -e "${GREEN}1. Set Max Upload File Size${NORMAL}"
            echo -e "${GREEN}2. Enable/Disable Maintenance Mode${NORMAL}"
            read -p "Please choose an option: " config_choice
            case $config_choice in
                1)
                    read -p "Enter the max upload file size in MB: " size
                    run_occ_command config:system:set php.memory_limit --value="$size"
                    ;;
                2)
                    echo -e "${GREEN}1. Enable Maintenance Mode${NORMAL}"
                    echo -e "${GREEN}2. Disable Maintenance Mode${NORMAL}"
                    read -p "Please choose an option: " maintenance_choice
                    case $maintenance_choice in
                        1)
                            run_occ_command maintenance:mode --on
                            ;;
                        2)
                            run_occ_command maintenance:mode --off
                            ;;
                        *)
                            log_error "Invalid option selected for Maintenance Mode."
                            ;;
                    esac
                    ;;
                *)
                    log_error "Invalid option selected for Configuration Settings."
                    ;;
            esac
            ;;
        4)
            # Database operations
            echo -e "${BLUE}Database Operations${NORMAL}"
            echo -e "${GREEN}1. Add Missing Indices${NORMAL}"
            read -p "Please choose an option: " db_choice
            case $db_choice in
                1)
                    echo -e "${YELLOW}Running OCC command to add missing indices...${NORMAL}"
                    run_occ_command db:add-missing-indices
                    ;;
                *)
                    log_error "Invalid option selected for Database Operations."
                    ;;
            esac
            ;;
        5)
            # Filesystem operations
            echo -e "${BLUE}Filesystem Operations${NORMAL}"
            echo -e "${GREEN}1. Filescan${NORMAL}"
            read -p "Please choose an option: " fs_choice
            case $fs_choice in
                1)
                    echo -e "${GREEN}1. Scan all files (--all)${NORMAL}"
                    echo -e "${GREEN}2. Scan unscanned files (--unscanned)${NORMAL}"
                    read -p "Please choose an option: " scan_choice
                    case $scan_choice in
                        1)
                            echo -e "${YELLOW}Running files:scan --all...${NORMAL}"
                            run_occ_command files:scan --all
                            ;;
                        2)
                            echo -e "${YELLOW}Running files:scan --unscanned...${NORMAL}"
                            run_occ_command files:scan --unscanned
                            ;;
                        *)
                            log_error "Invalid option selected for Filescan."
                            ;;
                    esac
                    ;;
                *)
                    log_error "Invalid option selected for Filesystem Operations."
                    ;;
            esac
            ;;
        6)
            # View logs
            echo -e "${BLUE}View Logs${NORMAL}"
            echo -e "${GREEN}1. View General Log${NORMAL}"
            echo -e "${GREEN}2. View Error Log${NORMAL}"
            read -p "Please choose an option: " log_choice
            case $log_choice in
                1)
                    less "$LOGFILE"
                    ;;
                2)
                    less "$ERROR_LOGFILE"
                    ;;
                *)
                    log_error "Invalid option selected for View Logs."
                    ;;
            esac
            ;;
        7)
            # Exit
            echo -e "${GREEN}Exiting the script...${NORMAL}"
            exit 0
            ;;
        *)
            log_error "Invalid option selected."
            ;;
    esac
    read -p "Press any key to return to the main menu..." -n 1 -s
done
