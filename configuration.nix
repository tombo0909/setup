
{ config, lib, pkgs, ... }:




  {
 imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
# "${agenixSrc}/modules/age.nix"
     ];
/*  age.identityPaths = [
    "/home/tom/.ssh/id_ed25519_nixos"  # Dein gerade erstellter ed25519-Key
    # optional weitere, z.B. root:
    # "/root/.ssh/id_ed25519"
  ];
  age.secrets."stripe-api-key" = {
    file  = /etc/nixos/secrets/stripe-api-key.age;
    owner = "tom";
    group = "root";
    mode  = "600";
  };
*/


  boot.loader.grub.configurationLimit = 7;           # für GRUB
  boot.loader.systemd-boot.configurationLimit = 7;   # für systemd-boot

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.device = "/dev/sda";
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  #  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.firewall.allowedUDPPorts = [ 1194 ]; # OpenVPN Standardport
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  networking.enableIPv6 = false;
  boot.kernelParams = [ "ipv6.disable=1" ];  # zusätzlich, greift nach Reboot


  #docker aktivieren
  virtualisation.docker.enable = true;

  services.fwupd.enable = true;


  
   
#  nix.gc = {
#    automatic = true;
#    dates = "hourly";
#    options = "--delete-older-than 60d";
#  };



  services.redshift.enable = true;
  location = {
    provider = "manual";
    latitude = 52.52;   # z.B. Berlin
    longitude = 13.405;
  };
  services.redshift.temperature = { day = 5500; night = 3700; };






  systemd.user.services.idle-notify = {
    description = "Notify after 10s X11 idle";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${idleNotify}/bin/idle-notify";
      Restart = "always";
      RestartSec = 1;
    };

    wantedBy = [ "graphical-session.target" ];
  };



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
${pkgs.coreutils}/bin/mkdir -p /home/tom/Pictures/screenshots

if [ ! -d "/home/tom/setup" ]; then
    ${pkgs.git}/bin/git clone https://github.com/tombo09/setup.git /home/tom/setup
fi

if [ ! -d "/home/tom/setup" ]; then
  ${pkgs.coreutils}/bin/cp -r /setup /home/tom/
fi

if [ ! -L "/home/tom/.config/background.jpg" ]; then
  ${pkgs.coreutils}/bin/ln -s /home/tom/setup/background.jpg /home/tom/.config/background.jpg
fi

${pkgs.coreutils}/bin/chown -R tom:users /home/tom
${pkgs.coreutils}/bin/chown root:root /home/tom/setup/configuration.nix
${pkgs.coreutils}/bin/chmod 644 /home/tom/setup/configuration.nix

      '';
    deps = [];
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;



  services.xserver = {

  xkb.layout = "myus";    # dein Name aus extraLayouts
  xkb.variant = "";       # leer lassen, wenn du "basic" willst
    # Custom-Layout einbinden
    xkb.extraLayouts.myus = {
      description = "US + AltGr: ä ö ü ß € ¢";
      languages = [ "eng" "deu" ];
      symbolsFile = pkgs.writeText "myus" ''
        // Basis: US, Ebene 3 via Right Alt (AltGr)
        xkb_symbols "basic" {
          include "us(basic)"
          include "level3(ralt_switch)"

          // e/E -> AltGr: €
          key <AD03> { [ e, E, EuroSign, EuroSign ] };
          // c/C -> AltGr: ¢
          key <AB03> { [ c, C, cent, cent ] };

          // a/A -> AltGr: ä/Ä
          key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
          // o/O -> AltGr: ö/Ö
          key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
          // u/U -> AltGr: ü/Ü
          key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
          // s/S -> AltGr: ß/ẞ
          key <AC02> { [ s, S, ssharp, U1E9E ] };
        };
      '';
    };


  };





  services.xserver.displayManager.sessionCommands = ''

   # DPMS and Screensaver settings
     xset +dpms
     xset dpms 0 0 600
     xset s 0 0
     xset r rate 280 45
    '';



