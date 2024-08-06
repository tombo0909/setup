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

echo "Wie viele Partitionen möchten Sie innerhalb der verschlüsselten Festplatte erstellen?"
read partition_count

declare -a partition_sizes
for ((i=1; i<$partition_count; i++))
do
    echo "Geben Sie die Größe der Partition $i in MiB an:"
    read size
    partition_sizes+=($size)
done

# Letzte Partition
echo "Soll die letzte Partition den gesamten restlichen Speicherplatz verwenden? (ja/nein)"
read use_rest

if [ "$use_rest" != "ja" ]; then
    echo "Geben Sie die Größe der letzten Partition in MiB an:"
    read size
    partition_sizes+=($size)
fi

# Verschlüssele die gesamte Festplatte
echo "Verschlüsseln der gesamten Festplatte..."
cryptsetup luksFormat $device
cryptsetup open $device cryptroot

# Erstelle ein virtuelles Partitionierungsschema auf der verschlüsselten Festplatte
pvcreate /dev/mapper/cryptroot
vgcreate vgcrypt /dev/mapper/cryptroot

start=1
for ((i=1; i<$partition_count; i++))
do
    lvcreate -L ${partition_sizes[$i-1]}MiB -n lv$i vgcrypt
done

if [ "$use_rest" == "ja" ]; then
    lvcreate -l 100%FREE -n lv$partition_count vgcrypt
else
    lvcreate -L ${partition_sizes[$partition_count-1]}MiB -n lv$partition_count vgcrypt
fi

# Formatieren und Label zuweisen
mkfs.fat -F 32 /dev/vgcrypt/lv1
fatlabel /dev/vgcrypt/lv1 NIXBOOT
mkfs.ext4 /dev/vgcrypt/lv2 -L NIXROOT

# Mounten der Partitionen
mount /dev/vgcrypt/lv2 /mnt
mkdir -p /mnt/boot
mount /dev/vgcrypt/lv1 /mnt/boot

echo "Partitionierung und Verschlüsselung abgeschlossen. Fortfahren mit der NixOS-Installation."
