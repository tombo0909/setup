#!/bin/bash
#tagcode=23
lockfile="/tmp/rsync.lock"

if [ -e "$lockfile" ]; then
    echo "rsync läuft bereits."
    exit 1
else
    touch "$lockfile"
    # Führe rsync aus
    rsync -av --delete $HOME /media/$USER/backup/Backup/Laptop/
    rsync -av $HOME /media/$USER/backup/Backup/Laptop/notrefreshed/
    # Entferne Lock-Datei nach Abschluss
    rm "$lockfile"
fi

