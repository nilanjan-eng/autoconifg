#!/bin/bash

# --- Configuration Section ---
# Define paths for configuration files
UH_CONFIG_FILE="/var/opt/htm/config/UpdateHandler.config"
VAL_CONFIG_FILE="/var/opt/htm/config/Validator.config"
DSM_CONFIG_FILE="/var/opt/htm/config/DeviceServiceMonitor.config"
PTOPROF_FILE="/etc/profile.d/pto-profile.sh"

# Define new IP base
IP_BASE="172.23.26.23"
IP_BASE_PTO="172.23.26."
OLD_IP_SFTP="10.152.20.111"
OLD_IP_DSM="10.210.13.200"
OLD_IP_GATEWAY="192.168.31"

# Backup list of config files
CONFIG_FILES_TO_BACKUP=("$UH_CONFIG_FILE" "$VAL_CONFIG_FILE" "$DSM_CONFIG_FILE" "$PTOPROF_FILE")

# --- Functions ---

# Backup function
backup_config_files() {
    echo "--- Starting Backup ---"
    for file in "${CONFIG_FILES_TO_BACKUP[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "${file}.bak"
            echo "Backed up '$file' to '${file}.bak'"
        else
            echo "Warning: File '$file' not found. Skipping backup."
        fi
    done
    echo "--- Backup Complete ---"
    echo
}

# Unified update function with better POSIX compliance and clearer output
update_config() {
    local file="$1"
    shift

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found. Cannot update."
        return 1
    fi

    echo "Processing updates for: $file"
    while [[ $# -gt 0 ]]; do
        echo "  Applying sed: $1"
        sed -i "$1" "$file"
        if [[ $? -ne 0 ]]; then
            echo "  Error: sed command failed on file '$file'."
            # Optional: return 1 # Uncomment to stop on first error
        fi
        shift
    done
    return 0
}

# --- Main Execution ---

backup_config_files

# --- Update Validator.config ---
echo "--- Updating Validator.config ---"
update_config "$VAL_CONFIG_FILE" \
    's|<MinimumLogLevel>Info</MinimumLogLevel>|<MinimumLogLevel>Debug</MinimumLogLevel>|' \
    's|<S9Server type="SFTP">|<S9Server type="FTP">|' \
    's|<TxArServer type="SFTP">|<TxArServer type="FTP">|' \
    's|<EodServer type="SFTP">|<EodServer type="FTP">|' \
    "s|<EndPoint>${OLD_IP_SFTP}:22</EndPoint>|<EndPoint>${IP_BASE}:21</EndPoint>|"
    

if [[ $? -eq 0 ]]; then
    echo "Validator.config update attempt finished successfully."
else
    echo "Validator.config update attempt had errors."
fi

# --- Update UpdateHandler.config ---
echo
echo "--- Updating UpdateHandler.config ---"
update_config "$UH_CONFIG_FILE" \
    's|<MinimumLogLevel>Info</MinimumLogLevel>|<MinimumLogLevel>Debug</MinimumLogLevel>|' \
    's|<DownloadServer type="SFTP">|<DownloadServer type="FTP">|' \
    "s|<EndPoint>.*</EndPoint>|<EndPoint>${IP_BASE}:21</EndPoint>|" \
    's|<RemoteFolder>.*</RemoteFolder>|<RemoteFolder>/update/</RemoteFolder>|'

if [[ $? -eq 0 ]]; then
    echo "UpdateHandler.config update attempt finished successfully."
else
    echo "UpdateHandler.config update attempt had errors."
fi

# --- Update DeviceServiceMonitor.config ---
echo
echo "--- Updating DeviceServiceMonitor.config ---"
update_config "$DSM_CONFIG_FILE" \
    "s|<Server>${OLD_IP_DSM}</Server>|<Server>${IP_BASE_PTO}.1</Server>|"

if [[ $? -eq 0 ]]; then
    echo "DeviceServiceMonitor.config update attempt finished successfully."
else
    echo "DeviceServiceMonitor.config update failed or had errors."
fi

# --- Update pto-profile.sh ---
echo
echo "--- Updating pto-profile.sh ---"
update_config "$PTOPROF_FILE" \
    "s|DEVICE_BASE_IP=\"${OLD_IP_GATEWAY}\\.\"|DEVICE_BASE_IP=\"${IP_BASE}.\"|" \
    's|export GATEWAY="${DEVICE_BASE_IP}.*"|export GATEWAY="${DEVICE_BASE_IP}1"|'

if [[ $? -eq 0 ]]; then
    echo "pto-profile.sh update attempt finished successfully."
    echo "- Note: Changed DEVICE_BASE_IP to \"${IP_BASE}.\""
    echo "- Note: Updated GATEWAY to use \${DEVICE_BASE_IP}1"
else
    echo "pto-profile.sh update attempt failed or had errors."
fi

# --- Final Summary ---
echo
echo "--- All configuration file update attempts are complete. Check logs above for errors. ---"