#!/bin/bash

# ==========================================================================
# knockknock.sh - SSH Access Management Script
# ==========================================================================
# Created: 2025/04/01
# Author: Marcus Raphelt
# License: GPLv3
#
# Description:
# This script is designed to manage SSH access to a server using UFW (Uncomplicated Firewall).
# It allows access to a specific port (default is 22 for SSH) for a limited time
# based on the presence of a "knock" file. If the knock file is present, it grants
# access to the IP address listed in the file. If the knock file is not present,
# it checks for any unauthorized access and revokes it.
# The script's main purpose is to grant ssh access for those who don't have a static ip address.
# It is designed to be run periodically (e.g., via cron)
# 
# The knock file can be created by any other script or process that wants to grant access.
#
# Requirements:
# - bash
# - ufw
#
# Usage:
# ./knockknock.sh
#
# Configuration:
# Update the variables in the script as needed:
# - KNOCK_FILE: Path to the knock file (default is /tmp/knock.txt)
# - LOG_FILE: Path to the log file (default is /var/log/knock.log)
# - PORT: Port number to allow access to (default is 22)
# - TIMEOUT_HOURS: Time in hours before access expires (default is 1 hour)
# - PERMANENT_IPS: List of IP addresses that should always have access
# ==========================================================================

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

KNOCK_FILE="/tmp/knock.txt"
LOG_FILE="/var/log/knock.log"
PORT=22
TIMEOUT_HOURS=1

# List of IP addresses to ignore (permanent access)
PERMANENT_IPS=("1.1.1.1" "2.2.2.2")

# Log function to add timestamp and write to log file
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check if IP is in permanent list
is_permanent_ip() {
    local check_ip=$1
    for ipaddr in "${PERMANENT_IPS[@]}"; do
        if [ "$ipaddr" == "$check_ip" ]; then
                echo "$ipaddr is permanent"
            return 0  # True, IP is in permanent list
        fi
    done
    return 1  # False, IP is not in permanent list
}

# Get currently allowed IPs from UFW for SSH
get_allowed_ips() {
    ufw status | grep -E "^$PORT" | awk '{print $3}' | sort -u
}

# Check if the knock file exists
if [ -f "$KNOCK_FILE" ]; then
    # Get IP address from the file
    IP=$(cat "$KNOCK_FILE")

    # Validate IP address format (basic validation)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Get the file creation time
        FILE_CREATION=$(stat -c %Y "$KNOCK_FILE")
        CURRENT_TIME=$(date +%s)

        # Calculate the difference in seconds
        TIME_DIFF=$((CURRENT_TIME - FILE_CREATION))
        TIMEOUT_SECONDS=$((TIMEOUT_HOURS * 3600))

        if [ $TIME_DIFF -ge $TIMEOUT_SECONDS ]; then
            # Time expired, revoke access
            ufw delete allow from $IP to any port $PORT
            # Remove the knock file
            rm -f "$KNOCK_FILE"
            log_message "Access for $IP has been revoked (timeout after $TIMEOUT_HOURS hours)"
        else
            # Check if the rule already exists
            if ! ufw status | grep "$PORT.*$IP"; then
                # Allow access
                ufw allow from $IP to any port $PORT
                log_message "command: ufw allow from $IP to any port $PORT"
                log_message "OK: Access granted for $IP to port $PORT"
            fi
            # Calculate remaining time and log it
            REMAINING_SECONDS=$((TIMEOUT_SECONDS - TIME_DIFF))
            REMAINING_HOURS=$((REMAINING_SECONDS / 3600))
            REMAINING_MINUTES=$(((REMAINING_SECONDS % 3600) / 60))
            log_message "Access for $IP to port $PORT will expire in $REMAINING_HOURS hours and $REMAINING_MINUTES minutes"
        fi
    else
        log_message "Invalid IP address format in $KNOCK_FILE"
    fi
else
    # If knock file doesn't exist, check for unauthorized access
    log_message "Knock file not found, checking for unauthorized access"

    # Get all IPs with SSH access
    for IPADDR in $(get_allowed_ips); do
      # Skip IPs that are in the permanent list
        if is_permanent_ip "$IPADDR"; then
            #log_message "IP $IPADDR has permanent access, skipping"
            continue
        fi

        # If IP is not permanent, revoke access
        ufw delete allow from $IPADDR to any port $PORT
        log_message "Unauthorized access revoked for IP $IPADDR (knock file not found)"
    done
fi


