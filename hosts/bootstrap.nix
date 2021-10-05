{ lib, profiles, nixosModulesPath, ... }:
{
  # https://nix.dev/tutorials/installing-nixos-on-a-raspberry-pi

  # build with: `bud build bootstrap bootstrapIso`
  # reachable on the local link via ssh root@fe80::47%eno1
  # where 'eno1' is replaced by your own machine's network
  # interface that has the local link to the target machine
  imports = [
    # profiles.networking
    profiles.core
    profiles.users.root # make sure to configure ssh keys
    profiles.users.nixos
    "${nixosModulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-installer.nix"
  ];

  boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

  # nix-shell -p raspberrypi-eeprom
  # mount /dev/disk/by-label/FIRMWARE /mnt
  # BOOTFS=/mnt FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a
}