#  systemd.user.services.setxkbmap = {
#    description = "Set X Keyboard Map";
#    serviceConfig = {
#      ExecStart = "${pkgs.xorg.setxkbmap}/bin/setxkbmap us";
#    };
#    wantedBy = [ "default.target" ];
#  };

  # Configure keymap in X11
#  services.xserver.xkb.layout = "us";
#  services.xserver.xkb.options = "eurosign:e,caps:escape";





  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
  # OR
   services.pipewire = {
    enable = false;
  #   pulse.enable = true;
   };
 

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


# before: IdleAction=suspend-then-hibernate
#         IdleActionSec=5s
services.logind = {
  lidSwitch = "suspend-then-hibernate";
  lidSwitchDocked = "suspend-then-hibernate";
  lidSwitchExternalPower = "suspend-then-hibernate";
  powerKey = "suspend-then-hibernate";
  powerKeyLongPress = "hibernate";

  extraConfig = ''
    IdleAction=suspend-then-hibernate
    IdleActionSec=30min
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






#security.pam = {
#  services.login = {
# };
#  };





 #Fingerprint
  services.fprintd.enable = true;

  security.pam.services = {
    lightdm.fprintAuth = true;
    sudo.fprintAuth = true;
    i3lock.fprintAuth = true;
  };

  # Fingerprint
  # LightDM: fprintd VOR unix, aber kurzer Timeout und nur 1 Versuch
  security.pam.services.lightdm.rules.auth.fprintd = {
    # kleiner als unix.order ⇒ läuft davor
    order = config.security.pam.services.lightdm.rules.auth.unix.order - 50;
    settings = {
      timeout = 2;        # Sekunden, Default 30
      "max-tries" = 1;     # Schlüssel mit Bindestrich muss in Anführungszeichen
    };
  };

 #Fingerprint
  # i3lock gleich behandeln (optional)
  security.pam.services.i3lock.rules.auth.fprintd = {
    order = config.security.pam.services.i3lock.rules.auth.unix.order - 50;
    settings = { timeout = 2; "max-tries" = 1; };
  };


#Fingerprint
powerManagement.resumeCommands = ''
  for d in /sys/bus/usb/devices/*; do
    [ -f "$d/idVendor" ] && [ -f "$d/idProduct" ] || continue
    if [ "$(cat "$d/idVendor")" = "06cb" ] && [ "$(cat "$d/idProduct")" = "00f9" ]; then
      echo on > "$d/power/control" 2>/dev/null || true
      b=$(basename "$d")
      echo "$b" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null || true
      echo "$b" > /sys/bus/usb/drivers/usb/bind   2>/dev/null || true
    fi
  done
  systemctl restart fprintd.service
'';


 
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
   mutableUsers = false;
   users.tom = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enables ‘sudo’ for the user.
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
       jetbrains.idea-ultimate
       gnupg
       spotify
       anki
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
        kdePackages.kdialog
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



monitorHook = pkgs.writeShellApplication {
  name = "monitorHook";
  runtimeInputs = with pkgs; [ coreutils systemd ];
  text = ''
    set -eu

    uid=$(id -u tom)
    export DISPLAY=:0
    export XAUTHORITY=/home/tom/.Xauthority
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus
    export XDG_RUNTIME_DIR=/run/user/$uid
    export PATH="/etc/profiles/per-user/tom/bin:/run/current-system/sw/bin:$PATH"

    st=/sys/class/drm/card1-DP-2/status
    [ -r "$st" ] || exit 0

    status=$(cat "$st")
    [ "$status" = "disconnected" ] || exit 0

    # Optional: Debounce/Lock gegen Mehrfach-Trigger
    lock="$XDG_RUNTIME_DIR/monitorHook.dp2.disconnected.lock"
    if ! ( set -o noclobber; : > "$lock" ) 2>/dev/null; then
      exit 0
    fi
    trap 'rm -f "$lock"' EXIT

    systemd-run --user --quiet --collect \
      -E DISPLAY="$DISPLAY" \
      -E XAUTHORITY="$XAUTHORITY" \
      -E DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
      -E PATH="$PATH" \
      setup-monitor.sh no-monitor
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
  

  programs.kitty = {
    enable = true;
        extraConfig = ''
      # Setzen Sie Ihre zusätzlichen Kitty-Konfigurationen hier
      enable_audio_bell no
      font_size 12
      background #000000
   '';
   };

  









  services.polybar = {
enable = true;
    package = pkgs.polybar.override {
      pulseSupport = true;  # Enable PulseAudio support
    };

script = ''
#!/usr/bin/env bash
# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
#echo "---" | tee -a /tmp/polybar.log /tmp/polybar.log
#polybar bar 2>&1 | tee -a /tmp/polybar.log & disown

#echo "Bars launched..."

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload bar &
  done
else
  polybar --reload bar &
fi

'';

extraConfig = ''
;==========================================================
;
;
;   ██████╗  ██████╗ ██╗  ██╗   ██╗██████╗  █████╗ ██████╗
;   ██╔══██╗██╔═══██╗██║  ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗
;   ██████╔╝██║   ██║██║   ╚████╔╝ ██████╔╝███████║██████╔╝
;   ██╔═══╝ ██║   ██║██║    ╚██╔╝  ██╔══██╗██╔══██║██╔══██╗
;   ██║     ╚██████╔╝███████╗██║   ██████╔╝██║  ██║██║  ██║
;   ╚═╝      ╚═════╝ ╚══════╝╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
;
;
;   To learn more about how to configure Polybar
;   go to https://github.com/polybar/polybar
;
;   The README contains a lot of information
;
;==========================================================

[colors]
background = #000000
background-alt = #373B41
foreground = #C5C8C6
#;foregroud = #ffffff
primary = #ffffff
secondary = #8ABEB7
alert = #A54242
disabled = #707880

[bar/bar]
width = 100%
height = 24pt
radius = 6
monitor = ''${env:MONITOR:}

; dpi = 96

background = ''${colors.background}
foreground = ''${colors.foreground}

line-size = 3pt

border-size = 0pt
border-color = #00000000

padding-left = 0
padding-right = 1

module-margin = 1

separator = |
separator-foreground = ''${colors.disabled}

font-0 = monospace;2
font-1 = "Font Awesome 5 Brands:style=Regular:pixelsize=14;1"
font-2 = "Font Awesome 6 Free:style=Regular:pixelsize=14;1"
font-3 = "Font Awesome 6 Free Solid:style=Solid:pixelsize=14;1"
font-4 = "Font Awesome 6 Brands:style=Regular:pixelsize=14;1"


modules-left = xworkspaces menu-apps
modules-center = date
modules-right = pulseaudio memory battery
cursor-click = pointer
cursor-scroll = ns-resize

enable-ipc = true

; wm-restack = generic
; wm-restack = bspwm
; wm-restack = i3

; override-redirect = true



format-margin = 8pt
tray-spacing = 16pt

[module/xworkspaces]
type = internal/xworkspaces

pin-workspaces = true

label-active = %name%
label-active-background = ''${colors.background-alt}
label-active-underline= ''${colors.primary}
label-active-padding = 1

label-active-foreground = ''${colors.primary}

label-occupied = %name%
label-occupied-padding = 1

label-occupied-foreground = ''${colors.primary}

label-urgent = %name%
label-urgent-background = ''${colors.alert}
label-urgent-padding = 1

label-empty = %name%
label-empty-foreground = ''${colors.disabled}
label-empty-padding = 1



label-mounted = %{F#F0C674}%mountpoint%%{F-} %percentage_used%%

label-unmounted = %mountpoint% not mounted
label-unmounted-foreground = ''${colors.disabled}

[module/pulseaudio]
type = internal/pulseaudio

;format-volume-prefix = "VOL "
format-volume-prefix-foreground = ''${colors.primary}
;format-volume = <label-volume>
format-volume-foreground = ''${colors.primary}

label-volume = %percentage%%

;label-muted = muted
label-muted =  muted
;label-muted-foreground = ''${colors.disabled}

; Available tags:
;   <label-volume> (default)
;   <ramp-volume>
;   <bar-volume>
format-volume = <ramp-volume> <label-volume>

; Available tags:
;   <label-muted> (default)
;   <ramp-volume>
;   <bar-volume>
;format-muted = <label-muted>

; Available tokens:
;   %percentage% (default)
;   %decibels%
;label-volume = %percentage%%

; Available tokens:
;   %percentage% (default)
;   %decibels%
;label-muted = 🔇 muted
label-muted-foreground = #666

; Only applies if <ramp-volume> is used
ramp-volume-0 = 
ramp-volume-1 = 
ramp-volume-2 = 

; Right and Middle click
click-right = pavucontrol
; click-middle = 

[module/xkeyboard]
type = internal/xkeyboard
blacklist-0 = num lock

label-layout = %layout%
label-layout-foreground = ''${colors.primary}

label-indicator-padding = 2
label-indicator-margin = 1
label-indicator-foreground = ''${colors.background}
label-indicator-background = ''${colors.secondary}

[module/memory]
type = internal/memory
interval = 2
format-prefix = "RAM "
format-prefix-foreground = ''${colors.primary}
label = %percentage_used:2%%
label-foreground = ''${colors.primary} 

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "CPU "
format-prefix-foreground = ''${colors.primary}
label = %percentage:2%%

[network-base]
type = internal/network
interval = 5
format-connected = <label-connected>
format-disconnected = <label-disconnected>
label-disconnected = %{F#F0C674}%ifname%%{F#707880} disconnected


[module/wlan]
inherit = network-base
interface-type = wireless
label-connected =  %essid%
#;label-connected = %{F#F0C674}%ifname%%{F-} %essid% %local_ip%
label-connected-foreground = ''${colors.primary}


[module/eth]
inherit = network-base
interface-type = wired
label-connected = %{F#F0C674}%ifname%%{F-} %local_ip%

[module/date]
type = internal/date
interval = 1

date = %d.%m %H:%M
date-alt = %A %d.%m.20%y %H:%M:%S

label = %date%
label-foreground = ''${colors.primary}

[settings]
screenchange-reload = true
pseudo-transparency = true



[module/battery]
type = internal/battery

; This is useful in case the battery never reports 100% charge
; Default: 100
full-at = 100

; format-low once this charge percentage is reached
; Default: 10
; New in version 3.6.0
low-at = 5

; Use the following command to list batteries and adapters:
; $ ls -1 /sys/class/power_supply/
battery = BAT0
adapter = ADP1

; If an inotify event haven't been reported in this many
; seconds, manually poll for new values.
;
; Needed as a fallback for systems that don't report events
; on sysfs/procfs.
;
; Disable polling by setting the interval to 0.
;
; Default: 5
poll-interval = 1

; see "man date" for details on how to format the time string
; NOTE: if you want to use syntax tags here you need to use %%{...}
; Default: %H:%M:%S
time-format = %H:%M

; Available tags:
;   <label-charging> (default)
;   <bar-capacity>
;   <ramp-capacity>
;   <animation-charging>
format-charging = <animation-charging> <label-charging>
;format-charging = <label-charging>

; Available tags:
;   <label-discharging> (default)
;   <bar-capacity>
;   <ramp-capacity>
;   <animation-discharging>
format-discharging = <ramp-capacity> <label-discharging>

; Available tags:
;   <label-full> (default)
;   <bar-capacity>
;   <ramp-capacity>
format-full = <ramp-capacity> <label-full>

; Format used when battery level drops to low-at
; If not defined, format-discharging is used instead.
; Available tags:
;   <label-low>
;   <animation-low>
;   <bar-capacity>
;   <ramp-capacity>
; New in version 3.6.0
format-low = <animation-low> <label-low>
;format-low = <animation-low>

; Available tokens:
;   %percentage% (default) - is set to 100 if full-at is reached
;   %percentage_raw%
;   %time%
;   %consumption% (shows current charge rate in watts)
;label-charging = Charging %percentage%%
;label-charging =  %percentage%%
label-charging = %percentage%%
label-charging-foreground = ''${colors.primary}

; Available tokens:
;   %percentage% (default) - is set to 100 if full-at is reached
;   %percentage_raw%
;   %time%
;   %consumption% (shows current discharge rate in watts)
;label-discharging = Discharging %percentage%%
label-discharging = %percentage%%
label-discharging-foreground = ''${colors.primary}

; Available tokens:
;   %percentage% (default) - is set to 100 if full-at is reached
;   %percentage_raw%
label-full = %percentage_raw%%
label-full-foreground = ''${colors.primary}

; Available tokens:
;   %percentage% (default) - is set to 100 if full-at is reached
;   %percentage_raw%
;   %time%
;   %consumption% (shows current discharge rate in watts)
; New in version 3.6.0
;label-low = BATTERY LOW
label-low = %percentage%%

; Only applies if <ramp-capacity> is used
ramp-capacity-0 = 
ramp-capacity-1 = 
ramp-capacity-2 = 
ramp-capacity-3 = 
ramp-capacity-4 = 

; Only applies if <bar-capacity> is used
bar-capacity-width = 10

; Only applies if <animation-charging> is used
animation-charging-0 = 
animation-charging-1 = 
animation-charging-2 = 
animation-charging-3 = 

; Framerate in milliseconds
animation-charging-framerate = 750

; Only applies if <animation-discharging> is used
animation-discharging-0 = 
animation-discharging-1 = 
animation-discharging-2 = 
animation-discharging-3 = 
animation-discharging-4 = 
; Framerate in milliseconds
animation-discharging-framerate = 500

; Only applies if <animation-low> is used
; New in version 3.6.0
animation-low-0 = ! 
animation-low-1 = 
animation-low-framerate = 1000


[module/menu-apps]
type = custom/menu
expand-right = true

label-open = 
label-close = X
label-separator = |
format-spacing = 1





menu-1-0 = 
menu-1-0-exec = kitty
menu-1-1 = 
menu-1-1-exec = spotify &
menu-1-2 = 
menu-1-2-exec = firefox &
menu-1-3 = Obsidian
menu-1-3-exec = obsidian &
menu-1-4 = Yubikey-Auth
menu-1-4-exec = yubioath-flutter &
menu-1-5 = keepassxc
menu-1-5-exec = keepassxc &
menu-1-6 = Anki
menu-1-6-exec = anki-bin &
menu-1-7 = Vscode
menu-1-7-exec = code &
menu-1-8 = Intellij
menu-1-8-exec = idea-ultimate &
menu-1-9 = VirtualBox
menu-1-9-exec = VirtualBox &



menu-4-0 = settings
menu-4-0-exec = arandr &
menu-4-1 = monitor (l) ext
menu-4-1-exec = setup-monitor.sh monitor left-of extend &
menu-4-2 = monitor (l) mir
menu-4-2-exec = setup-monitor.sh monitor left-of mirror &
menu-4-3 = monitor (r) ext
menu-4-3-exec = setup-monitor.sh monitor right-of extend &
menu-4-4 = monitor (r) mir
menu-4-4-exec = setup-monitor.sh monitor right-of mirror &
menu-4-5 = no monitor
menu-4-5-exec = setup-monitor.sh no-monitor &


menu-8-0 = Rechteck hinzufügen
menu-8-0-exec = create-rectangle
menu-8-1 = Mode beenden
menu-8-1-exec = pkill -f rectangle.py


[module/network]
type = internal/network
; Name of the network interface to display. You can get the names of the
; interfaces on your machine with `ip link`
; Wireless interfaces often start with `wl` and ethernet interface with `eno` or `eth`
interface =  

; If no interface is specified, polybar can detect an interface of the given type.
; If multiple are found, it will prefer running interfaces and otherwise just
; use the first one found.
; Either 'wired' or 'wireless'
; New in version 3.6.0
interface-type = wireless

; Seconds to sleep between updates
; Default: 1
interval = 3.0

; NOTE: Experimental (might change or be removed in the future)
; Test connectivity every Nth update by pinging 8.8.8.8
; In case the ping fails 'format-packetloss' is used until the next ping
; A value of 0 disables the feature
; Default: 0
;ping-interval = 3

; @deprecated: Define min width using token specifiers (%downspeed:min% and %upspeed:min%)
; Minimum output width of upload/download rate
; Default: 3
udspeed-minwidth = 5

; Accumulate values from all interfaces
; when querying for up/downspeed rate
; Default: false
accumulate-stats = true

; Consider an `UNKNOWN` interface state as up.
; Some devices like USB network adapters have 
; an unknown state, even when they're running
; Default: false
unknown-as-up = true

; The unit used for displaying network speeds
; For example if set to the empty string, a speed of 5 KB/s is displayed as 5 K
; Default: B/s
; New in version 3.6.0
speed-unit = ' '

; Available tags:
;   <label-connected> (default)
;   <ramp-signal>
;format-connected = <ramp-signal> <label-connected>
format-connected = <label-connected>

; Available tags:
;   <label-disconnected> (default)
format-disconnected = <label-disconnected>

; Used when connected, but ping fails (see ping-interval)
; Available tags:
;   <label-connected> (default)
;   <label-packetloss>
;   <animation-packetloss>
format-packetloss = <animation-packetloss> <label-connected>

; All labels support the following tokens:
;   %ifname%    [wireless+wired]
;   %local_ip%  [wireless+wired]
;   %local_ip6% [wireless+wired]
;   %essid%     [wireless]
;   %signal%    [wireless]
;   %upspeed%   [wireless+wired]
;   %downspeed% [wireless+wired]
;   %netspeed%  [wireless+wired] (%upspeed% + %downspeed%) (New in version 3.6.0)
;   %linkspeed% [wired]
;   %mac%       [wireless+wired] (New in version 3.6.0)

; Default: %ifname% %local_ip%
;label-connected = %essid% %signal%%
label-connected = %essid%
label-connected-foreground = ''${colors.primary}

; Default: (none)
label-disconnected = not connected
label-disconnected-foreground = ''${colors.primary}

; Default: (none)
;label-packetloss = %essid%
;label-packetloss-foreground = #eefafafa

; Only applies if <ramp-signal> is used
ramp-signal-0 = "|"
ramp-signal-1 = "||"
ramp-signal-2 = "|||"
ramp-signal-3 = "||||"
ramp-signal-4 = "|||||"
ramp-signal-5 = "||||||"

; Only applies if <animation-packetloss> is used
animation-packetloss-0 = ⚠
animation-packetloss-0-foreground = #ffa64c
animation-packetloss-1 = 📶
animation-packetloss-1-foreground = #000000
; Framerate in milliseconds
animation-packetloss-framerate = 500

[module/backlight]
type = internal/backlight

; Use the following command to list available cards:
; $ ls -1 /sys/class/backlight/
; Default: first usable card in /sys/class/backlight (new in version 3.7.0)
card = intel_backlight

; Use the `/sys/class/backlight/.../actual-brightness` file
; rather than the regular `brightness` file.
; New in version 3.6.0
; Changed in version: 3.7.0: Defaults to true also on amdgpu backlights
; Default: true
use-actual-brightness = true

; Interval in seconds after which after which the current brightness is read
; (even if no update is detected).
; Use this as a fallback if brightness updates are not registering in polybar
; (which happens if the use-actual-brightness is false).
; There is no guarantee on the precisio of this timing.
; Set to 0 to turn off
; New in version 3.7.0
; Default: 0 (5 if use-actual-brightness is false)
poll-interval = 0

; Enable changing the backlight with the scroll wheel
; NOTE: This may require additional configuration on some systems. Polybar will
; write to `/sys/class/backlight/''${self.card}/brightness` which requires polybar
; to have write access to that file.
; DO NOT RUN POLYBAR AS ROOT. 
; The recommended way is to add the user to the
; `video` group and give that group write-privileges for the `brightness` file.
; See the ArchWiki for more information:
; https://wiki.archlinux.org/index.php/Backlight#ACPI
; Default: false
enable-scroll = true

; Interval for changing the brightness (in percentage points).
; New in version 3.7.0
; Default: 5
scroll-interval = 10

; Available tags:
;   <label> (default)
;   <ramp>
;   <bar>
format = <label>

; Available tokens:
;   %percentage% (default)
label =  %percentage%%

; Only applies if <ramp> is used
ramp-0 = 🌕
ramp-1 = 🌔
ramp-2 = 🌓
ramp-3 = 🌒
ramp-4 = 🌑

; Only applies if <bar> is used
bar-width = 10
bar-indicator = |
bar-fill = ─
bar-empty = ─

; vim:ft=dosini


'';
};


  xsession.windowManager.i3 = {
    enable = true;
    config = {
floating = {
border = 2;
modifier = "Mod4";
};
bars = [];
modes = {};
keybindings = {};
focus = {
mouseWarping = true;
wrapping = "yes";
followMouse = true;
newWindow = "smart";
};
window = {
border = 2;
hideEdgeBorders = "none";
commands = [];
};
colors = {
focused = {
  border = "#000000";            # Rahmenfarbe
  background = "#707880";        # Hintergrundfarbe
  text = "#000000";              # Textfarbe
  indicator = "#1c1c1c";         # Indikatorfarbe
  childBorder = "#707880";       # Farbe des Kinderrahmens
};

unfocused = {
  border = "#000000";            # Rahmenfarbe
  background = "#1c1c1c";        # Hintergrundfarbe
  text = "#000000";              # Textfarbe
  indicator = "#000000";         # Indikatorfarbe
  childBorder = "#1c1c1c";       # Farbe des Kinderrahmens
};

focusedInactive = {
  border = "#000000";            # Rahmenfarbe
  background = "#1c1c1c";        # Hintergrundfarbe
  text = "#000000";              # Textfarbe
  indicator = "#000000";         # Indikatorfarbe
  childBorder = "#1c1c1c";       # Farbe des Kinderrahmens
};

urgent = {
  border = "#000000";            # Rahmenfarbe
  background = "#FFFFFF";        # Hintergrundfarbe
  text = "#1c1c1c";              # Textfarbe
  indicator = "#000000";         # Indikatorfarbe
  childBorder = "#FFFFFF";       # Farbe des Kinderrahmens
};

placeholder = {
  border = "#000000";            # Rahmenfarbe (wird ignoriert)
  background = "#1c1c1c";        # Hintergrundfarbe
  text = "#FFFFFF";              # Textfarbe
  indicator = "#000000";         # Indikatorfarbe (wird ignoriert)
  childBorder = "#1c1c1c";       # Farbe des Kinderrahmens (wird ignoriert)
};
background = "#000000";
};

fonts = {
  names = [ "DejaVu Sans Mono" "FontAwesome5Free" ];
  style = "Bold Semi-Condensed";
  size = 12.0;
};
workspaceLayout = "default";
defaultWorkspace = "workspace number 1";
	};
    extraConfig = ''
# This file has been auto-generated by i3-config-wizard(1).
# It will not be overwritten, so edit it as you like.
#
# Should you change your keyboard layout some time, delete
# this file and re-run i3-config-wizard(1).
#

# i3 config file (v4)
#
# Please see https://i3wm.org/docs/userguide.html for a complete reference!

set $mod Mod4

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
#font pango:monospace 12

# This font is widely installed, provides lots of unicode glyphs, right-to-left
# text rendering and scalability on retina/hidpi displays (thanks to pango).
#font pango:DejaVu Sans Mono 8

# Start XDG autostart .desktop files using dex. See also
# https://wiki.archlinux.org/index.php/XDG_Autostart
exec --no-startup-id dex --autostart --environment i3

# The combination of xss-lock, nm-applet and pactl is a popular choice, so
# they are included here as an example. Modify as you see fit.

# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
#exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
exec --no-startup-id xss-lock --transfer-sleep-lock -- betterlockscreen -l 

# NetworkManager is the most popular way to manage wireless networks on Linux,
# and nm-applet is a desktop environment-independent system tray GUI for it.
exec --no-startup-id nm-applet

# Use pactl to adjust volume in PulseAudio.
set $refresh_i3status killall -SIGUSR1 i3status
#bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
#bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status

bindsym XF86AudioRaiseVolume exec --no-startup-id pamixer -i 10 && killall -SIGUSR1 i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pamixer -d 10 && killall -SIGUSR1 i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# move tiling windows via drag & drop by left-clicking into the title bar,
# or left-clicking anywhere into the window while holding the floating modifier.
tiling_drag modifier titlebar

# start a terminal
bindsym $mod+Return exec kitty

# kill focused window
bindsym $mod+Shift+q kill

# A more modern dmenu replacement is rofi:
# bindcode $mod+40 exec "rofi -modi drun,run -show drun"
# There also is i3-dmenu-desktop which only displays applications shipping a
# .desktop file. It is a wrapper around dmenu, so you need that installed.
# bindcode $mod+40 exec --no-startup-id i3-dmenu-desktop

# change focus
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+h split h

# split in vertical orientation
bindsym $mod+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
#bindsym $mod+d focus child

# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

# switch to workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart
# exit i3 (logs you out of your X session)
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

# resize window (you can also use the mouse for that)
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym j resize shrink width 10 px or 10 ppt
        bindsym k resize grow height 10 px or 10 ppt
        bindsym l resize shrink height 10 px or 10 ppt
        bindsym semicolon resize grow width 10 px or 10 ppt

        # same bindings, but for the arrow keys
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        # back to normal: Enter or Escape or $mod+r
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"

# Farben definieren
set $red #FF0000
set $green #00FF00
set $blue #0000FF
set $yellow #FFFF00
set $white #FFFFFF
set $black #000000
set $light-grey #C5C8C6
set $medium-grey #707880
set $dark-grey #1c1c1c

# Farben für verschiedene Fensterzustände
#client.focused          $black $medium-grey $black $dark-grey $medium-grey
#client.unfocused        $black $dark-grey $black $black $dark-grey
#client.focused_inactive $black $dark-grey $black $black $dark-grey
#client.urgent           $black $white $dark-grey $black $white
#client.placeholder      $black $dark-grey $white $black $dark-grey

bindsym $mod+Shift+p workspace prev
#bindsym $mod+Shift+n workspace next

#Hide window title bar
default_border pixel 2
default_floating_border pixel 2
for_window [class="^.*"] border pixel 2

# Wechselt zu einem neuen Workspace
bindsym $mod+Shift+n workspace t

# Helligkeit reduzieren
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 10%-

# Helligkeit erhöhen
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +10%

bindsym $mod+Tab workspace back_and_forth

# Tastatur Helligkeit aktivieren
bindsym F6 exec --no-startup-id brightnessctl -d tpacpi::kbd_backlight s 2

# Tastatur Helligkeit deaktivieren
bindsym F5 exec --no-startup-id brightnessctl -d tpacpi::kbd_backlight s 0 

# move workspace to left and right monitors
bindsym $mod+Shift+bracketleft move workspace to output left
bindsym $mod+Shift+bracketright move workspace to output right



# Set touchpad sensitivity
#exec --no-startup-id xinput --set-prop 9 "libinput Accel Speed" 0.35




bindsym $mod+Shift+s workspace number $ws1
bindsym $mod+Shift+o workspace number $ws2
bindsym $mod+Shift+f workspace number $ws3


bindsym $mod+p exec playerctl play-pause
bindsym $mod+o exec playerctl next
bindsym $mod+i exec playerctl previous 



for_window [class="firefox"] border pixel 0
for_window [class="Spotify"] border pixel 0
for_window [class="obsidian"] border pixel 0

for_window [class="Spotify"] move to workspace number 1
for_window [class="obsidian"] move to workspace number 2
for_window [class="firefox"] move to workspace number 3



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


   (vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      ms-python.python
      ];
    })



(pkgs.writeShellScriptBin "clean-generations.sh" ''
#!/usr/bin/env bash
set -euo pipefail

## Defaults
keepGensDef=10; keepDaysDef=20
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

# Ein Bash-Skript erstellen, das das Python-Skript ausführt
pkgs.writeShellScriptBin "create-rectangle" ''
#!/usr/bin/env bash
nix-shell -p qt5Full python310Packages.pyqt5 --run "python ${pythonScript}"
'')



}


