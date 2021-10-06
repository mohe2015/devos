# https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_systemd-networkd
# https://wiki.archlinux.org/title/WireGuard#systemd-networkd
# https://www.freedesktop.org/software/systemd/man/systemd.netdev.html
# THIS IS THE CLIENT SETUP IT SEEMS

{ config, pkgs, lib, ... }: {
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
  systemd.network = {
    enable = true;
    netdevs = {
      "10-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          MTUBytes = "1300";
          Name = "wg0";
        };
        # See also man systemd.netdev
        extraConfig = ''
          [WireGuard]
          # Currently, the private key must be world readable, as the resulting netdev file will reside in the Nix store.
          PrivateKey=EMlybyTmXI/4z311xU9S3m82mC2OOMRfRM0Okiik83o=
          ListenPort=9918

          [WireGuardPeer]
          PublicKey=OhApdFoOYnKesRVpnYRqwk3pdM247j8PPVH5K7aIKX0=
          AllowedIPs=fc00::1/64, 10.100.0.1
          Endpoint={set this to the server ip}:51820
        '';
      };
    };
    networks = {
      # See also man systemd.network
      "40-wg0".extraConfig = ''
        [Match]
        Name=wg0

        [Network]
        DHCP=none
        IPv6AcceptRA=false
        Gateway=fc00::1
        Gateway=10.100.0.1
        DNS=fc00::53
        NTP=fc00::123

        # IP addresses the client interface will have
        [Address]
        Address=fe80::3/64
        [Address]
        Address=fc00::3/120
        [Address]
        Address=10.100.0.2/24
      '';
    };
  };
}
