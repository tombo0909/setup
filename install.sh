#!/usr/bin/env bash

# Abfrage, ob die Standardinstallation oder die individuelle Installation durchgeführt werden soll
read -p "Möchten Sie die Standardinstallation oder eine individuelle Installation durchführen? [DEF/ind]: " INSTALLATION_TYPE
INSTALLATION_TYPE=${INSTALLATION_TYPE:-DEF}

if [ "$INSTALLATION_TYPE" == "DEF" ]; then
    # Standardinstallation

    # Define the disk and partition variables
    DISK="/dev/nvme0n1"  # Set this to the correct disk (e.g., /dev/sda)
    BOOT_PARTITION="${DISK}p1"
    LVM_PARTITION="${DISK}p2"

    # Delete all partitions on the disk
    sgdisk --zap-all $DISK

    # Create the EFI boot partition
    sgdisk -n 1:0:+1G -t 1:ef00 $DISK

    # Create the LVM partition with a size of 250 GB
    # sgdisk -n 2:0:+250G -t 2:8e00 $DISK

    # Create the LVM partition using the remaining available space
    sgdisk -n 2:0:0 -t 2:8e00 $DISK

    # Print the partition table to verify
    sgdisk -p $DISK

    # Inform the user that the script has finished partitioning
    echo "Partitioning complete. Proceeding with LUKS setup."

    # You will be asked to enter your passphrase - DO NOT FORGET THIS
    cryptsetup luksFormat $LVM_PARTITION

    # Decrypt the encrypted partition and call it nixos-enc. The decrypted partition
    # will get mounted at /dev/mapper/nixos-enc
    cryptsetup luksOpen $LVM_PARTITION nixos-enc

    # Create the LVM physical volume using nixos-enc
    pvcreate /dev/mapper/nixos-enc

    # Create a volume group that will contain our root and swap partitions
    vgcreate nixos-vg /dev/mapper/nixos-enc

    # Create a logical volume for our root filesystem from all remaining free space.
    # Volume is labeled "root"
    lvcreate -l 100%FREE -n root nixos-vg

    # Create a FAT32 filesystem on our boot partition
    mkfs.vfat -n boot $BOOT_PARTITION

    # Create an ext4 filesystem for our root partition
    mkfs.ext4 -L nixos /dev/nixos-vg/root

    # Mount the root filesystem
    mount /dev/nixos-vg/root /mnt

    # Create and mount the boot directory
    mkdir /mnt/boot
    mount $BOOT_PARTITION /mnt/boot

    # Inform the user that the setup is complete
    echo "Setup complete. Root and boot filesystems are mounted."

    nixos-generate-config --root /mnt
    sudo ln -s /mnt/etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
    sudo cp /home/nixos/setup/configuration.nix /mnt/etc/nixos/configuration.nix

    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager

    sudo nix-channel --update

    sudo cp -r /home/nixos/setup /home/tom/

    # Das soll nur bei Encryption hinzugefügt werden
    sudo grep -q 'boot.initrd.luks.devices' /mnt/etc/nixos/hardware-configuration.nix || sudo sed -i.bak '/^}$/i\  boot.initrd.luks.devices = {\n  root = {\n    device = "'"$LVM_PARTITION"'";\n    preLVM = true;\n   };\n };' /mnt/etc/nixos/hardware-configuration.nix

    cd /mnt/
    sudo nixos-install



else
    # Individuelle Installation

    # Abfrage der Festplatte und Partitionsnamen
    read -p "Geben Sie das Disk-Device ein (z.B. /dev/nvme0n1): " DISK
    declare -A PARTITIONS
    declare -A PART_NAMES
    declare -A LABELS
    declare -A FILESYSTEMS

    # Abfrage der Anzahl der Partitionen
    read -p "Wie viele Partitionen möchten Sie erstellen? " PART_COUNT

    for (( i=1; i<=$PART_COUNT; i++ ))
    do
        read -p "Geben Sie den Partitionsnamen für Partition $i ein (z.B. /dev/nvme0n1p1 oder /dev/sda1): " PART_NAME
        PART_NAMES[$i]=$PART_NAME

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
            LABEL_DEFAULT="BOOT"
            FS_DEFAULT="vfat"
        elif [ $i -eq 2 ]; then
            LABEL_DEFAULT="NIXOS"
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
    read -p "Möchten Sie das Disc-Device verschlüsseln (ja/nein)? " ENCRYPT

    # Löschen aller Partitionen auf der Festplatte
    sgdisk --zap-all $DISK

    # Erstellung der Partitionen
    for (( i=1; i<=$PART_COUNT; i++ ))
    do
        if [ $i -eq 1 ]; then
            sgdisk -n $i:0:${PARTITIONS[$i]} -t $i:ef00 $DISK  # EFI Boot Partition
            BOOT_PARTITION="${PART_NAMES[$i]}"
        else
            sgdisk -n $i:0:${PARTITIONS[$i]} -t $i:8e00 $DISK  # LVM oder normale Partition
            LVM_PARTITION="${PART_NAMES[$i]}"
        fi
    done

    # Partitionstabelle zur Überprüfung anzeigen
    sgdisk -p $DISK

    # Erstellung der Dateisysteme und Labeln der Partitionen
    for (( i=1; i<=$PART_COUNT; i++ ))
    do
        PARTITION="${PART_NAMES[$i]}"
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
    sudo cp -r /home/nixos/setup /home/tom/

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

    cd /mnt/
    sudo nixos-install
fi
