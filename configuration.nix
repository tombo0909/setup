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




  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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

    (pkgs.writeShellScriptBin "post-install-test" ''
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
        sudo sed -i "s|resume=UUID=[a-fA-F0-9-]*|resume=UUID=''${root_uuid}|g" "$config_file"
    else
        sudo sed -i.bak '/^}$/i\  boot.kernelParams = [ "resume=UUID='"$root_uuid"'"' "$config_file"
    fi

    if grep -q 'resume_offset=[0-9]*' "$config_file"; then
        sudo sed -i "s|resume_offset=[0-9]*|resume_offset=''${offset}|g" "$config_file"
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

 (pkgs.writeShellScriptBin "backup-home" ''
#!/usr/bin/env bash
lockfile="/tmp/rsync.lock"

if [ -e "$lockfile" ]; then
    echo "rsync läuft bereits."
    exit 1
else
    touch "$lockfile"
    # Führe rsync aus
rsync -av --delete --exclude=".cache" $HOME /run/media/toshiba-2TB/backup/laptop/refreshed/
rsync -av --exclude=".cache" $HOME /run/media/toshiba-2TB/backup/laptop/notrefreshed/
  # Entferne Lock-Datei nach Abschluss
    rm "$lockfile"
fi
  '')
 (pkgs.writeShellScriptBin "check-battery" ''
#!/usr/bin/env bash

# Funktion zur Überprüfung des Batteriestatus
check_battery_status() {
    # Ladezustand der Batterie in Prozent ermitteln
    battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
    battery_status=$(cat /sys/class/power_supply/BAT0/status)

    # Batteriewert aufrunden

    # Überprüfen, ob der Ladezustand unter 20% fällt und die Batterie nicht geladen wird
    if [ "$battery_level" -lt 15 ] && [ "$battery_status" != "Charging" ]; then
        DISPLAY=:0 notify-send -u critical -t 8000 -i dialog-warning "Battery Warning" "Battery level is below 15%! Current level: $battery_level%"
    fi
}

# Batteriestatus überprüfen
check_battery_status

  '')

 (pkgs.writeShellScriptBin "eject-extdisc" ''
#!/usr/bin/env bash
#


# UUID der verschlüsselten Partition
UUID="fa2a1b43-fe24-4213-819f-a3e72d8020b3"  # Ersetzen Sie dies durch die tatsächliche UUID Ihrer verschlüsselten Partition
MAPPER_NAME="toshiba-2TB"
MOUNT_POINT="/run/media/toshiba-2TB"

# Abfrage des sudo-Passworts mit kdialog
SUDO_PASSWORD=$(kdialog --password "Geben Sie Ihr sudo-Passwort ein:")

# Überprüfen, ob ein Passwort eingegeben wurde
if [ -z "$SUDO_PASSWORD" ]; then
    kdialog --error "Es wurde kein Passwort eingegeben. Das Skript wird beendet."
    exit 1
fi

# Finden des Geräts basierend auf der UUID
DEVICE=$(echo "$SUDO_PASSWORD" | sudo -S blkid -o device -t UUID=$UUID)

# Überprüfen, ob das Gerät gefunden wurde
if [ -z "$DEVICE" ]; then
    kdialog --error "Das Gerät mit der UUID $UUID wurde nicht gefunden. Das Skript wird beendet."
    exit 1
fi

# Entmounte das Verzeichnis, falls es gemountet ist
echo "$SUDO_PASSWORD" | sudo -S umount "$MOUNT_POINT"

# Schließe das verschlüsselte Laufwerk
echo "$SUDO_PASSWORD" | sudo -S cryptsetup luksClose "$MAPPER_NAME"

# Schalte das Laufwerk aus
echo "$SUDO_PASSWORD" | sudo -S udisksctl power-off -b "$DEVICE"
'')


(pkgs.writeShellScriptBin "iphone-backup" ''
#!/usr/bin/env bash

lockfile="/tmp/rsync_ifuse.lock"
BASEDIR="/home/tom/Pictures/iphone/"

# Erstelle das Verzeichnis, wenn es nicht existiert
if [ ! -d "$BASEDIR" ]; then
    mkdir -p "$BASEDIR"
fi

# Funktion, um den Ordner /tmp/iphone zu erstellen, ifuse auszuführen und Inhalte zu synchronisieren
create_and_sync_pics_folder() {
    # Erstelle den Ordner und führe ifuse aus, wenn nicht vorhanden
    if [ ! -d "/tmp/iphone" ]; then
       mkdir /tmp/iphone && ifuse /tmp/iphone
    fi
    # Synchronisiere die Bilder
    rsync -av "/tmp/iphone/DCIM/" "$BASEDIR"
}

# Prüfe, ob bereits ein Prozess läuft
if [ -e "$lockfile" ]; then
    echo "Ein anderer Synchronisationsprozess läuft bereits."
    exit 0  # Beendet das Skript sofort
fi

# Erstelle eine Lock-Datei, um zu signalisieren, dass ein Prozess läuft
touch "$lockfile"

# Erstelle den Ordner /tmp/iphone, führe ifuse aus und synchronisiere
create_and_sync_pics_folder

# Entferne die Lock-Datei nach Abschluss
rm -f "$lockfile"

# Füge eine kurze Pause hinzu, um das System nicht zu überlasten (optional)
sleep 5

#-----------------------------------------------------------------------------------------------------------------------------
fusermount -u /tmp/iphone && rmdir /tmp/iphone


# Navigiere durch alle Unterordner und finde HEIC-Dateien zur Konvertierung
find "$BASEDIR" -type f -name "*.HEIC" | while read file; do
    # Extrahiere den Dateinamen ohne Erweiterung
    filename=$(basename "$file" .HEIC)

    # Definiere den Pfad für die Ausgabedatei (gleicher Ordner wie das Original)
    output="''${file%.HEIC}.jpg"

    # Überprüfe, ob die JPG-Version bereits existiert, um unnötige Konvertierungen zu vermeiden
    if [ ! -f "$output" ]; then
        # Konvertiere die HEIC-Datei in eine JPG-Datei mit maximaler Qualität
        heif-convert -q 100 "$file" "$output"

        # Optional: Rückmeldung geben, welche Datei konvertiert wurde
        echo "Konvertiert: $file -> $output"
    else
        echo "Datei existiert bereits und wurde übersprungen: $output"
    fi
done

# Nachdem alle HEIC-Dateien konvertiert wurden, lösche alle verbleibenden HEIC-Dateien
find "$BASEDIR" -type f -name "*.HEIC" -exec rm -f {} \;
echo "Alle HEIC-Dateien wurden gelöscht."
  '')


(pkgs.writeShellScriptBin "setup-monitor" ''
#!/usr/bin/env bash

# Liste der erlaubten Geräteseriennummern
ALLOWED_DEVICE_SERIALS=("34Q8W13" "0" "serial-ID-3" "")

# Interner Monitor
IN="eDP-1"
# Externer Monitor
EXT="DP-2"
USE_MONITOR=''${1:-no-monitor}
POSITION=''${2:-left-of}
MODE=''${3:-extend}

# Funktion, um die Seriennummern der Monitore zu erhalten
get_monitor_serials() {
    hwinfo --monitor | grep "Serial ID:" | awk -F ': ' '{print $2}'
}

# Funktion, um die Polybar zu starten
start_polybar() {
    killall -q polybar
    while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
    polybar bar &
}

# Polybar initial stoppen
killall -q polybar

if [ "$USE_MONITOR" == "monitor" ]; then
    # Überprüfen, ob der externe Monitor angeschlossen ist
    if xrandr --query | grep -q "$EXT connected"; then
        # Alle Seriennummern der angeschlossenen Monitore abrufen
        MONITOR_SERIALS=$(get_monitor_serials)

        # Debugging: Seriennummern ausgeben
        echo "Erkannte Seriennummern der Monitore:"
        echo "$MONITOR_SERIALS"

        # Variable zum Verfolgen, ob alle Monitore erlaubt sind
        ALL_ALLOWED=true

        # Überprüfen, ob jede erkannte Seriennummer in der Liste der erlaubten Seriennummern ist
        for serial in $MONITOR_SERIALS; do
            serial=$(echo "$serial" | xargs)  # Entfernt führende und nachfolgende Leerzeichen
            ALLOWED=false
            for allowed_serial in "''${ALLOWED_DEVICE_SERIALS[@]}"; do
                if [[ "$serial" == "$allowed_serial" ]]; then
                    ALLOWED=true
                    break
                fi
            done

            if [[ "$ALLOWED" == false ]]; then
                echo "Seriennummer $serial ist nicht erlaubt."
                if ! yad --question --text="Möchten Sie den Monitor mit der Seriennummer $serial verwenden?"; then
                    echo "Benutzer hat die Verwendung des Monitors mit der Seriennummer $serial abgelehnt"
                    exit 1
                else
                    echo "Benutzer hat die Verwendung des Monitors mit der Seriennummer $serial akzeptiert"
                    # Wenn der Benutzer die Verwendung akzeptiert, setzen wir ALLOWED auf true
                    ALLOWED=true
                fi
            else
                echo "Seriennummer $serial ist erlaubt."
            fi

            # Wenn der Benutzer die Verwendung eines fremden Monitors akzeptiert hat, brechen wir die Schleife ab
            if [[ "$ALLOWED" == true ]]; then
                break
            fi
        done

        # Externer Monitor ist erlaubt oder Benutzer hat ihn akzeptiert
        if [ "$MODE" == "mirror" ]; then
            # Monitore spiegeln
            xrandr --output $IN --auto --output $EXT --auto --same-as $IN --primary
            # Polybar neu starten
            start_polybar
        else
            # Monitore erweitern und gemäß der angegebenen Position ausrichten
            xrandr --output $IN --auto --output $EXT --auto --$POSITION $IN --primary

            # Alle Arbeitsbereiche auf den externen Monitor verschieben
            for workspace in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
                i3-msg workspace "$workspace"
                i3-msg move workspace to output $EXT
            done

            # i3-Konfiguration neu laden
            i3-msg restart
        fi
    else
        echo "Externer Monitor ist nicht angeschlossen."
        # Polybar neu starten
        start_polybar
    fi
else
    # Externer Monitor soll nicht verwendet werden
    xrandr --output $IN --auto --output $EXT --off

    # Alle Arbeitsbereiche zurück auf den internen Monitor verschieben
    for workspace in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
        i3-msg workspace "$workspace"
        i3-msg move workspace to output $IN
    done

    # i3-Konfiguration neu laden
    i3-msg restart
fi
  '')

(pkgs.writeShellScriptBin "clean-generations" ''
#!/usr/bin/env bash
set -euo pipefail

## Defaults
keepGensDef=30; keepDaysDef=30
keepGens=$keepGensDef; keepDays=$keepDaysDef

## Usage
usage () {
    printf "Usage:\n\t ./trim-generations.sh <keep-gernerations> <keep-days> <profile> \n\n
(defaults are: Keep-Gens=$keepGensDef Keep-Days=$keepDaysDef Profile=user)\n\n"
    printf "If you enter any parameters, you must enter all three, or none to use defaults.\n"
    printf "Example:\n\t trim-generations.sh 15 10 home-manager\n"
    printf "  this will work on the home-manager profile and keep all generations from the\n"
    printf "last 10 days, and keep at least 15 generations no matter how old.\n"
    printf "\nProfiles available are:\tuser, home-manager, channels, system (root)\n"
    printf "\n-h or --help prints this help text."
}

if [ $# -eq 1 ]; then      # if help requested
    if [ $1 = "-h" ]; then
         usage
         exit 1;
    fi
    if [ $1 = "--help" ]; then
         usage
         exit 2;
    fi
    printf "Dont recognise your option exiting..\n\n"
    usage
    exit 3;

    elif [ $# -eq 0 ]; then            # print the defaults
        printf "The current defaults are:\n Keep-Gens=$keepGensDef Keep-Days=$keepDaysDef \n\n"
        read -p "Keep these defaults? (y/n):" answer

        case "$answer" in
        [yY1] )
                printf "Using defaults..\n"
            ;;
        [nN0] ) printf "ok, doing nothing, exiting..\n"
            exit 6;
            ;;
        *     ) printf "%b" "Doing nothing, exiting.."
            exit 7;
            ;;
        esac
fi

## Handle parameters (and change if root)
if [[ $EUID -ne 0 ]]; then              # if not root
    profile=$(readlink /home/$USER/.nix-profile)
else
    if [ -d /nix/var/nix/profiles/system ]; then   # maybe this or the other
        profile="/nix/var/nix/profiles/system"
    elif [ -d /nix/var/nix/profiles/default ]; then
        profile="/nix/var/nix/profiles/default"
    else
        echo "Cant find profile for root. Exiting"
        exit 8
    fi
fi
if (( $# < 1 )); then
    printf "Keeping default: $keepGensDef generations OR $keepDaysDef days, whichever is more\n"
elif [[ $# -le 2 ]]; then
    printf "\nError: Not enough arguments.\n\n" >&2
    usage
    exit 1
elif (( $# > 4)); then
    printf "\nError: Too many arguments.\n\n" >&2
    usage
    exit 2
else
    if [ $1 -lt 1 ]; then
        printf "using Gen numbers less than 1 not recommended. Setting to min=1\n"
        read -p "is that ok? (y/n): " asnwer
        #printf "$asnwer"
        case "$asnwer" in
        [yY1] )
            printf "ok, continuing..\n"
            ;;
        [nN0] )
            printf "ok, doing nothing, exiting..\n"
            exit 6;
            ;;
        *     )
            printf "%b" "Doing nothing, exiting.."
            exit 7;
            ;;
        esac
    fi
    if [ $2 -lt 0 ]; then
        printf "using negative days number not recommended. Setting to min=0\n"
        read -p "is that ok? (y/n): " asnwer

        case "$asnwer" in
        [yY1] )
            printf "ok, continuing..\n"
            ;;
        [nN0] )
            printf "ok, doing nothing, exiting..\n"
            exit 6;
            ;;
        *     )
            printf "%b" "Doing nothing, exiting.."
            exit 7;
            ;;
        esac
    fi
    keepGens=$1; keepDays=$2;
    (( keepGens < 1 )) && keepGens=1
    (( keepDays < 0 )) && keepDays=0
    if [[ $EUID -ne 0 ]]; then
        if [[ $3 == "user" ]] || [[ $3 == "default" ]]; then
            profile=$(readlink /home/$USER/.nix-profile)
        elif [[ $3 == "home-manager" ]]; then
            # home-manager defaults to $XDG_STATE_HOME; otherwise, use
            # `home-manager generations` and `nix-store --query --roots
            # /nix/store/...` to figure out what reference is keeping the old
            # generations alive.
            profile="''${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
        elif [[ $3 == "channels" ]]; then
            profile="/nix/var/nix/profiles/per-user/$USER/channels"
        else
            printf "\nError: Do not understand your third argument. Should be one of: (user / home-manager/ channels)\n\n"
            usage
            exit 3
        fi
    else
        if [[ $3 == "system" ]]; then
            profile="/nix/var/nix/profiles/system"
        elif [[ $3 == "user" ]] || [[ $3 == "default" ]]; then
            profile="/nix/var/nix/profiles/default"
        else
            printf "\nError: Do not understand your third argument. Should be one of: (user / system)\n\n"
            usage
            exit 3
        fi
    fi
    printf "OK! \t Keep Gens = $keepGens \t Keep Days = $keepDays\n\n"
fi

printf "Operating on profile: \t $profile\n\n"

## Runs at the end, to decide whether to delete profiles that match chosen parameters.
choose () {
    local default="$1"
    local prompt="$2"
    local answer

    read -p "$prompt" answer
    [ -z "$answer" ] && answer="$default"

    case "$answer" in
        [yY1] ) #printf "answered yes!\n"
             nix-env --delete-generations -p $profile ''${!gens[@]}
            exit 0
            ;;
        [nN0] ) printf "Ok doing nothing exiting..\n"
            exit 6;
            ;;
        *     ) printf "%b" "Unexpected answer '$answer'!" >&2
            exit 7;
            ;;
    esac
} # end of function choose

