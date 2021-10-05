{ lib, profiles, nixosModulesPath, ... }:
{
  # https://nix.dev/tutorials/installing-nixos-on-a-raspberry-pi
  # bud build bootstrap sdImage

  # reachable on the local link via ssh root@fe80::47%eno1
  # where 'eno1' is replaced by your own machine's network
  # interface that has the local link to the target machine
  imports = [
    # profiles.networking
    profiles.core
    profiles.users.root # make sure to configure ssh keys
    profiles.users.nixos
    # either new-kernel doesn't work or we need a gpt disk header
    "${nixosModulesPath}/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

  services.openssh = {
    openFirewall = true;
  };

  # nix-shell -p raspberrypi-eeprom
  # mount /dev/disk/by-label/FIRMWARE /mnt
  # BOOTFS=/mnt FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a
}
