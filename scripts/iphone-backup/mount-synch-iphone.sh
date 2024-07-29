#!/bin/bash
#tagcode=14

lockfile="/tmp/rsync_ifuse.lock"

# Funktion, um den Ordner ~/iphone zu erstellen, ifuse auszuführen und Inhalte zu synchronisieren
create_and_sync_pics_folder() {
    # Erstelle den Ordner und führe ifuse aus, wenn nicht vorhanden
    if [ ! -d "$HOME/iphone" ]; then
       mkdir ~/iphone && ifuse ~/iphone
    fi

    # Synchronisiere die Bilder
    rsync -av "$HOME/iphone/DCIM/" "$HOME/Documents/Iphone/Bilder"
}

# Prüfe, ob bereits ein Prozess läuft
if [ -e "$lockfile" ]; then
    echo "Ein anderer Synchronisationsprozess läuft bereits."
    exit 0  # Beendet das Skript sofort
fi

# Erstelle eine Lock-Datei, um zu signalisieren, dass ein Prozess läuft
touch "$lockfile"

# Erstelle den Ordner ~/iphone, führe ifuse aus und synchronisiere
create_and_sync_pics_folder

# Entferne die Lock-Datei nach Abschluss
rm -f "$lockfile"

# Füge eine kurze Pause hinzu, um das System nicht zu überlasten (optional)
sleep 5
