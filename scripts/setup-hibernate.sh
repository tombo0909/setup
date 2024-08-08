#!/usr/bin/env bash
#
# Function to find the largest partition
find_largest_partition() {
  largest_partition=""
  largest_size=0
  
  for partition in $(lsblk -ln -o NAME); do
    size=$(lsblk -ln -o SIZE /dev/$partition | grep -o '[0-9.]*')
    unit=$(lsblk -ln -o SIZE /dev/$partition | grep -o '[A-Z]*')
    
    # Convert size to GB for comparison
    case $unit in
      K) size_in_gb=$(echo "$size / 1024 / 1024" | bc -l) ;;
      M) size_in_gb=$(echo "$size / 1024" | bc -l) ;;
      G) size_in_gb=$size ;;
      T) size_in_gb=$(echo "$size * 1024" | bc -l) ;;
      *) size_in_gb=0 ;;
    esac
    
    # Compare and find the largest partition
    if (( $(echo "$size_in_gb > $largest_size" | bc -l) )); then
      largest_size=$size_in_gb
      largest_partition="/dev/$partition"
    fi
  done
  
  echo "$largest_partition"
}

# Get the total RAM size in MB
total_ram=$(free -m | awk '/^Mem:/{print $2}')

# Turn off swap
sudo swapoff /var/swapfile

# Resize the swap file based on total RAM size (example: same size as RAM)
sudo dd if=/dev/zero of=/var/swapfile bs=1M count=$total_ram

# Set the correct permissions
sudo chmod 600 /var/swapfile

# Set up the swap file
sudo mkswap /var/swapfile

# Turn on swap
sudo swapon /var/swapfile



# Verify Resume Parameters
# Find the offset of the swap file
offset=$(sudo filefrag -v /var/swapfile | grep " 0:" | awk '{print $4}' | sed 's/\.\.//')

# Find the largest partition
root_partition=$(find_largest_partition)
if [[ -z "$root_partition" ]]; then
  echo "Root partition not found."
  exit 1
fi

# Get the UUID of the root partition
root_uuid=$(sudo blkid -s UUID -o value $root_partition)

# Update the configuration
config_file="/etc/nixos/configuration.nix"

sudo sed -i "s|swapDevices = \[ { device = \"/var/swapfile\"; size = [0-9]*; } \];|swapDevices = [ { device = \"/var/swapfile\"; size = $total_ram; } ];|g" $config_file
sudo sed -i "s|boot.resumeDevice = \"/dev/.*\";|boot.resumeDevice = \"$root_partition\";|g" $config_file
sudo sed -i "s|\"resume=UUID=.*\"|\"resume=UUID=${root_uuid}\"|g" $config_file
sudo sed -i "s|\"resume_offset=[0-9]*\"|\"resume_offset=${offset}\"|g" $config_file

echo "Configuration updated successfully."

