{ config, lib, suites, nixosModulesPath, ... }:
{
  # for first time:
  # deploy '.#NixOS' --ssh-user nixos --hostname 192.168.2.126 --magic-rollback false
  # else:
  # deploy '.#NixOS' --ssh-user nixos --hostname 192.168.2.126

  imports = suites.base ++ [
    "${nixosModulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

  services.openssh = {
    openFirewall = true;
  };
  
  # https://github.com/NixOS/nixpkgs/issues/10001
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks = let
    networkConfig = {
      DHCP = "yes";
      DNSSEC = "yes";
      DNSOverTLS = "yes";
      DNS = [ "1.1.1.1" "1.0.0.1" ];
    };
  in {
    # Config for all useful interfaces
    "40-wired" = {
      enable = true;
      name = "en*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 1024; # Better be explicit
    };
    "40-wireless" = {
      enable = true;
      name = "wl*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 2048; # Prefer wired
    };
  };

  # Wait for any interface to become available, not for all
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    "" "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];
}
