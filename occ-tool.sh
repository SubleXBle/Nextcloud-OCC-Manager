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
    echo -e "${GREEN}5. Filesystem${NORMAL}"
    echo -e "${GREEN}6. View Logs${NORMAL}"
    echo -e "${GREEN}7. Exit${NORMAL}"
    read -p "Please choose an option: " choice

    case $choice in
        5)
            # Filesystem operations
            while true; do
                clear
                echo -e "${BLUE}Filesystem Operations${NORMAL}"
                echo -e "${GREEN}1. Filescan (--all, --unscanned)${NORMAL}"
                echo -e "${GREEN}2. Cleanup Filecache (files:cleanup)${NORMAL}"
                echo -e "${GREEN}3. Copy a File/Folder (files:copy)${NORMAL}"
                echo -e "${GREEN}4. Delete a File/Folder (files:delete)${NORMAL}"
                echo -e "${GREEN}5. Get File Contents (files:get)${NORMAL}"
                echo -e "${GREEN}6. Move a File/Folder (files:move)${NORMAL}"
                echo -e "${GREEN}7. Write Contents to a File (files:put)${NORMAL}"
                echo -e "${GREEN}8. List File Reminders (files:reminders)${NORMAL}"
                echo -e "${GREEN}9. Back to Main Menu${NORMAL}"
                read -p "Please choose an option: " fs_choice

                case $fs_choice in
                    1)
                        echo -e "${GREEN}1. Scan all files (--all)${NORMAL}"
                        echo -e "${GREEN}2. Scan unscanned files (--unscanned)${NORMAL}"
                        read -p "Please choose an option: " scan_choice
                        case $scan_choice in
                            1) run_occ_command files:scan --all ;;
                            2) run_occ_command files:scan --unscanned ;;
                            *) log_error "Invalid option for Filescan." ;;
                        esac
                        ;;
                    2)
                        echo -e "${YELLOW}Cleaning up filecache...${NORMAL}"
                        run_occ_command files:cleanup
                        ;;
                    3)
                        read -p "Source file/folder path: " source
                        read -p "Destination path: " destination
                        run_occ_command files:copy "$source" "$destination"
                        ;;
                    4)
                        read -p "File/folder path to delete: " path
                        run_occ_command files:delete "$path"
                        ;;
                    5)
                        read -p "File path to retrieve contents: " path
                        run_occ_command files:get "$path"
                        ;;
                    6)
                        read -p "Source file/folder path: " source
                        read -p "Destination path: " destination
                        run_occ_command files:move "$source" "$destination"
                        ;;
                    7)
                        read -p "File path to write contents to: " path
                        read -p "Enter the contents (use quotes for multiple words): " content
                        run_occ_command files:put "$path" "$content"
                        ;;
                    8)
                        echo -e "${YELLOW}Listing file reminders...${NORMAL}"
                        run_occ_command files:reminders
                        ;;
                    9)
                        break
                        ;;
                    *)
                        log_error "Invalid option selected for Filesystem Operations."
                        ;;
                esac
                read -p "Press any key to return to the Filesystem menu..." -n 1 -s
            done
            ;;
        6)
            # View logs
            echo -e "${BLUE}View Logs${NORMAL}"
            echo -e "${GREEN}1. View General Log${NORMAL}"
            echo -e "${GREEN}2. View Error Log${NORMAL}"
            read -p "Please choose an option: " log_choice
            case $log_choice in
                1) less "$LOGFILE" ;;
                2) less "$ERROR_LOGFILE" ;;
                *) log_error "Invalid option selected for View Logs." ;;
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