# printf "profile = $profile\n\n"
## Query nix-env for generations list
IFS=$'\n' nixGens=( $(nix-env --list-generations -p $profile | sed 's:^\s*::; s:\s*$::' | tr '\t' ' ' | tr -s ' ') )
timeNow=$(date +%s)

## Get info on oldest generation
IFS=' ' read -r -a oldestGenArr <<< "''${nixGens[0]}"
oldestGen=''${oldestGenArr[0]}
oldestDate=''${oldestGenArr[1]}
printf "%-30s %s\n" "oldest generation:" $oldestGen
#oldestDate=''${nixGens[0]:3:19}
printf "%-30s %s\n" "oldest generation created:" $oldestDate
oldestTime=$(date -d "$oldestDate" +%s)
oldestElapsedSecs=$((timeNow-oldestTime))
oldestElapsedMins=$((oldestElapsedSecs/60))
oldestElapsedHours=$((oldestElapsedMins/60))
oldestElapsedDays=$((oldestElapsedHours/24))
printf "%-30s %s\n" "minutes before now:" $oldestElapsedMins
printf "%-30s %s\n" "hours before now:" $oldestElapsedHours
printf "%-30s %s\n\n" "days before now:" $oldestElapsedDays

## Get info on current generation
for i in "''${nixGens[@]}"; do
    IFS=' ' read -r -a iGenArr <<< "$i"
    genNumber=''${iGenArr[0]}
    genDate=''${iGenArr[1]}
    if [[ "$i" =~ current ]]; then
        currentGen=$genNumber
        printf "%-30s %s\n" "current generation:" $currentGen
        currentDate=$genDate
        printf "%-30s %s\n" "current generation created:" $currentDate
        currentTime=$(date -d "$currentDate" +%s)
        currentElapsedSecs=$((timeNow-currentTime))
        currentElapsedMins=$((currentElapsedSecs/60))
        currentElapsedHours=$((currentElapsedMins/60))
        currentElapsedDays=$((currentElapsedHours/24))
        printf "%-30s %s\n" "minutes before now:" $currentElapsedMins
        printf "%-30s %s\n" "hours before now:" $currentElapsedHours
        printf "%-30s %s\n\n" "days before now:" $currentElapsedDays
    fi
