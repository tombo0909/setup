#!/usr/bin/env bash

# Überprüfen der Internetverbindung
if ! ping -c 1 google.com &> /dev/null; then
    echo "Keine Internetverbindung erkannt."
    read -p "Möchten Sie sich mit einem Netzwerk verbinden? (J/n): " -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ssid=$(kdialog --inputbox "Bitte geben Sie den Netzwerk-Namen (SSID) ein:")
        password=$(kdialog --password "Bitte geben Sie das Netzwerk-Passwort ein:")
        nmcli dev wifi connect "$ssid" password "$password"
    else
        echo "Keine Internetverbindung. Skript wird beendet."
        exit 1
    fi
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

read -p "Möchten Sie einen Fingerabdruck einrichten? (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo fprintd-enroll
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cd /home/tom/
read -p "Möchten Sie das Repository klonen? (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Bitte stecken Sie Ihren YubiKey ein."
    while [ $(lsusb | grep -c 'Yubico') -eq 0 ]; do
        echo -ne "Warten auf YubiKey...\r"
        sleep 0.7
        echo -ne "                     \r"
        sleep 0.7
    done
    echo "YubiKey erkannt."
    if git clone git@github.com:tombo0909/data.git; then
        echo "Das Repository wurde erfolgreich geklont."
    else
        echo "Das Klonen des Repositories ist fehlgeschlagen."
    fi
fi


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cd /home/tom/setup/
git remote set-url origin git@github.com:tombo0909/setup.git
gpg --import /home/tom/setup/public.key
read -p "Möchten Sie das Repository entschlüsseln (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Bitte stecken Sie Ihren YubiKey ein."
    while [ $(lsusb | grep -c 'Yubico') -eq 0 ]; do
        echo -ne "Warten auf YubiKey...\r"
        sleep 0.7
        echo -ne "                     \r"
        sleep 0.7
    done
    echo "YubiKey erkannt."
    cd /home/tom/data
    if git-crypt unlock; then
        echo "Das Repository wurde erfolgreich entschlüsselt."
    else
        echo "Die Entschlüsselung des Repositories ist fehlgeschlagen."
    fi
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "configuration.nix und data Symlinks werden gesetzt."


# Überprüfen und löschen, wenn /etc/nixos/configuration.nix existiert
if [ -e /etc/nixos/configuration.nix ]; then
    sudo rm /etc/nixos/configuration.nix
fi

# Überprüfen und erstellen, wenn der symlink nicht existiert
if [ ! -L /etc/nixos/configuration.nix ]; then
    sudo ln -s /home/tom/setup/configuration.nix /etc/nixos/configuration.nix
fi


# Überprüfen und erstellen, wenn der symlink nicht existiert
if [ ! -L /home/tom/.config/Passwords.kdbx ]; then
    sudo ln -s /home/tom/data/Passwords.kdbx /home/tom/.config/Passwords.kdbx
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Abfrage ob die Sitzung wiederhergestellt werden soll
read -p "Letzte Firefox-Sitzung wiederherstellen? (J/n): " -r
echo

# Überprüfen, ob der Benutzer nicht mit 'N' oder 'n' geantwortet hat
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Firefox-Prozess beenden
    pkill -f firefox
    sleep 0.5

    # Sicherstellen, dass das Profilverzeichnis existiert
    mkdir -p /home/tom/.mozilla/firefox/tom.default

    # profiles.ini ins Firefox-Verzeichnis kopieren
    cp /home/tom/data/firefox/settings/profiles.ini /home/tom/.mozilla/firefox/

    # Wichtige Dateien ins Profilverzeichnis kopieren
    cp ~/data/firefox/settings/key4.db ~/.mozilla/firefox/tom.default/key4.db
    cp ~/data/firefox/settings/logins.json ~/.mozilla/firefox/tom.default/logins.json
    cp ~/data/firefox/settings/user.js ~/.mozilla/firefox/tom.default/user.js
    cp ~/data/firefox/settings/places.sqlite ~/.mozilla/firefox/tom.default/places.sqlite
    cp -r ~/data/firefox/settings/extensions/ ~/.mozilla/firefox/tom.default/

    # Sitzung wiederherstellen
    session_file=/home/tom/.mozilla/firefox/tom.default/sessionstore.jsonlz4
    if [ -f /home/tom/data/firefox/session/recovery.jsonlz4 ]; then
        cp /home/tom/data/firefox/session/recovery.jsonlz4 "$session_file"
        sleep 0.5
        
        # Firefox neu starten
        firefox &
        echo "Letzte Firefox-Sitzung wurde erfolgreich wiederhergestellt."
    else
        echo "Vorherige Sitzung nicht gefunden. Firefox wird nicht wiederhergestellt."
    fi
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

