#!/usr/bin/env bash

# Funktion zur Überprüfung des Batteriestatus
check_battery_status() {
    # Ladezustand der Batterie in Prozent ermitteln
    battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
    battery_status=$(cat /sys/class/power_supply/BAT0/status)

    # Batteriewert aufrunden

    # Überprüfen, ob der Ladezustand unter 20% fällt und die Batterie nicht geladen wird
    if [ "$battery_level" -lt 15 ] && [ "$battery_status" != "Charging" ]; then
        DISPLAY=:0 notify-send -u critical -t 8000 -i dialog-warning "Battery Warning" "Battery level is below 15%! Current level: $battery_level%"
    fi
}

# Batteriestatus überprüfen
check_battery_status
