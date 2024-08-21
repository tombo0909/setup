#!/usr/bin/env bash
#

# Abfrage der Festplatte
read -p "Geben Sie das Disk-Device ein (z.B. /dev/nvme0n1): " DISK

# Abfrage der Anzahl der Partitionen
read -p "Wie viele Partitionen möchten Sie erstellen? " PART_COUNT

declare -A PARTITIONS
declare -A LABELS
declare -A FILESYSTEMS

for (( i=1; i<=$PART_COUNT; i++ ))
do
    if [ $i -eq $PART_COUNT ]; then
        read -p "Möchten Sie den verbleibenden Speicherplatz für Partition $i verwenden (ja/nein)? " USE_REST
        if [ "$USE_REST" == "ja" ]; then
            PARTITIONS[$i]=""
        else
            read -p "Geben Sie die Größe der Partition $i in MB ein (z.B. 102400 für 100GB): " SIZE_MB
            PARTITIONS[$i]="${SIZE_MB}M"
        fi
    else
        read -p "Geben Sie die Größe der Partition $i in MB ein (z.B. 102400 für 100GB): " SIZE_MB
        PARTITIONS[$i]="${SIZE_MB}M"
    fi
    
    if [ $i -eq 1 ]; then
        LABEL_DEFAULT="boot"
        FS_DEFAULT="vfat"
    elif [ $i -eq 2 ]; then
        LABEL_DEFAULT="nixos"
        FS_DEFAULT="ext4"
    else
        LABEL_DEFAULT=""
        FS_DEFAULT=""
    fi

    read -p "Geben Sie das Label für Partition $i ein (Standard: $LABEL_DEFAULT): " LABEL
    LABELS[$i]=${LABEL:-$LABEL_DEFAULT}

    read -p "Welches Dateisystem möchten Sie für Partition $i verwenden (Standard: $FS_DEFAULT)? " FS
    FILESYSTEMS[$i]=${FS:-$FS_DEFAULT}
done

# Abfrage, ob die Festplatte verschlüsselt werden soll
read -p "Möchten Sie die Festplatte verschlüsseln (ja/nein)? " ENCRYPT

# Löschen aller Partitionen auf der Festplatte
sgdisk --zap-all $DISK

# Erstellung der Partitionen
for (( i=1; i<=$PART_COUNT; i++ ))
do
    if [ $i -eq 1 ]; then
        sgdisk -n $i:0:${PARTITIONS[$i]} -t $i:ef00 $DISK  # EFI Boot Partition
        BOOT_PARTITION="${DISK}p$i"
    else
        sgdisk -n $i:0:${PARTITIONS[$i]} -t $i:8e00 $DISK  # LVM oder normale Partition
        LVM_PARTITION="${DISK}p$i"
    fi
done

# Partitionstabelle zur Überprüfung anzeigen
sgdisk -p $DISK

# Erstellung der Dateisysteme und Labeln der Partitionen
for (( i=1; i<=$PART_COUNT; i++ ))
do
    PARTITION="${DISK}p$i"
    FS=${FILESYSTEMS[$i]}
    LABEL=${LABELS[$i]}

    if [ "$FS" == "vfat" ]; then
        mkfs.vfat -n "$LABEL" $PARTITION
    elif [ "$FS" == "ext4" ]; then
        mkfs.ext4 -L "$LABEL" $PARTITION
    elif [ "$FS" == "xfs" ]; then
        mkfs.xfs -L "$LABEL" $PARTITION
    elif [ "$FS" == "btrfs" ]; then
        mkfs.btrfs -L "$LABEL" $PARTITION
    else
        echo "Nicht unterstütztes Dateisystem $FS, bitte manuell formatieren."
    fi
done

if [ "$ENCRYPT" == "ja" ]; then
    # Benutzer darüber informieren, dass die Verschlüsselung eingerichtet wird
    echo "Partitionierung abgeschlossen. Verschlüsselung wird eingerichtet."

    # Einrichtung der Verschlüsselung
    cryptsetup luksFormat $LVM_PARTITION
    cryptsetup luksOpen $LVM_PARTITION nixos-enc
    pvcreate /dev/mapper/nixos-enc
    vgcreate nixos-vg /dev/mapper/nixos-enc
    lvcreate -l 100%FREE -n root nixos-vg

    # Root-Dateisystem erstellen und mounten
    mkfs.ext4 -L nixos /dev/nixos-vg/root
    mount /dev/nixos-vg/root /mnt

    # Boot-Verzeichnis erstellen und mounten
    mkdir /mnt/boot
    mount $BOOT_PARTITION /mnt/boot
else
    # Root-Dateisystem erstellen und mounten
    mkfs.ext4 -L nixos $LVM_PARTITION
    mount $LVM_PARTITION /mnt

    # Boot-Verzeichnis erstellen und mounten
    mkdir /mnt/boot
    mount $BOOT_PARTITION /mnt/boot
fi

# NixOS-Konfiguration generieren und System vorbereiten
nixos-generate-config --root /mnt
sudo ln -s /mnt/etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
sudo cp /home/nixos/setup/configuration.nix /mnt/etc/nixos/configuration.nix

if [ "$ENCRYPT" == "ja" ]; then
    # Konfiguration für verschlüsselte Festplatte hinzufügen
    sudo grep -q 'boot.initrd.luks.devices' /mnt/etc/nixos/hardware-configuration.nix || sudo sed -i.bak '/^}$/i\  boot.initrd.luks.devices = {\n  root = {\n    device = "'"$LVM_PARTITION"'";\n    preLVM = true;\n   };\n };' /mnt/etc/nixos/hardware-configuration.nix
fi

# NixOS-Kanäle hinzufügen und aktualisieren
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
sudo nix-channel --update

# i3-Konfiguration einrichten
sudo mkdir -p /home/tom/.config/i3
sudo cp -r /home/nixos/setup /home/tom/
sudo cp /home/tom/setup/i3/config /home/tom/.config/i3/config


# Partitionstabelle anzeigen
lsblk

# Abfrage, ob die Installation gestartet werden soll
read -p "Möchten Sie NixOS jetzt installieren (ja/nein)? " INSTALL

if [ "$INSTALL" == "ja" ]; then
    cd /mnt/
    sudo nixos-install
else
    echo "Installation abgebrochen."
fi
