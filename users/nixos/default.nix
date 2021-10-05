{ hmUsers, ... }:
{
  home-manager.users = { inherit (hmUsers) nixos; };

  users.users.nixos = {
    uid = 1000;
    hashedPassword = "$6$21iQr5L1$AiN22mgmz34gIH.5GNqnbelr9ru31KYqmNaoIH91LDrcG0ZFpzJYxUf.X5djKa/lKDYuNoo0KmXsGXIy2CRTA0";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpm6jXKndgHfeANK/Dipr2f5x75EDY17/NfUieutEJ4 moritz@nixos" ];
  };
}
