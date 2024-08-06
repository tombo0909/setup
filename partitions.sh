#!/usr/bin/env bash



if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <device>"
    exit 1
fi

device=$1

echo "Möchten Sie eine Full-Disk-Encryption durchführen? (ja/nein)"
read encrypt

if [ "$encrypt" != "ja" ]; then
    echo "Verschlüsselung wird übersprungen."
    exit 0
fi

echo "Erstellen der Partitionen..."
parted $device -- mklabel gpt
parted $device -- mkpart primary 1MiB 100%

# Root-Partition verschlüsseln
root_partition="${device}1"

echo "Verschlüsseln der gesamten Festplatte..."
cryptsetup luksFormat $root_partition
cryptsetup open $root_partition cryptroot

echo "Formatieren und Label zuweisen..."
mkfs.ext4 /dev/mapper/cryptroot -L NIXROOT

echo "Mounten der Partition..."
mount /dev/mapper/cryptroot /mnt

# Boot-Partition innerhalb der verschlüsselten Partition erstellen
mkdir -p /mnt/boot
mount ${device}p1 /mnt/boot

echo "Partitionierung und Verschlüsselung abgeschlossen. Fortfahren mit der NixOS-Installation."
