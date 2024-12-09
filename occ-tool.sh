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

run_occ_command() {
    COMMAND="sudo -u www-data php $NEXTCLOUD_PATH/occ $*"
    echo -e "${BLUE}Running command: ${YELLOW}$COMMAND${NORMAL}"
    # Directly output and log the result using tee
    sudo -u www-data php "$NEXTCLOUD_PATH/occ" "$@" 2>&1 | tee -a "$LOGFILE"
    EXIT_CODE=${PIPESTATUS[0]}
    if [[ $EXIT_CODE -ne 0 ]]; then
        log_error "Command failed: occ $*"
    else
        echo -e "${GREEN}Success:${NORMAL} Command executed successfully."
    fi
}

# Main menu
while true; do
    clear
    echo -e "${BLUE}Nextcloud OCC Manager${NORMAL}"
    echo "1) User Management"
    echo "2) App Management"
    echo "3) Configuration Management"
    echo "4) View Logs"
    echo "5) Exit"
    echo -n "Choose an option: "
    read option

    case $option in
        1)
            echo "1) Add User"
            echo "2) Delete User"
            echo "3) List Users"
            echo -n "Choose an option: "
            read user_option
            case $user_option in
                1)
                    echo -n "Enter username: "
                    read username
                    echo -n "Enter email address: "
                    read email
                    run_occ_command user:add "$username" "$email"
                    ;;
                2)
                    echo -n "Enter username to delete: "
                    read delete_user
                    run_occ_command user:delete "$delete_user"
                    ;;
                3)
                    run_occ_command user:list
                    ;;
                *)
                    echo -e "${RED}Invalid option${NORMAL}"
                    ;;
            esac
            ;;
        2)
            echo "1) Install App"
            echo "2) Remove App"
            echo "3) Update App"
            echo -n "Choose an option: "
            read app_option
            case $app_option in
                1)
                    echo -n "Enter app name to install: "
                    read app_name
                    run_occ_command app:install "$app_name"
                    ;;
                2)
                    echo -n "Enter app name to remove: "
                    read app_name
                    run_occ_command app:remove "$app_name"
                    ;;
                3)
                    echo -n "Enter app name to update (or leave empty to update all): "
                    read app_name
                    if [[ -z "$app_name" ]]; then
                        run_occ_command app:update --all
                    else
                        run_occ_command app:update "$app_name"
                    fi
                    ;;
                *)
                    echo -e "${RED}Invalid option${NORMAL}"
                    ;;
            esac
            ;;
        3)
            echo "1) Set Configuration Value"
            echo "2) Upload Max Filesize"
            echo "3) Toggle Maintenance Mode"
            echo -n "Choose an option: "
            read config_option
            case $config_option in
                1)
                    echo -n "Enter configuration key: "
                    read config_key
                    echo -n "Enter configuration value: "
                    read config_value
                    run_occ_command config:system:set "$config_key" --value="$config_value"
                    ;;
                2)
                    echo -n "Enter max upload filesize (in MB): "
                    read filesize
                    run_occ_command config:system:set php.upload_max_filesize --value="$filesize"
                    ;;
                3)
                    echo "1) Enable Maintenance Mode"
                    echo "2) Disable Maintenance Mode"
                    echo -n "Choose an option: "
                    read maintenance_option
                    case $maintenance_option in
                        1)
                            run_occ_command maintenance:mode --on
                            ;;
                        2)
                            run_occ_command maintenance:mode --off
                            ;;
                        *)
                            echo -e "${RED}Invalid option${NORMAL}"
                            ;;
                    esac
                    ;;
                *)
                    echo -e "${RED}Invalid option${NORMAL}"
                    ;;
            esac
            ;;
        4)
            echo -e "${YELLOW}Logs:${NORMAL}"
            echo "1) View regular log"
            echo "2) View error log"
            echo -n "Choose an option: "
            read log_option
            case $log_option in
                1)
                    cat "$LOGFILE"
                    ;;
                2)
                    cat "$ERROR_LOGFILE"
                    ;;
                *)
                    echo -e "${RED}Invalid option${NORMAL}"
                    ;;
            esac
            ;;
        5)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NORMAL}"
            ;;
    esac

    echo -n "Press any key to return to the main menu..."
    read -n 1
done
