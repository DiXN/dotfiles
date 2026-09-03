{ lib, pkgs, ... }:

{
  imports = [
    ./common/pc.nix
    (import ../disko-config.nix { withSwap = true; filesystem = "btrfs"; })
    ../modules/nixos/base.nix
    ../modules/nixos/wifi.nix
    ../modules/nixos/gui.nix
    ../modules/nixos/containers.nix
    ../modules/nixos/yubikey.nix
  ];

  networking.hostName = "mk-notebook";

  networking.networkmanager.wifi.powersave = lib.mkDefault true;

  services.power-profiles-daemon.enable = true;

  home-manager.users.mk.programs.niri.settings = {
    input.touch.map-to-output = "eDP-1";
    spawn-at-startup = [ { argv = [ "rot8" ]; } ];
  };

  services.snapper.configs.root = {
    SUBVOLUME = "/";
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = "5";
    TIMELINE_LIMIT_DAILY = "7";
    TIMELINE_LIMIT_WEEKLY = "0";
    TIMELINE_LIMIT_MONTHLY = "0";
    TIMELINE_LIMIT_YEARLY = "0";
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    rot8
  ];
}
