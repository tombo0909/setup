#!/usr/bin/env bash

# Liste der erlaubten Geräteseriennummern
ALLOWED_DEVICE_SERIALS=("34Q8W13" "0" "serial-ID-3" "")

# Interner Monitor
IN="eDP-1"
# Externer Monitor
EXT="DP-2"
USE_MONITOR=${1:-no-monitor}
POSITION=${2:-left-of}
MODE=${3:-extend}

# Funktion, um die Seriennummern der Monitore zu erhalten
get_monitor_serials() {
    hwinfo --monitor | grep "Serial ID:" | awk -F ': ' '{print $2}'
}

# Funktion, um die Polybar zu starten
start_polybar() {
    killall -q polybar
    while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
    polybar bar &
}

# Polybar initial stoppen
killall -q polybar

if [ "$USE_MONITOR" == "monitor" ]; then
    # Überprüfen, ob der externe Monitor angeschlossen ist
    if xrandr --query | grep -q "$EXT connected"; then
        # Alle Seriennummern der angeschlossenen Monitore abrufen
        MONITOR_SERIALS=$(get_monitor_serials)

        # Debugging: Seriennummern ausgeben
        echo "Erkannte Seriennummern der Monitore:"
        echo "$MONITOR_SERIALS"

        # Variable zum Verfolgen, ob alle Monitore erlaubt sind
        ALL_ALLOWED=true

        # Überprüfen, ob jede erkannte Seriennummer in der Liste der erlaubten Seriennummern ist
        for serial in $MONITOR_SERIALS; do
            serial=$(echo "$serial" | xargs)  # Entfernt führende und nachfolgende Leerzeichen
            ALLOWED=false
            for allowed_serial in "${ALLOWED_DEVICE_SERIALS[@]}"; do
                if [[ "$serial" == "$allowed_serial" ]]; then
                    ALLOWED=true
                    break
                fi
            done

            if [[ "$ALLOWED" == false ]]; then
                echo "Seriennummer $serial ist nicht erlaubt."
                if ! yad --question --text="Möchten Sie den Monitor mit der Seriennummer $serial verwenden?"; then
                    echo "Benutzer hat die Verwendung des Monitors mit der Seriennummer $serial abgelehnt"
                    exit 1
                else
                    echo "Benutzer hat die Verwendung des Monitors mit der Seriennummer $serial akzeptiert"
                    # Wenn der Benutzer die Verwendung akzeptiert, setzen wir ALLOWED auf true
                    ALLOWED=true
                fi
            else
                echo "Seriennummer $serial ist erlaubt."
            fi

            # Wenn der Benutzer die Verwendung eines fremden Monitors akzeptiert hat, brechen wir die Schleife ab
            if [[ "$ALLOWED" == true ]]; then
                break
            fi
        done

        # Externer Monitor ist erlaubt oder Benutzer hat ihn akzeptiert
        if [ "$MODE" == "mirror" ]; then
            # Monitore spiegeln
            xrandr --output $IN --auto --output $EXT --auto --same-as $IN --primary
            # Polybar neu starten
            start_polybar
        else
            # Monitore erweitern und gemäß der angegebenen Position ausrichten
            xrandr --output $IN --auto --output $EXT --auto --$POSITION $IN --primary

            # Alle Arbeitsbereiche auf den externen Monitor verschieben
            for workspace in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
                i3-msg workspace "$workspace"
                i3-msg move workspace to output $EXT
            done

            # i3-Konfiguration neu laden
            i3-msg restart
        fi
    else
        echo "Externer Monitor ist nicht angeschlossen."
        # Polybar neu starten
        start_polybar
    fi
else
    # Externer Monitor soll nicht verwendet werden
    xrandr --output $IN --auto --output $EXT --off

    # Alle Arbeitsbereiche zurück auf den internen Monitor verschieben
    for workspace in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
        i3-msg workspace "$workspace"
        i3-msg move workspace to output $IN
    done

    # i3-Konfiguration neu laden
    i3-msg restart
fi
