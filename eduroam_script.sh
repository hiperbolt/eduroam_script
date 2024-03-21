#!/bin/bash

# Function to check if connected to a network
check_connection() {
    connected=$(nmcli -t -f GENERAL.STATE device show | grep -oP '^GENERAL.STATE:\K(.+)' | head -n 1)
    [ "$connected" = "100 (connected)" ]
}

# Function to check internet connectivity
check_internet() {
    ping -c 1 -w 1 8.8.8.8 > /dev/null
}

# Function to get the name of the currently connected WiFi network
get_current_wifi() {
    current_wifi=$(nmcli -t -f NAME connection show --active | grep -oP '^\K(.+)' | head -n 1)
    echo "$current_wifi"
}

# Function to reconnect to the WiFi network
reconnect_wifi() {
    wifi_name=$1
    if [ -z "$wifi_name" ]; then
        echo "Error: No WiFi network specified."
        exit 1
    fi
    nmcli con down "$wifi_name"
    nmcli con up "$wifi_name"
}

# Main script
while true; do
    if check_connection && ! check_internet; then
        echo "on cond"
        current_wifi=$(get_current_wifi)
        if [ -z "$current_wifi" ]; then
            echo "Error: No WiFi network currently connected."
            exit 1
        fi

        echo "Currently connected WiFi network: $current_wifi"
        echo "Reconnecting to $current_wifi..."
        reconnect_wifi "$current_wifi"
        echo "Reconnection to $current_wifi successful."
    else
        echo "Already connected to a network or internet connection is available."
    fi
    sleep 5
done

