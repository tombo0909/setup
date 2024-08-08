# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:



{  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  swapDevices = [ { device = "/var/swapfile"; size = 8192; } ];
  boot.resumeDevice = "/dev/nvme0n1p2";  # the unlocked drive mapping /root-partition
  boot.kernelParams = [
   "resume=UUID=f4d5497c-8d6e-4f44-bbcd-4b98dec084b6" #sudo blkid -s UUID -o value /var/swapfile
   "resume_offset=7245824" #sudo filefrag -v /var/swapfile | grep " 0:" | awk '{print $4}'
  ];
 
  networking = {
    wireless = {
      enable = true;
      networks = {
        "FRITZ!Box 7530 KH" = {
          psk = "AralHat2407Auf";
        };
      };
    };
  };
  
   
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
    exampleScript = {
      text = ''
      #!/usr/bin/env bash
      source ${config.system.build.setEnvironment}
     # mkdir /home/tom/neu
     # git clone https://github.com/tombo0909/setup.git
     ${pkgs.sudo}/bin/sudo touch /etc/zumTesten
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
     "*/6 * * * * tom ~/.config/scripts/check-battery.sh"
     "*/30 * * * * tom ~/.config/scripts/backup-home.sh"
     "*/1 * * * * tom /home/tom/kk.sh"
#"0 */1 * * * * tom cp -r ~/.mozilla/firefox/*.default/sessionstore-backups/* ~/setup/firefox/ && cd ~/setup/firefox && git add . && git commit -m 'Update setup' && git push"
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
     sudo



  (vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      ms-python.python
      ];
    })
  ];


  fonts.packages = with pkgs; [
    font-awesome
  ];
    
 

 

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
        initExtra = ''
  export GPG_TTY=$(tty)
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  HISTCONTROL=ignoreboth
  
  # append to the history file, don't overwrite it
  shopt -s histappend

  # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=-1
  HISTFILESIZE=-1
  # Ton deaktivieren im Terminal bei Fehler
  bind 'set bell-style none'
   
export PS1='\[\033[1;38;2;255;140;0m\]\u@\h\[\033[1;37m\]:\[\033[1;38;2;255;140;0m\]\w\[\033[00m\]\$ '
alias open='xdg-open'
alias gita='git add .'
alias gitc='git commit -m "c"'
alias gitp='git push'
alias gitf='git add . && git commit -m "c" && git push'
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

