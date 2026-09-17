{ lib, ... }:

{
  imports = [
    ./common/container.nix
    ../modules/nixos/base.nix
    ../modules/nixos/gui.nix
    ../modules/nixos/containers.nix
    ../modules/nixos/gaming.nix
    ../modules/nixos/yubikey.nix
  ];

  networking.hostName = "mk-nix-sys";

  home-manager.users.mk.programs.niri.settings = {
    environment = lib.mkForce {
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

  # No local pcscd: the host daemon serves the shared socket.
  services.pcscd.enable = lib.mkForce false;

  home-manager.users.mk.programs.zen-browser.profiles.mk.mods = lib.mkForce [];
}