read -p "Möchten Sie die letzte Obsidian-Sitzung wiederherstellen? (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    pkill -f obsidian
    sleep 0.5
    echo '{"vaults":{"ae1d4fd0a33d9f5f":{"path":"/home/tom/data/tom-obsidian","ts":1723243908158,"open":true}}}' > /home/tom/.config/obsidian/obsidian.json
    sleep 0.5
    obsidian > /dev/null 2>&1 &
    echo "Letzte Obsidian-Sitzung wurde erfolgreich wiederhergestellti."
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

read -p "Möchten Sie die letzte Keepassxc-Sitzung wiederherstellen? (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    mkdir -p /home/tom/.cache/keepassxc
    touch /home/tom/.cache/keepassxc/keepassxc.ini
    sed -i '/^LastOpenedDatabases=/c\LastOpenedDatabases=/home/tom/.config/Passwords.kdbx' /home/tom/.cache/keepassxc/keepassxc.ini && grep -q '^LastOpenedDatabases=' /home/tom/.cache/keepassxc/keepassxc.ini || echo 'LastOpenedDatabases=/home/tom/.config/Passwords.kdbx' >> /home/tom/.cache/keepassxc/keepassxc.ini
    sed -i '/^LastDatabases=/c\LastDatabases=/home/tom/.config/Passwords.kdbx' /home/tom/.cache/keepassxc/keepassxc.ini && grep -q '^LastDatabases=' /home/tom/.cache/keepassxc/keepassxc.ini || echo 'LastDatabases=/home/tom/.config/Passwords.kdbx' >> /home/tom/.cache/keepassxc/keepassxc.ini
    sed -i '/^LastActiveDatabase=/c\LastActiveDatabase=/home/tom/.config/Passwords.kdbx' /home/tom/.cache/keepassxc/keepassxc.ini && grep -q '^LastActiveDatabase=' /home/tom/.cache/keepassxc/keepassxc.ini || echo 'LastActiveDatabase=/home/tom/.config/Passwords.kdbx' >> /home/tom/.cache/keepassxc/keepassxc.ini

    echo "Letzte Keepassxc-Sitzung wurde erfolgreich wiederhergestellt."

fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

read -p "Möchten Sie Hibernation einrichten? (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Hibernation wird eingerichtet..."

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
    root_uuid=$(sudo blkid -s UUID -o value /var/swapfile)
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
        sudo sed -i.bak '/^}$/i\  boot.kernelParams = [ "resume=UUID='"$root_uuid"'"' "$config_file"
    fi

    if grep -q 'resume_offset=[0-9]*' "$config_file"; then
        sudo sed -i "s|resume_offset=[0-9]*|resume_offset=${offset}|g" "$config_file"
    else
        sudo sed -i.bak '/^}$/i\  "resume_offset='"$offset"'" ];' "$config_file"
    fi

    echo "Hibernation wurde erfolgreich eingerichtet."
else
    echo "Hibernation wurde nicht eingerichtet."
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "Kernel-Parameter werden eingerichtet..."
#wichtig für Audio auf manchen Geräten
config_file="/etc/nixos/hardware-configuration.nix"
# Überprüfen, ob ein Intel-Chip vorhanden ist
if lspci | grep -q 'Intel'; then
    echo "Intel-Chip erkannt."

    # Überprüfen, ob der Kernel-Parameter bereits vorhanden ist
    if ! grep -q 'snd-intel-dspcfg.dsp_driver=1' "$config_file"; then
        echo "Kernel-Parameter nicht vorhanden. Füge ihn hinzu."

        # Füge den Kernel-Parameter hinzu, wenn er noch nicht existiert
        sudo sed -i '/boot.kernelParams = \[/a\    "snd-intel-dspcfg.dsp_driver=1"' "$config_file"
        
        echo "Kernel-Parameter wurde hinzugefügt."
    else
        echo "Kernel-Parameter bereits vorhanden. Keine Änderung vorgenommen."
    fi
else
    echo "Kein Intel-Chip erkannt. Keine Änderungen vorgenommen."
fi


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "System wird aktualisiert..."

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
sudo nix-channel --update
sudo nixos-rebuild switch

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

read -p "Möchten Sie das Gerät neu starten, um Hibernate zu aktivieren? (J/n): " -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo reboot
else
    echo "Skript abgeschlossen. Bitte starten Sie das Gerät später neu, um Hibernation zu aktivieren."
fi
