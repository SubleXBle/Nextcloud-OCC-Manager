#!/bin/bash

# Farbcodes
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[33m'
BLUE='\033[34m'

# Logfile-Pfade
LOGFILE="/var/log/nextcloud_maintenance.log"
ERROR_LOGFILE="/var/log/nextcloud_error.log"

# Nextcloud Installation Pfad
NEXTCLOUD_PATH="/var/www/nextcloud"

# Funktionsdefinitionen
echo_success() {
    echo -e "${GREEN}$1${NORMAL}"
}

echo_error() {
    echo -e "${RED}$1${NORMAL}"
}

log_error() {
    echo -e "${RED}Error: $1${NORMAL}"
    echo "$(date) - $1" | tee -a "$ERROR_LOGFILE"
}

run_occ_command() {
    local command=$1
    echo "Führe den Befehl aus: occ $command"
    sudo -u www-data php "$NEXTCLOUD_PATH/occ" $command >> "$LOGFILE" 2>> "$ERROR_LOGFILE"

    if [ $? -ne 0 ]; then
        log_error "Fehler bei der Ausführung des Befehls: occ $command. Details im Logfile."
    else
        echo_success "Befehl erfolgreich ausgeführt: occ $command"
    fi
}

# Benutzerverwaltung Menü
user_management() {
    while true; do
        clear
        echo -e "${YELLOW}Benutzerverwaltung${NORMAL}"
        echo "1) Benutzer hinzufügen"
        echo "2) Benutzer löschen"
        echo "3) Benutzerliste anzeigen"
        echo "4) Zurück zum Hauptmenü"
        read -p "Wähle eine Option (1-4): " user_choice

        case $user_choice in
            1)
                read -p "Gib den Benutzernamen ein: " username
                read -p "Gib die E-Mail-Adresse ein: " email
                run_occ_command "user:add $username $email"
                ;;
            2)
                read -p "Gib den Benutzernamen ein, den du löschen möchtest: " username
                run_occ_command "user:delete $username"
                ;;
            3)
                run_occ_command "user:list"
                ;;
            4)
                break
                ;;
            *)
                echo_error "Ungültige Auswahl."
                ;;
        esac
    done
}

# App-Verwaltung Menü
app_management() {
    while true; do
        clear
        echo -e "${YELLOW}App-Verwaltung${NORMAL}"
        echo "1) App installieren"
        echo "2) App deinstallieren"
        echo "3) App aktualisieren"
        echo "4) Zurück zum Hauptmenü"
        read -p "Wähle eine Option (1-4): " app_choice

        case $app_choice in
            1)
                read -p "Gib den App-Namen ein: " app_name
                run_occ_command "app:install $app_name"
                ;;
            2)
                read -p "Gib den App-Namen ein: " app_name
                run_occ_command "app:remove $app_name"
                ;;
            3)
                read -p "Möchtest du eine bestimmte App aktualisieren? (yes/no): " update_choice
                if [ "$update_choice" == "yes" ]; then
                    read -p "Gib den App-Namen ein: " app_name
                    run_occ_command "app:update $app_name"
                else
                    run_occ_command "app:update --all"
                fi
                ;;
            4)
                break
                ;;
            *)
                echo_error "Ungültige Auswahl."
                ;;
        esac
    done
}

# Konfigurationswerte setzen
set_config_values() {
    echo -e "${YELLOW}Konfiguration setzen${NORMAL}"
    echo "1) Wartungsmodus"
    echo "2) Max. Upload-Größe ändern"
    echo "3) Zurück zum Hauptmenü"
    read -p "Wähle eine Option (1-3): " config_choice

    case $config_choice in
        1)
            read -p "Wartungsmodus aktivieren (true/false): " maintenance
            run_occ_command "config:system:set maintenance --value=$maintenance"
            ;;
        2)
            read -p "Neue Upload-Größe (MB): " size
            run_occ_command "config:system:set upload_max_filesize --value=${size}M"
            ;;
        3)
            return
            ;;
        *)
            echo_error "Ungültige Auswahl."
            ;;
    esac
}

# Dateien-Operationen Menü
filesystem_operations() {
    while true; do
        clear
        echo -e "${BLUE}Filesystem Operations${NORMAL}"
        echo "1) Dateien scannen (alle/unscanned)"
        echo "2) Datei-Cache bereinigen"
        echo "3) Datei/Ordner kopieren"
        echo "4) Datei/Ordner löschen"
        echo "5) Datei-Inhalte anzeigen"
        echo "6) Datei/Ordner verschieben"
        echo "7) Zurück zum Hauptmenü"
        read -p "Wähle eine Option (1-7): " fs_choice

        case $fs_choice in
            1)
                read -p "Scannen aller Dateien (--all) oder nur ungescannte (--unscanned): " scan
                run_occ_command "files:scan $scan"
                ;;
            2)
                run_occ_command "files:cleanup"
                ;;
            3)
                read -p "Quelle: " src
                read -p "Ziel: " dest
                run_occ_command "files:copy $src $dest"
                ;;
            4)
                read -p "Pfad zum Löschen: " path
                run_occ_command "files:delete $path"
                ;;
            5)
                read -p "Dateipfad: " path
                run_occ_command "files:get $path"
                ;;
            6)
                read -p "Quelle: " src
                read -p "Ziel: " dest
                run_occ_command "files:move $src $dest"
                ;;
            7)
                break
                ;;
            *)
                echo_error "Ungültige Auswahl."
                ;;
        esac
    done
}

# Logs anzeigen
view_logs() {
    echo -e "${YELLOW}Logs anzeigen${NORMAL}"
    echo "1) Allgemeines Log anzeigen"
    echo "2) Fehler-Log anzeigen"
    echo "3) Zurück zum Hauptmenü"
    read -p "Wähle eine Option (1-3): " log_choice

    case $log_choice in
        1) less "$LOGFILE" ;;
        2) less "$ERROR_LOGFILE" ;;
        3) return ;;
        *) echo_error "Ungültige Auswahl." ;;
    esac
}

# Hauptmenü
while true; do
    clear
    echo -e "${BLUE}Nextcloud OCC Command Manager${NORMAL}"
    echo "1) Benutzerverwaltung"
    echo "2) App-Verwaltung"
    echo "3) Konfiguration setzen"
    echo "4) Dateien-Operationen"
    echo "5) Logs anzeigen"
    echo "6) Skript beenden"
    read -p "Wähle eine Option (1-6): " choice

    case $choice in
        1) user_management ;;
        2) app_management ;;
        3) set_config_values ;;
        4) filesystem_operations ;;
        5) view_logs ;;
        6) echo_success "Skript wird beendet."; exit 0 ;;
        *) echo_error "Ungültige Auswahl." ;;
    esac
done