done

## Compare oldest and current generations
timeBetweenOldestAndCurrent=$((currentTime-oldestTime))
elapsedDays=$((timeBetweenOldestAndCurrent/60/60/24))
generationsDiff=$((currentGen-oldestGen))

## Figure out what we should do, based on generations and options
if [[ elapsedDays -le keepDays ]]; then
    printf "All generations are no more than $keepDays days older than current generation. \nOldest gen days difference from current gen: $elapsedDays \n\n\tNothing to do!\n"
    exit 4;
elif [[ generationsDiff -lt keepGens ]]; then
    printf "Oldest generation ($oldestGen) is only $generationsDiff generations behind current ($currentGen). \n\n\t Nothing to do!\n"
    exit 5;
else
    printf "\tSomething to do...\n"
    declare -a gens
    for i in "''${nixGens[@]}"; do
        IFS=' ' read -r -a iGenArr <<< "$i"
        genNumber=''${iGenArr[0]}
        genDiff=$((currentGen-genNumber))
        genDate=''${iGenArr[1]}
        genTime=$(date -d "$genDate" +%s)
        elapsedSecs=$((timeNow-genTime))
        genDaysOld=$((elapsedSecs/60/60/24))
        if [[ genDaysOld -gt keepDays ]] && [[ genDiff -ge keepGens ]]; then
            gens["$genNumber"]="$genDate, $genDaysOld day(s) old"
        fi
    done
    printf "\nFound the following generation(s) to delete:\n"
    for K in "''${!gens[@]}"; do
        printf "generation $K \t ''${gens[$K]}\n"
    done
    printf "\n"
    choose "y" "Do you want to delete these? [Y/n]: "
