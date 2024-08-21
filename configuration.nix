# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:



{  
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.device = "/dev/sda";
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  #  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.


 
#  networking = {
#    wireless = {
#      enable = true;
#      networks = {
#        "FRITZ!Box 7530 KH" = {
#          psk = "";
#        };
#      };
#    };
#  };
  
   
#  nix.gc = {
#    automatic = true;
#    dates = "hourly";
#    options = "--delete-older-than 60d";
#  };


  nix.optimise.automatic = true;
  nix.optimise.dates = [ "12:00" ]; # Optional; allows customizing optimisation schedule
    
  nixpkgs.config.allowUnfree = true;
 
  services.pcscd.enable = true; 

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  #  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  system.activationScripts = {
    startScript = {
      text = ''
${pkgs.coreutils}/bin/mkdir -p /home/tom/.config/polybar
${pkgs.coreutils}/bin/mkdir -p /home/tom/.config/i3
${pkgs.coreutils}/bin/mkdir -p /home/tom/.ssh
${pkgs.coreutils}/bin/mkdir -p /home/tom/.config/scripts
${pkgs.coreutils}/bin/mkdir -p /home/tom/Pictures/iphone
${pkgs.coreutils}/bin/mkdir -p /home/tom/Pictures/screenshots


if [ ! -d "/home/tom/setup" ]; then
    ${pkgs.git}/bin/git clone https://github.com/tombo0909/setup.git /home/tom/setup
fi

if [ ! -d "/home/tom/setup" ]; then
  ${pkgs.coreutils}/bin/cp -r /setup /home/tom/
fi

if [ ! -L "/home/tom/.config/polybar/launch.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/polybar/launch.sh /home/tom/.config/polybar/launch.sh
fi

if [ ! -L "/home/tom/.config/polybar/config.ini" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/polybar/config.ini /home/tom/.config/polybar/config.ini
fi

if [ ! -L "/home/tom/.config/background.jpg" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/background.jpg /home/tom/.config/background.jpg
fi

if [ ! -L "/home/tom/.config/i3/config" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/i3/config /home/tom/.config/i3/config
fi

if [ ! -L "/home/tom/.ssh/known_hosts" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/known_hosts /home/tom/.ssh/known_hosts
fi

if [ ! -L "/home/tom/.config/scripts/backup-home.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/backup-home.sh /home/tom/.config/scripts/backup-home.sh
fi

if [ ! -L "/home/tom/.config/scripts/clean-generations.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/clean-generations.sh /home/tom/.config/scripts/clean-generations.sh
fi

if [ ! -L "/home/tom/.config/scripts/setup-monitor.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/setup-monitor.sh /home/tom/.config/scripts/setup-monitor.sh
fi

if [ ! -L "/home/tom/.config/scripts/update-system.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/update-system.sh /home/tom/.config/scripts/update-system.sh
fi

if [ ! -L "/home/tom/.config/scripts/check-battery.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/check-battery.sh /home/tom/.config/scripts/check-battery.sh
fi

if [ ! -L "/home/tom/.config/scripts/iphone-backup.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/iphone-backup.sh /home/tom/.config/scripts/iphone-backup.sh
fi

if [ ! -L "/home/tom/.config/scripts/post-install.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/post-install.sh /home/tom/.config/scripts/post-install.sh
fi

if [ ! -L "/home/tom/.config/scripts/eject-extdisc.sh" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/eject-extdisc.sh /home/tom/.config/scripts/eject-extdisc.sh
fi

if [ ! -L "/home/tom/.config/scripts/rechteck.py" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/scripts/rechteck.py /home/tom/.config/scripts/rechteck.py
fi

${pkgs.coreutils}/bin/chown -R tom:users /home/tom
interface=$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' | ${pkgs.gnugrep}/bin/grep -E '^(wl|eno|eth)' | ${pkgs.coreutils}/bin/head -n 1);
${pkgs.coreutils}/bin/cp /home/tom/setup/polybar/config.ini /home/tom/setup/polybar/config.ini.bak;
${pkgs.gawk}/bin/awk -v interface="$interface" '/^\[module\/network\]/ { in_network_module = 1 } in_network_module && /^interface =/ { $0 = "interface = " interface; in_network_module = 0 } { print }' /home/tom/setup/polybar/config.ini.bak > /home/tom/setup/polybar/config.ini


      '';
    deps = [];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = /home/tom/.config/i3/config;

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText  "xkb-layout" ''
     
   ! Map umlauts to RIGHT ALT + <key>
        keycode 108 = Mode_switch
        keysym e = e E EuroSign
        keysym c = c C cent
        keysym a = a A adiaeresis Adiaeresis
        keysym o = o O odiaeresis Odiaeresis
        keysym u = u U udiaeresis Udiaeresis
        keysym s = s S ssharp
      ''}"

   # DPMS and Screensaver settings
     xset +dpms
     xset dpms 0 0 540
     xset s 0 0
    '';



  systemd.user.services.setxkbmap = {
    description = "Set X Keyboard Map";
    serviceConfig = {
      ExecStart = "${pkgs.xorg.setxkbmap}/bin/setxkbmap us";
    };
    wantedBy = [ "default.target" ];
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };
 

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
      enable = true;
      touchpad = {
        sendEventsMode = "enabled";
        scrollMethod = "twofinger";
        naturalScrolling = false;
        tapping = true;
        accelProfile = "flat";
        accelSpeed = "1";
      };
    };
 

  services.usbmuxd.enable = true; # for mounting iphone  


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

 
  services.logind = {

	lidSwitch = "suspend-then-hibernate";
	lidSwitchDocked = "suspend-then-hibernate";
	lidSwitchExternalPower = "suspend-then-hibernate";
        powerKey = "suspend-then-hibernate";
	powerKeyLongPress = "hibernate";
	extraConfig = ''
IdleAction=suspend-then-hibernate
IdleActionSec=5s
        '';
  };

  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    percentageLow = 10;
    percentageCritical = 5;
    percentageAction = 3;
    ignoreLid=false;
  };


  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m 
    SuspendState=mem   #suspendtoidle is buggy 
  '';
   
  services.devmon.enable = true;
  services.udisks2.enable = true;



  services.cron = {
    enable = true;
    systemCronJobs = [
     "*/6 * * * * tom /home/tom/.config/scripts/check-battery.sh"
     "*/30 * * * * tom /home/tom/.config/scripts/backup-home.sh"
   ];
  };


  security.pam.services.login = {

  };
   

 
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
   mutableUsers = false;
   users.tom = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
     hashedPassword = "$6$13/UxgqtVvIrUpnW$dd4GyMsqHhWmB26YMtlKnWDmNQecwTy2rZVwFKwVZ.7G78kX7Yg2HIOdIK3RmoJIKjCHwD8Fnr93Oj.lZswjY1";
     packages = with pkgs; [
       firefox
       tree
       vscode
       keepassxc
       kitty
       dmenu
       obsidian
       yubioath-flutter
       yubikey-manager-qt
       jetbrains.idea-ultimate
       gnupg
       spotify
       anki-bin
     ];
  };
};
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "mein-skript" ''
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

# Überprüfen, ob das Remote-Repository bereits gesetzt wurde
REMOTE_URL=$(git remote get-url origin)
if [ "$REMOTE_URL" != "git@github.com:tombo0909/setup.git" ]; then
    git remote set-url origin git@github.com:tombo0909/setup.git
    echo "Git remote URL wurde gesetzt."
else
    echo "Git remote URL ist bereits korrekt."
fi

# Überprüfen, ob der Schlüssel bereits importiert wurde
KEY_FINGERPRINT=$(gpg --with-colons --import-options show-only --import /home/tom/setup/public.key 2>/dev/null | grep '^fpr' | cut -d':' -f10)

if gpg --list-keys | grep -q "$KEY_FINGERPRINT"; then
    echo "Der GPG-Schlüssel ist bereits importiert."
else
    gpg --import /home/tom/setup/public.key
    echo "Der GPG-Schlüssel wurde importiert."
fi

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

echo "Symlinks werden eingerichtet."


# Überprüfen und löschen, wenn /etc/nixos/configuration.nix existiert
if [ -e /etc/nixos/configuration.nix ]; then
    sudo rm /etc/nixos/configuration.nix
fi

# Überprüfen und erstellen, wenn der symlink nicht existiert
if [ ! -L /etc/nixos/configuration.nix ]; then
    sudo ln -s /home/tom/setup/configuration.nix /etc/nixos/configuration.nix
    echo "configuration.nix Symlink wurde erfolgreich gesetzt."
fi


# Überprüfen und erstellen, wenn der symlink nicht existiert
if [ ! -L /home/tom/.config/Passwords.kdbx ]; then
    sudo ln -s /home/tom/data/Passwords.kdbx /home/tom/.config/Passwords.kdbx
    echo "Keepassxc Symlink wurde erfolgreich gesetzt."
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
        sudo sed -i "s|resume=UUID=[a-fA-F0-9-]*|resume=UUID=$root_uuid|g" "$config_file"
    else
        sudo sed -i.bak '/^}$/i\  boot.kernelParams = [ "resume=UUID='"$root_uuid"'"' "$config_file"
    fi

    if grep -q 'resume_offset=[0-9]*' "$config_file"; then
        sudo sed -i "s|resume_offset=[0-9]*|resume_offset=$offset|g" "$config_file"
    else
        sudo sed -i.bak '/^}$/i\  "resume_offset='"$offset"'" ];' "$config_file"
    fi

    echo "Hibernation wurde erfolgreich eingerichtet."
else
    echo "Hibernation wurde nicht eingerichtet."
fi

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


echo "Kernel-Parameter werden eingerichtet..."

config_file="/etc/nixos/hardware-configuration.nix"

# Wichtig für Audio auf manchen Geräten
# Überprüfen, ob ein Intel-Chip vorhanden ist
if lspci | grep -q 'Intel'; then
    echo "Intel-Chip erkannt."

    # Überprüfen, ob der Kernel-Parameter bereits vorhanden ist
    if ! grep -q 'snd-intel-dspcfg.dsp_driver=1' "$config_file"; then
        echo "Kernel-Parameter nicht vorhanden. Füge ihn hinzu."

        # Füge den Kernel-Parameter hinzu, wenn er noch nicht existiert
        # Überprüfe, ob 'boot.kernelParams' existiert, bevor der Parameter hinzugefügt wird
        if grep -q 'boot.kernelParams = \[' "$config_file"; then
            sudo sed -i '/boot.kernelParams = \[/a\    "snd-intel-dspcfg.dsp_driver=1"' "$config_file"
            echo "Kernel-Parameter wurde hinzugefügt."
        else
            echo "Warnung: 'boot.kernelParams' nicht in der Datei gefunden. Parameter konnte nicht hinzugefügt werden."
        fi
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
    '')
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     xclip
     xautolock
     i3lock
     xss-lock
     ranger
     betterlockscreen
     git
     fprintd
     usbutils
     feh
     dunst
     alsa-utils
     polybar
     pavucontrol
     brightnessctl
     networkmanager_dmenu
     bc
     arandr
     xidlehook
     libnotify
     python3
     openjdk11
     playerctl
     jq
     yad
     hwinfo
     killall
     pam
     xorg.xmodmap
     maim
     xdotool
     xdg-utils
     cryptsetup
     xorg.setxkbmap
     kdialog
     libimobiledevice #for mounting iphone 
     ifuse   #for mounting iphone
     libheif #for converting iphone pictures
     pciutils
     usbmuxd
     git-crypt

     qt5Full
     python310Packages.pyqt5


  (vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      ms-python.python
      ];
    })

  ];


  fonts.packages = with pkgs; [
    font-awesome
  ];
    
 
  services.udev.packages = with pkgs; [
    sudo
  ];


  services.udev.extraRules = let
    unlockAndMount = pkgs.writeShellApplication {
      name = "unlockAndMount";
      runtimeInputs = with pkgs; [
        cryptsetup
        kdialog
        coreutils  # Für grundlegende Befehle wie mkdir
        util-linux # Für mount
	libnotify

      ];
      text = ''
export DISPLAY=:0
export XAUTHORITY=/home/tom/.Xauthority

UUID="fa2a1b43-fe24-4213-819f-a3e72d8020b3"
MAPPER_NAME="toshiba-2TB"
MOUNT_POINT="/run/media/toshiba-2TB"
DEVICE=$(blkid -o device -t UUID="$UUID")

while true; do
    PASSPHRASE=$(kdialog --password "Bitte geben Sie das Passwort fuer die verschluesselte Festplatte ein:")

    if [ -n "$PASSPHRASE" ]; then
        if echo "$PASSPHRASE" | cryptsetup luksOpen "$DEVICE" "$MAPPER_NAME"; then
            mkdir -p "$MOUNT_POINT"
            if systemd-mount --no-block /dev/mapper/"$MAPPER_NAME" "$MOUNT_POINT"; then
                break
            else
                cryptsetup luksClose "$MAPPER_NAME"
            fi
        fi
    else
        exit 1
    fi
done
      '';
    };

  in ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="fa2a1b43-fe24-4213-819f-a3e72d8020b3", RUN+="${pkgs.sudo}/bin/sudo -u root ${unlockAndMount}/bin/unlockAndMount"

  '';



  services.fprintd.enable = true;

  services.fprintd.tod.enable = true;

  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  
  home-manager.users.tom = { pkgs, ... }: {
   home.packages = [ 
   pkgs.atool
   pkgs.httpie
   ];
   
   programs.bash = {
        enable = true;
        historySize=-1;
	historyFileSize=-1;
        historyControl = [ "ignoredups" ];

        initExtra = ''
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  
  # append to the history file, don't overwrite it
  shopt -s histappend

  # Ton deaktivieren im Terminal bei Fehler
  bind 'set bell-style none'
   
export PS1='\[\033[1;38;2;255;140;0m\]\u@\h\[\033[1;37m\]:\[\033[1;38;2;255;140;0m\]\w\[\033[00m\]\$ '
alias open='xdg-open'
alias gita='git add .'
alias gitc='git commit -m "c"'
alias gitp='git push'
alias gitf='git add . && git commit -m "c" && git push'
alias update-system='/home/tom/.config/scripts/update-system.sh'
alias privacy-mode='nix-shell -p qt5Full python310Packages.pyqt5 --run "python /home/tom/rechteck.py"'
   '';
  };

  

  programs.neovim = {
    enable = true;
    extraConfig = ''
      lua << EOF
        -- Zeilennummern und relative Zeilennummern aktivieren
        vim.o.number = true
        vim.o.relativenumber = true

        -- Yank into system clipboard
        vim.keymap.set({'n', 'v'}, '<leader>y', '"+y') -- yank motion
        vim.keymap.set({'n', 'v'}, '<leader>Y', '"+Y') -- yank line

        -- Paste from system clipboard
        vim.keymap.set('n', '<leader>p', '"+p')  -- paste after cursor
        vim.keymap.set('n', '<leader>P', '"+P')  -- paste before cursor
      EOF
    ''; 
  };
  

  programs.git = {
    enable = true;
    userName  = "tombo09";
    userEmail = "regular.tb@gmail.com";
  };

  programs.kitty = {
    enable = true;
        extraConfig = ''
      # Setzen Sie Ihre zusätzlichen Kitty-Konfigurationen hier
      enable_audio_bell no
      font_size 12
      background #000000
   '';
   };

  
  home.file.".config/betterlockscreen/betterlockscreenrc" = {
    text = ''
  locktext="Type password to unlock..."
           '';
    };


  home.file.".config/keepassxc/keepassxc.ini" = {
    text = ''
    [General]
    ConfigVersion=2
    OpenPreviousDatabasesOnStartup=true


    [Browser]
    CustomProxyLocation=

    [PasswordGenerator]
    AdditionalChars=
    ExcludedChars=
    Lenght=25

    [Security]
    LockDatabaseIdle=true
    LockDatabaseIdleSecond=240
      '';
  };

   # The state version is required and should stay at the version you
   # originally installed.
   home.stateVersion = "24.05";
  };

  home-manager.backupFileExtension = "backup";
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

