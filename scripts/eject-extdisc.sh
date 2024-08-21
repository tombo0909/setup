#!/usr/bin/env bash
#


# UUID der verschlüsselten Partition
UUID="fa2a1b43-fe24-4213-819f-a3e72d8020b3"  # Ersetzen Sie dies durch die tatsächliche UUID Ihrer verschlüsselten Partition
MAPPER_NAME="toshiba-2TB"
MOUNT_POINT="/run/media/toshiba-2TB"

# Abfrage des sudo-Passworts mit kdialog
SUDO_PASSWORD=$(kdialog --password "Geben Sie Ihr sudo-Passwort ein:")

# Überprüfen, ob ein Passwort eingegeben wurde
if [ -z "$SUDO_PASSWORD" ]; then
    kdialog --error "Es wurde kein Passwort eingegeben. Das Skript wird beendet."
    exit 1
fi

# Finden des Geräts basierend auf der UUID
DEVICE=$(echo "$SUDO_PASSWORD" | sudo -S blkid -o device -t UUID=$UUID)

# Überprüfen, ob das Gerät gefunden wurde
if [ -z "$DEVICE" ]; then
    kdialog --error "Das Gerät mit der UUID $UUID wurde nicht gefunden. Das Skript wird beendet."
    exit 1
fi

# Entmounte das Verzeichnis, falls es gemountet ist
echo "$SUDO_PASSWORD" | sudo -S umount "$MOUNT_POINT"

# Schließe das verschlüsselte Laufwerk
echo "$SUDO_PASSWORD" | sudo -S cryptsetup luksClose "$MAPPER_NAME"

# Schalte das Laufwerk aus
echo "$SUDO_PASSWORD" | sudo -S udisksctl power-off -b "$DEVICE"