fi
  '')
(pkgs.writeShellScriptBin "setup-hibernation" ''
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
    sudo sed -i "s|resume=UUID=[a-fA-F0-9-]*|resume=UUID=''${root_uuid}|g" "$config_file"
else
    sudo sed -i.bak '/^}$/i\  boot.kernelParams = [ "resume=UUID='"$root_uuid"'" ];' "$config_file"
fi

if grep -q 'resume_offset=[0-9]*' "$config_file"; then
    sudo sed -i "s|resume_offset=[0-9]*|resume_offset=''${offset}|g" "$config_file"
else
    sudo sed -i.bak '/^}$/i\  "resume_offset='"$offset"'" ];' "$config_file"
fi
  '')

(pkgs.writeShellScriptBin "update-system" ''
#!/usr/bin/env bash
# Datum des letzten Ausführens: 15.08.2024

# Pfad zur Batteriekapazität
bat_capacity_path="/sys/class/power_supply/BAT0/capacity"

# Überprüft, ob der Pfad existiert
if [ ! -f "$bat_capacity_path" ]; then
  echo -e "\033[0;31mError: Batteriekapazität konnte nicht gefunden werden.\033[0m"
  exit 1
fi

# Liest die Batteriekapazität aus
bat_capacity=$(cat "$bat_capacity_path")

# Überprüft die Batteriekapazität
if [[ $bat_capacity -le 12 ]]; then
  echo -e "\033[0;31mBattery capacity too low!\033[0m"
  exit 1
fi
# Wenn die Batteriekapazität ausreichend ist, wird nichts ausgegeben und das Skript endet normal.

#---------------------------------------------------------------------------------------

# Schwellenwert für RAM-Nutzung in Prozent
threshold=80

# Aktuelle RAM-Nutzung in Prozent ermitteln
ram_usage=$(free | awk '/^Mem:/ {printf("%.0f"), $3/$2 * 100.0}')

# Überprüfen, ob die RAM-Nutzung den Schwellenwert überschreitet
if [ "$ram_usage" -gt "$threshold" ]; then
  echo -e "\033[0;31mRAM usage too high! Currently using $ram_usage% of RAM.\033[0m"
  exit 1
fi
# Wenn die RAM-Nutzung unter dem Schwellenwert liegt, wird nichts ausgegeben und das Skript endet normal.

#-----------------------------------------------------------------------------------------

# Aktuelles Datum und Uhrzeit anzeigen
echo "Aktuelles Datum und Uhrzeit: $(date +"%d.%m.%Y %H:%M")"

# Pfad zur Datei selbst
DATEI=$(realpath "$0")

# Überprüfe, ob die Datei existiert, um das Datum des letzten Ausführens zu lesen
if [ -f "$DATEI" ]; then
  letztesDatum=$(sed -n '2p' "$DATEI" | grep -oP '\d{2}\.\d{2}\.\d{4}')

  if [ -n "$letztesDatum" ]; then
    formatiertesDatum=$(echo $letztesDatum | awk -F"." '{printf "%04d-%02d-%02d", $3, $2, $1}')
    sekLetztesDatum=$(date -d "$formatiertesDatum" +%s)
    sekHeute=$(date +%s)
    diffTage=$(( (sekHeute - sekLetztesDatum) / 86400 ))
    echo "Das Skript wurde zuletzt vor $diffTage Tagen am $letztesDatum ausgeführt."
  else
    echo "Das Skript wird zum ersten Mal ausgeführt."
  fi
else
  echo "Fehler: Die Datei konnte nicht gefunden werden."
  exit 1
fi

# Neues Datum
newDate=$(date "+%d.%m.%Y")

# Aktualisiere das Datum des letzten Ausführens in der Datei
sed -i "2s/.*/# Datum des letzten Ausführens: $newDate/" "$DATEI"

#------------------------------------------------------------------------------------------

# Bash Historie aufräumen
echo -ne "\e[1;34m>>\e[0m Möchtest du die Bash-Historie reinigen? (Y/n): "
read clean_decision
clean_decision=''${clean_decision:-y}

if [[ $clean_decision =~ ^[Yy]$ ]]; then
  password=$(kdialog --password "Enter the keyword, that should be removed from history")
  if [[ -z "$password" ]] || type "$password" &>/dev/null; then
    echo "The input cannot be empty or a valid command."
  else
    temp_file=$(mktemp)
    removed=$(grep -- "$password" ~/.bash_history)

    if [[ ! "$removed" =~ [^[:space:]] ]]; then
      echo "No line with your keyword!"
    else
      echo "Removed the following lines containing your keyword: "
      echo "$removed"
      echo -ne "\e[1;34m>>\e[0m Do you want to remove these commands from your history? (y/N): "
      read remove_decision
      remove_decision=''${remove_decision:-y}

      if [[ $remove_decision =~ ^[Yy]$ ]]; then
        grep -v -- "$password" ~/.bash_history > "$temp_file"
        mv "$temp_file" ~/.bash_history
        echo "Commands have been removed."
      else
        echo "Commands have not been removed."
      fi
    fi

    [[ -f $temp_file ]] && rm "$temp_file"
  fi

  # Laden der .bashrc, um sicherzustellen, dass Aliase verfügbar sind
  if [ -f ~/.bashrc ]; then
    source ~/.bashrc
  fi

  histfile="$HOME/.bash_history"
  tmpfile_dup=$(mktemp)

  awk '!seen[$0]++' "$histfile" > "$tmpfile_dup"
  mv "$tmpfile_dup" "$histfile"
  echo "Duplicates removed."

  check_command() {
    type "$1" &>/dev/null
  }

  temp_file=$(mktemp)
  removed_commands=$(mktemp)

  commands_before=$(wc -l < "$histfile")

  while IFS= read -r command; do
    if [[ ! $command =~ ^[[:space:]]*$ ]]; then
      cmd=$(echo $command | cut -d ' ' -f1)

      if [[ $cmd == "sudo" ]]; then
        cmd=$(echo $command | cut -d ' ' -f2)
      fi

      if check_command "$cmd"; then
        echo "$command" >> "$temp_file"
      else
        echo "$command" >> "$removed_commands"
      fi
    fi
  done < "$histfile"

  if [[ -s $removed_commands ]]; then
    echo -ne "\e[1;34m>>\e[0m Möchtest du die Befehle sehen, die entfernt werden würden? (y/N): "
    read show_decision
    show_decision=''${show_decision:-n}

    if [[ $show_decision == "y" ]]; then
      echo "Entfernte Befehle:"
      cat "$removed_commands"
    fi

    echo -ne "\e[1;34m>>\e[0m Möchtest du diese Befehle wirklich entfernen? (Y/n): "
    read remove_decision
    remove_decision=''${remove_decision:-y}

    if [[ $remove_decision =~ ^[Yy]$ ]]; then
      mv "$temp_file" "$histfile"
      echo "Befehle wurden entfernt."
    else
      echo "Befehle wurden NICHT entfernt."
      rm "$temp_file"
    fi
  else
    echo "Historie hat keine Befehle mit Syntaxfehlern"
  fi

  commands_after=$(wc -l < "$histfile")

  if [ "$commands_before" -ne "$commands_after" ]; then
    echo "Anzahl der Befehle in der Historie von $commands_before Befehlen auf $commands_after reduziert."
  else
    echo "Es wurden keine Befehle entfernt, die Anzahl der Befehle in der history ist immer noch $commands_before."
  fi

  rm "$removed_commands"
fi

#------------------------------------------------------------------

# Funktion zur Überprüfung der Internetverbindung
check_internet() {
  wget -q --spider http://google.com
  return $?
}

# Den Benutzer fragen, ob das System aktualisiert werden soll
echo -ne "\e[1;34m>>\e[0m Möchtest du das System jetzt aktualisieren? (Y/n): "
read update_answer
update_answer=''${update_answer:-y}

if [[ $update_answer =~ ^[Yy]$ ]]; then
  echo "System wird aktualisiert..."

  if check_internet; then
    echo "Internetverbindung erkannt. Aktualisierung wird gestartet..."

    sudo nix-channel --update 
    sudo nixos-rebuild switch --upgrade  
  else
    echo "Keine Internetverbindung erkannt. Systemaktualisierung übersprungen."
  fi
fi

#------------------------------------------------------------------------------------------------------------------------------------

# Frage, ob System-Generations-Reinigung durchgeführt werden soll
echo -ne "\e[1;34m>>\e[0m Möchtest du die System-Generations-Reinigung durchführen? (Y/n): "
read clean_generations
clean_generations=''${clean_generations:-y}

if [[ $clean_generations =~ ^[Yy]$ ]]; then
  set -euo pipefail

  ## Defaults
  keepGensDef=10; keepDaysDef=30
  keepGens=$keepGensDef; keepDays=$keepDaysDef

  ## Usage
  usage () {
    printf "Usage:\n\t ./trim-generations.sh <keep-gernerations> <keep-days> <profile> \n\n
  (defaults are: Keep-Gens=$keepGensDef Keep-Days=$keepDaysDef Profile=user)\n\n"
    printf "If you enter any parameters, you must enter all three, or none to use defaults.\n"
    printf "Example:\n\t trim-generations.sh 15 10 home-manager\n"
    printf "  this will work on the home-manager profile and keep all generations from the\n"
    printf "last 10 days, and keep at least 15 generations no matter how old.\n"
    printf "\nProfiles available are:\tuser, home-manager, channels, system (root)\n"
    printf "\n-h or --help prints this help text."
  }

  if [ $# -eq 1 ]; then
    if [ $1 = "-h" ]; then
      usage
      exit 1
    fi
    if [ $1 = "--help" ]; then
      usage
      exit 2
    fi
    printf "Dont recognise your option exiting..\n\n"
    usage
    exit 3

  elif [ $# -eq 0 ]; then
    printf "The current defaults are:\n Keep-Gens=$keepGensDef Keep-Days=$keepDaysDef \n\n"
    read -p "Keep these defaults? (y/n):" answer

    case "$answer" in
      [yY1] )
        printf "Using defaults..\n"
        ;;
      [nN0] )
        printf "ok, doing nothing, exiting..\n"
        exit 6
        ;;
      *     )
        printf "%b" "Doing nothing, exiting.."
        exit 7
        ;;
    esac
  fi

  ## Handle parameters (and change if root)
  if [[ $EUID -ne 0 ]]; then
    profile=$(readlink /home/$USER/.nix-profile)
  else
    if [ -d /nix/var/nix/profiles/system ]; then
      profile="/nix/var/nix/profiles/system"
    elif [ -d /nix/var/nix/profiles/default ]; then
      profile="/nix/var/nix/profiles/default"
    else
      echo "Cant find profile for root. Exiting"
      exit 8
    fi
  fi

  if (( $# < 1 )); then
    printf "Keeping default: $keepGensDef generations OR $keepDaysDef days, whichever is more\n"
  elif [[ $# -le 2 ]]; then
    printf "\nError: Not enough arguments.\n\n" >&2
    usage
    exit 1
  elif (( $# > 4)); then
    printf "\nError: Too many arguments.\n\n" >&2
    usage
    exit 2
  else
    if [ $1 -lt 1 ]; then
      printf "using Gen numbers less than 1 not recommended. Setting to min=1\n"
      read -p "is that ok? (y/n): " asnwer
      case "$asnwer" in
        [yY1] )
          printf "ok, continuing..\n"
          ;;
        [nN0] )
          printf "ok, doing nothing, exiting..\n"
          exit 6
          ;;
        *     )
          printf "%b" "Doing nothing, exiting.."
          exit 7
          ;;
      esac
    fi
    if [ $2 -lt 0 ]; then
      printf "using negative days number not recommended. Setting to min=0\n"
      read -p "is that ok? (y/n): " asnwer

      case "$asnwer" in
        [yY1] )
          printf "ok, continuing..\n"
          ;;
        [nN0] )
          printf "ok, doing nothing, exiting..\n"
          exit 6
          ;;
        *     )
          printf "%b" "Doing nothing, exiting.."
          exit 7
          ;;
      esac
    fi

    keepGens=$1; keepDays=$2;
    (( keepGens < 1 )) && keepGens=1
    (( keepDays < 0 )) && keepDays=0

    if [[ $EUID -ne 0 ]]; then
      if [[ $3 == "user" ]] || [[ $3 == "default" ]]; then
        profile=$(readlink /home/$USER/.nix-profile)
      elif [[ $3 == "home-manager" ]]; then
        profile="''${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
      elif [[ $3 == "channels" ]]; then
        profile="/nix/var/nix/profiles/per-user/$USER/channels"
      else
        printf "\nError: Do not understand your third argument. Should be one of: (user / home-manager/ channels)\n\n"
        usage
        exit 3
      fi
    else
      if [[ $3 == "system" ]]; then
        profile="/nix/var/nix/profiles/system"
      elif [[ $3 == "user" ]] || [[ $3 == "default" ]]; then
        profile="/nix/var/nix/profiles/default"
      else
        printf "\nError: Do not understand your third argument. Should be one of: (user / system)\n\n"
        usage
        exit 3
      fi
    fi

    printf "OK! \t Keep Gens = $keepGens \t Keep Days = $keepDays\n\n"
  fi

  printf "Operating on profile: \t $profile\n\n"

  ## Runs at the end, to decide whether to delete profiles that match chosen parameters.
  choose () {
    local default="$1"
    local prompt="$2"
    local answer

    read -p "$prompt" answer
    [ -z "$answer" ] && answer="$default"

    case "$answer" in
      [yY1] )
        nix-env --delete-generations -p $profile ''${!gens[@]}
        exit 0
        ;;
      [nN0] )
        printf "Ok doing nothing exiting..\n"
        exit 6
        ;;
      *     )
        printf "%b" "Unexpected answer '$answer'!" >&2
        exit 7
        ;;
    esac
  }

  ## Query nix-env for generations list
  IFS=$'\n' nixGens=( $(nix-env --list-generations -p $profile | sed 's:^\s*::; s:\s*$::' | tr '\t' ' ' | tr -s ' ') )
  timeNow=$(date +%s)

  ## Get info on oldest generation
  IFS=' ' read -r -a oldestGenArr <<< "''${nixGens[0]}"
  oldestGen=''${oldestGenArr[0]}
  oldestDate=''${oldestGenArr[1]}
  printf "%-30s %s\n" "oldest generation:" $oldestGen
  printf "%-30s %s\n" "oldest generation created:" $oldestDate
  oldestTime=$(date -d "$oldestDate" +%s)
  oldestElapsedSecs=$((timeNow-oldestTime))
  oldestElapsedMins=$((oldestElapsedSecs/60))
  oldestElapsedHours=$((oldestElapsedMins/60))
  oldestElapsedDays=$((oldestElapsedHours/24))
  printf "%-30s %s\n" "minutes before now:" $oldestElapsedMins
  printf "%-30s %s\n" "hours before now:" $oldestElapsedHours
  printf "%-30s %s\n" "days before now:" $oldestElapsedDays

  ## Get info on current generation
  for i in "''${nixGens[@]}"; do
    IFS=' ' read -r -a iGenArr <<< "$i"
    genNumber=''${iGenArr[0]}
    genDate=''${iGenArr[1]}

    if [[ "$i" =~ current ]]; then
      currentGen=$genNumber
      printf "%-30s %s\n" "current generation:" $currentGen
      currentDate=$genDate
      printf "%-30s %s\n" "current generation created:" $currentDate
      currentTime=$(date -d "$currentDate" +%s)
      currentElapsedSecs=$((timeNow-currentTime))
      currentElapsedMins=$((currentElapsedSecs/60))
      currentElapsedHours=$((currentElapsedMins/60))
      currentElapsedDays=$((currentElapsedHours/24))
      printf "%-30s %s\n" "minutes before now:" $currentElapsedMins
      printf "%-30s %s\n" "hours before now:" $currentElapsedHours
      printf "%-30s %s\n" "days before now:" $currentElapsedDays
    fi
  done

  ## Compare oldest and current generations
  timeBetweenOldestAndCurrent=$((currentTime-oldestTime))
  elapsedDays=$((timeBetweenOldestAndCurrent/60/60/24))
  generationsDiff=$((currentGen-oldestGen))

  ## Figure out what we should do, based on generations and options
  if [[ elapsedDays -le keepDays ]]; then
    printf "All generations are no more than $keepDays days older than current generation. \nOldest gen days difference from current gen: $elapsedDays \n\n\tNothing to do!\n"
    exit 4
  elif [[ generationsDiff -lt keepGens ]]; then
    printf "Oldest generation ($oldestGen) is only $generationsDiff generations behind current ($currentGen). \n\n\t Nothing to do!\n"
    exit 5
  else
    printf "\tSomething to do...\n"
    declare -a gens

    for i in "''${nixGens[@]}"; do
      IFS=' ' read -r -a iGenArr <<< "$i"
      genNumber=''${iGenArr[0]}
      genDiff=$((currentGen-genNumber))
      genDate=''${iGenArr[1]}
      genTime=$(date -d "$genDate" +%s)
      elapsedSecs=$((timeNow-genTime))
      genDaysOld=$((elapsedSecs/60/60/24))

      if [[ genDaysOld -gt keepDays ]] && [[ genDiff -ge keepGens ]]; then
        gens["$genNumber"]="$genDate, $genDaysOld day(s) old"
      fi
    done

    printf "\nFound the following generation(s) to delete:\n"
    for K in "''${!gens[@]}"; do
      printf "generation $K \t ''${gens[$K]}\n"
    done
    printf "\n"
    choose "y" "Do you want to delete these? [Y/n]: "
  fi

  echo "Systemaktualisierung abgeschlossen."
