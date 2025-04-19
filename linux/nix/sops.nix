{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-yubikey
  ];
}
