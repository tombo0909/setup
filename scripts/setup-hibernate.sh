#!/usr/bin/env bash

# Swap-Datei und Resume-Konfiguration (keine Benutzerabfrage)
find_largest_partition() {
    largest_partition=""
    largest_size=0
    for partition in $(lsblk -ln -o NAME); do
        if [[ $partition == dm-* ]]; then
            continue
        fi
        size=$(lsblk -ln -o SIZE /dev/$partition | grep -o '[0-9.]*')
        unit=$(lsblk -ln -o SIZE /dev/$partition | grep -o '[A-Z]*')
        case $unit in
            K) size_in_gb=$(echo "$size / 1024 / 1024" | bc -l) ;;
            M) size_in_gb=$(echo "$size / 1024" | bc -l) ;;
            G) size_in_gb=$size ;;
            T) size_in_gb=$(echo "$size * 1024" | bc -l) ;;
            *) size_in_gb=0 ;;
        esac
        if (( $(echo "$size_in_gb > $largest_size" | bc -l) )); then
            largest_size=$size_in_gb
            largest_partition="/dev/$partition"
        fi
    done
    echo "$largest_partition"
}

find_encrypted_root_partition() {
    for mapper_partition in $(ls /dev/mapper/*); do
        if [[ $(lsblk -ln -o MOUNTPOINT $mapper_partition) == "/" ]]; then
            echo "$mapper_partition"
            return
        fi
    done
    echo ""
}

total_ram=$(free -m | awk '/^Mem:/{print $2}')
if grep -q '/var/swapfile' /proc/swaps; then
    # Swapfile ist aktiv, swapoff ausführen
    sudo swapoff /var/swapfile
fi
sudo dd if=/dev/zero of=/var/swapfile bs=1M count=$total_ram
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
offset=$(sudo filefrag -v /var/swapfile | grep " 0:" | awk '{print $4}' | sed 's/\.\.//')
root_partition=$(find_encrypted_root_partition)
if [[ -z "$root_partition" ]]; then
    root_partition=$(find_largest_partition)
fi
if [[ -z "$root_partition" ]]; then
    echo "Root partition not found."
    exit 1
fi
root_uuid=$(sudo blkid -s UUID -o value $root_partition)
config_file="/etc/nixos/hardware-configuration.nix"

sudo sed -i '/swapDevices = \[ \];/d' $config_file
if grep -q 'swapDevices = \[.*{.*device = "/var/swapfile";.*size = [0-9]*;.*}.*\];' "$config_file"; then
    sudo sed -i "s|swapDevices = \[.*{.*device = \"/var/swapfile\";.*size = [0-9]*;.*}.*\];|swapDevices = [ { device = \"/var/swapfile\"; size = $total_ram; } ];|g" "$config_file"
else
    sudo sed -i.bak '/^}$/i\  swapDevices = [ { device = "/var/swapfile"; size = '"$total_ram"'; } ];' "$config_file"
fi

if grep -q 'boot.resumeDevice = "/dev/.*";' "$config_file"; then
    sudo sed -i "s|boot.resumeDevice = \"/dev/.*\";|boot.resumeDevice = \"$root_partition\";|g" "$config_file"
else
    sudo sed -i.bak '/^}$/i\  boot.resumeDevice = "'"$root_partition"'";' "$config_file"
fi

if grep -q 'resume=UUID=[a-fA-F0-9-]*' "$config_file"; then
    sudo sed -i "s|resume=UUID=[a-fA-F0-9-]*|resume=UUID=${root_uuid}|g" "$config_file"
else
    sudo sed -i.bak '/^}$/i\  boot.kernelParams = [ "resume=UUID='"$root_uuid"'" ];' "$config_file"
fi

if grep -q 'resume_offset=[0-9]*' "$config_file"; then
    sudo sed -i "s|resume_offset=[0-9]*|resume_offset=${offset}|g" "$config_file"
else
    sudo sed -i.bak '/^}$/i\  "resume_offset='"$offset"'" ];' "$config_file"
fi
