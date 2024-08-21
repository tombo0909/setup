#!/usr/bin/env bash

lockfile="/tmp/rsync_ifuse.lock"
BASEDIR="/home/tom/Pictures/iphone/"

# Erstelle das Verzeichnis, wenn es nicht existiert
if [ ! -d "$BASEDIR" ]; then
    mkdir -p "$BASEDIR"
fi

# Funktion, um den Ordner /tmp/iphone zu erstellen, ifuse auszuführen und Inhalte zu synchronisieren
create_and_sync_pics_folder() {
    # Erstelle den Ordner und führe ifuse aus, wenn nicht vorhanden
    if [ ! -d "/tmp/iphone" ]; then
       mkdir /tmp/iphone && ifuse /tmp/iphone
    fi
    # Synchronisiere die Bilder
    rsync -av "/tmp/iphone/DCIM/" "$BASEDIR"
}

# Prüfe, ob bereits ein Prozess läuft
if [ -e "$lockfile" ]; then
    echo "Ein anderer Synchronisationsprozess läuft bereits."
    exit 0  # Beendet das Skript sofort
fi

# Erstelle eine Lock-Datei, um zu signalisieren, dass ein Prozess läuft
touch "$lockfile"

# Erstelle den Ordner /tmp/iphone, führe ifuse aus und synchronisiere
create_and_sync_pics_folder

# Entferne die Lock-Datei nach Abschluss
rm -f "$lockfile"

# Füge eine kurze Pause hinzu, um das System nicht zu überlasten (optional)
sleep 5

#-----------------------------------------------------------------------------------------------------------------------------
fusermount -u /tmp/iphone && rmdir /tmp/iphone


# Navigiere durch alle Unterordner und finde HEIC-Dateien zur Konvertierung
find "$BASEDIR" -type f -name "*.HEIC" | while read file; do
    # Extrahiere den Dateinamen ohne Erweiterung
    filename=$(basename "$file" .HEIC)

    # Definiere den Pfad für die Ausgabedatei (gleicher Ordner wie das Original)
    output="${file%.HEIC}.jpg"

    # Überprüfe, ob die JPG-Version bereits existiert, um unnötige Konvertierungen zu vermeiden
    if [ ! -f "$output" ]; then
        # Konvertiere die HEIC-Datei in eine JPG-Datei mit maximaler Qualität
        heif-convert -q 100 "$file" "$output"

        # Optional: Rückmeldung geben, welche Datei konvertiert wurde
        echo "Konvertiert: $file -> $output"
    else
        echo "Datei existiert bereits und wurde übersprungen: $output"
    fi
done

# Nachdem alle HEIC-Dateien konvertiert wurden, lösche alle verbleibenden HEIC-Dateien
find "$BASEDIR" -type f -name "*.HEIC" -exec rm -f {} \;
echo "Alle HEIC-Dateien wurden gelöscht."


