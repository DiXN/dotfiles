{ lib, pkgs, ... }:

{
  imports = [
    ./common/pc.nix
    ../modules/nixos/base.nix
    ../modules/nixos/gui.nix
    ../modules/nixos/containers.nix
    ../modules/nixos/yubikey.nix
  ];

  networking.hostName = "mk-notebook";

  networking.networkmanager.wifi.powersave = lib.mkDefault true;

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
