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

echo "Wie viele Partitionen möchten Sie erstellen?"
read partition_count

declare -a partition_sizes
for ((i=1; i<=$partition_count; i++))
do
    echo "Geben Sie die Größe der Partition $i in MiB an:"
    read size
    partition_sizes+=($size)
done

echo "Erstellen der Partitionen..."
parted $device -- mklabel gpt

start=1
for ((i=1; i<$partition_count; i++))
do
    end=$(($start + ${partition_sizes[$i-1]}))
    parted $device -- mkpart primary ${start}MiB ${end}MiB
    start=$end
done
parted $device -- mkpart primary ${start}MiB 100%

echo "Setzen des Boot-Flags auf der ersten Partition..."
parted $device -- set 1 boot on

echo "Verschlüsseln der Root-Partition..."
cryptsetup luksFormat ${device}2
cryptsetup open ${device}2 cryptroot

echo "Formatieren der Partitionen und Label zuweisen..."
mkfs.fat -F 32 ${device}1
fatlabel ${device}1 NIXBOOT
mkfs.ext4 /dev/mapper/cryptroot -L NIXROOT

echo "Mounten der Partitionen..."
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot

echo "Partitionierung und Verschlüsselung abgeschlossen. Fortfahren mit der NixOS-Installation."
