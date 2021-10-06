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

  sdImage.compressImage = false;

  security.sudo.wheelNeedsPassword = false;

  boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

  services.openssh = {
    openFirewall = true;
  };

  # https://github.com/NixOS/nixpkgs/issues/10001
  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;
  };
  systemd.network.enable = true;
  networking.usePredictableInterfaceNames = lib.mkForce true;

  systemd.network.networks =
    let
      networkConfig = {
        DHCP = "yes";
        # resolvectl dnssec eth0 off # to fix
        DNSSEC = "no"; # can't use because NTP doesn't get bootstrapped - tihs is supposed to work but it doesn't
        DNSOverTLS = "no";
        DNS = [ "1.1.1.1" "1.0.0.1" ];
      };
    in
    {
      # Config for all useful interfaces
      "40-wired" = {
        enable = true;
        name = "e*";
        inherit networkConfig;
        dhcpV4Config.RouteMetric = 1024; # Better be explicit
      };
      "40-wireless" = {
        enable = true;
        name = "w*";
        inherit networkConfig;
        dhcpV4Config.RouteMetric = 2048; # Prefer wired
      };
    };

  # Wait for any interface to become available, not for all
  # systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
  #   "" "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  # ];

  # nix-shell -p raspberrypi-eeprom
  # mount /dev/disk/by-label/FIRMWARE /mnt
  # BOOTFS=/mnt FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a
}
