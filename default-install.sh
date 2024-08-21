#!/usr/bin/env bash
#

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

sudo mkdir -p /home/tom/.config/i3
sudo cp -r /home/nixos/setup /home/tom/
sudo cp /home/tom/setup/i3/config /home/tom/.config/i3/config

# Das soll nur bei Encryption hinzugefügt werden
sudo grep -q 'boot.initrd.luks.devices' /mnt/etc/nixos/hardware-configuration.nix || sudo sed -i.bak '/^}$/i\  boot.initrd.luks.devices = {\n  root = {\n    device = "'"$LVM_PARTITION"'";\n    preLVM = true;\n   };\n };' /mnt/etc/nixos/hardware-configuration.nix

cd /mnt/
sudo nixos-install