fi

#--------------------------------------------------------------------------------


# URL des Git-Repositories festlegen
repo_url="git@github.com:tombo0909/data.git" 

echo -ne "\e[1;34m>>\e[0m Möchtest du das Repository aktualisieren? (Y/n): "
read antwort
antwort=''${antwort:-y}

if [[ $antwort == "y" || $antwort == "Y" ]]; then
  temp_dir=$(mktemp -d 2>/dev/null)

  echo "Bitte stecken Sie Ihren YubiKey ein."
  while [ $(lsusb | grep -c 'Yubico') -eq 0 ]; do
    echo -ne "Warten auf YubiKey...\r"
    sleep 0.7
    echo -ne "                     \r"
    sleep 0.7
  done
  echo "YubiKey erkannt."


  # Ins lokale Repository wechseln
  cd /home/tom/data

  # Dateien ins lokale Repository kopieren
  cp -r /home/tom/.mozilla/firefox/*.default/sessionstore-backups/* /home/tom/data/firefox/

  # Änderungen committen und pushen
  git add .
  git commit -m "Update data"
  git push
  echo "Data wurde erfolgreich aktualisiert und gepusht."

  cd /home/tom/
else
  echo "Aktualisierung wurde abgebrochen."
fi

exit
  '')
(pkgs.writeShellScriptBin "rechteck.py" ''
#!/usr/bin/env python
import sys
from PyQt5 import QtWidgets, QtCore, QtGui

class ResizableRectangle(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        self.setGeometry(300, 300, 200, 100)
        self.setAttribute(QtCore.Qt.WA_TranslucentBackground)
        self.setWindowFlags(QtCore.Qt.FramelessWindowHint | QtCore.Qt.WindowStaysOnTopHint | QtCore.Qt.X11BypassWindowManagerHint)

        self.dragging = False
        self.resizing = False
        self.margin = 7  # Ändern um minimale Groesse des Rechtecks und Empfindlichkeit an den Ecken/Kanten zu veraendern 
        self.resize_direction = None

    def mousePressEvent(self, event):
        if event.button() == QtCore.Qt.LeftButton:
            self.detect_resize_direction(event)
            if self.resize_direction:
                self.resizing = True
                self.resize_start_pos = event.globalPos()
                self.resize_start_geometry = self.geometry()
            else:
                self.dragging = True
                self.drag_start_pos = event.globalPos() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if self.dragging:
            self.move(event.globalPos() - self.drag_start_pos)
            event.accept()
        elif self.resizing:
            self.perform_resize(event)
            event.accept()
        else:
            self.update_cursor_shape(event)

    def mouseReleaseEvent(self, event):
        self.dragging = False
        self.resizing = False
        self.resize_direction = None
        event.accept()

    def detect_resize_direction(self, event):
        rect = self.rect()
        x, y, w, h = rect.x(), rect.y(), rect.width(), rect.height()
        mx, my = event.x(), event.y()

        if mx <= self.margin and my <= self.margin:
            self.resize_direction = 'top_left'
        elif mx >= w - self.margin and my <= self.margin:
            self.resize_direction = 'top_right'
        elif mx <= self.margin and my >= h - self.margin:
            self.resize_direction = 'bottom_left'
        elif mx >= w - self.margin and my >= h - self.margin:
            self.resize_direction = 'bottom_right'
        elif mx <= self.margin:
            self.resize_direction = 'left'
        elif mx >= w - self.margin:
            self.resize_direction = 'right'
        elif my <= self.margin:
            self.resize_direction = 'top'
        elif my >= h - self.margin:
            self.resize_direction = 'bottom'
        else:
            self.resize_direction = None

    def perform_resize(self, event):
        if not self.resize_direction:
            return

        delta = event.globalPos() - self.resize_start_pos
        geom = self.resize_start_geometry

        if self.resize_direction == 'top_left':
            new_geom = QtCore.QRect(geom.left() + delta.x(), geom.top() + delta.y(), geom.width() - delta.x(), geom.height() - delta.y())
        elif self.resize_direction == 'top_right':
            new_geom = QtCore.QRect(geom.left(), geom.top() + delta.y(), geom.width() + delta.x(), geom.height() - delta.y())
        elif self.resize_direction == 'bottom_left':
            new_geom = QtCore.QRect(geom.left() + delta.x(), geom.top(), geom.width() - delta.x(), geom.height() + delta.y())
        elif self.resize_direction == 'bottom_right':
            new_geom = QtCore.QRect(geom.left(), geom.top(), geom.width() + delta.x(), geom.height() + delta.y())
        elif self.resize_direction == 'left':
            new_geom = QtCore.QRect(geom.left() + delta.x(), geom.top(), geom.width() - delta.x(), geom.height())
        elif self.resize_direction == 'right':
            new_geom = QtCore.QRect(geom.left(), geom.top(), geom.width() + delta.x(), geom.height())
        elif self.resize_direction == 'top':
            new_geom = QtCore.QRect(geom.left(), geom.top() + delta.y(), geom.width(), geom.height() - delta.y())
        elif self.resize_direction == 'bottom':
            new_geom = QtCore.QRect(geom.left(), geom.top(), geom.width(), geom.height() + delta.y())

        if new_geom.width() >= self.margin * 2 and new_geom.height() >= self.margin * 2:
            self.setGeometry(new_geom)

    def update_cursor_shape(self, event):
        rect = self.rect()
        x, y, w, h = rect.x(), rect.y(), rect.width(), rect.height()
        mx, my = event.x(), event.y()

        if mx <= self.margin and my <= self.margin:
            self.setCursor(QtCore.Qt.SizeFDiagCursor)
        elif mx >= w - self.margin and my <= self.margin:
            self.setCursor(QtCore.Qt.SizeBDiagCursor)
        elif mx <= self.margin and my >= h - self.margin:
            self.setCursor(QtCore.Qt.SizeBDiagCursor)
        elif mx >= w - self.margin and my >= h - self.margin:
            self.setCursor(QtCore.Qt.SizeFDiagCursor)
        elif mx <= self.margin:
            self.setCursor(QtCore.Qt.SizeHorCursor)
        elif mx >= w - self.margin:
            self.setCursor(QtCore.Qt.SizeHorCursor)
        elif my <= self.margin:
            self.setCursor(QtCore.Qt.SizeVerCursor)
        elif my >= h - self.margin:
            self.setCursor(QtCore.Qt.SizeVerCursor)
        else:
            self.setCursor(QtCore.Qt.ArrowCursor)

    def paintEvent(self, event):
        painter = QtGui.QPainter(self)
        painter.setBrush(QtGui.QBrush(QtGui.QColor(0, 0, 0)))
        painter.drawRect(self.rect())

class RectangleApp(QtWidgets.QApplication):
    def __init__(self, argv):
        super().__init__(argv)
        self.rectangles = []

    def add_rectangle(self):
        rect = ResizableRectangle()
        rect.show()
        self.rectangles.append(rect)

def main():
    app = RectangleApp(sys.argv)
    app.add_rectangle()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
'')
];
}




