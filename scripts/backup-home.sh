#!/usr/bin/env bash
lockfile="/tmp/rsync.lock"

if [ -e "$lockfile" ]; then
    echo "rsync läuft bereits."
    exit 1
else
    touch "$lockfile"
    # Führe rsync aus
rsync -av --delete --exclude=".cache" $HOME /run/media/toshiba-2TB/backup/laptop/refreshed/
rsync -av --exclude=".cache" $HOME /run/media/toshiba-2TB/backup/laptop/notrefreshed/
  # Entferne Lock-Datei nach Abschluss
    rm "$lockfile"
fi

