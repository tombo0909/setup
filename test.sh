
#!/usr/bin/env bash

# Füge LUKS und Bootloader-Konfiguration zur bestehenden configuration.nix hinzu
cat <<EOF >> /mnt/etc/nixos/configuration.nix

boot.initrd.luks.devices = {
  root = {
    device = "/dev/vgcrypt/lv2";
    preLVM = true;
  };
};

boot.loader.grub = {
  enable = true;
  version = 2;
  device = "$device";  # Ersetze dies durch dein tatsächliches Gerät
  efiSupport = true;
  efiInstallAsRemovable = true;
  useOSProber = true;
};

fileSystems."/" = {
  device = "/dev/mapper/vgcrypt-lv2";
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/mapper/vgcrypt-lv1";
  fsType = "vfat";
};
EOF

echo "Konfigurationsdatei aktualisiert. Fortfahren mit der NixOS-Installation."
echo "Führen Sie den Befehl 'nixos-install' aus, um die Installation abzuschließen."
