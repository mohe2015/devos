{ config, lib, suites, nixosModulesPath, ... }:
{
  # deploy '.#NixOS' --ssh-user nixos --hostname 192.168.2.127

  imports = suites.base ++ [
    "${nixosModulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

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
}
