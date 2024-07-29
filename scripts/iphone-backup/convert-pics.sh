#!/bin/bash
#tagcode=12

# Setze das Basisverzeichnis, in dem die Unterordner durchsucht werden sollen
BASEDIR=$HOME/Documents/Iphone/Bilder

# Setze das Zielverzeichnis für die konvertierten Dateien
OUTPUTDIR=$HOME/Documents/Iphone/convertedBilder

# Erstelle das Ausgabeverzeichnis, falls es noch nicht existiert
mkdir -p "$OUTPUTDIR"


# Erstelle das Ausgabeverzeichnis, falls es noch nicht existiert
mkdir -p "$OUTPUTDIR"

# Navigiere durch alle Unterordner und kopiere alle Nicht-HEIC-Dateien ins Zielverzeichnis
find "$BASEDIR" -type f ! -name "*.HEIC" -exec rsync -av {} "$OUTPUTDIR/" \;

# Navigiere durch alle Unterordner und finde HEIC-Dateien zur Konvertierung
find "$BASEDIR" -type f -name "*.HEIC" | while read file; do
    # Extrahiere den Dateinamen ohne Erweiterung
    filename=$(basename "$file" .HEIC)

    # Definiere den Pfad für die Ausgabedatei
    output="$OUTPUTDIR/${filename}.jpg"

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
