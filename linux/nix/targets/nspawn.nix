{ lib, ... }:

{
  imports = [
    ./common/container.nix
    ../modules/nixos/base.nix
    ../modules/nixos/gui.nix
    ../modules/nixos/containers.nix
    ../modules/nixos/yubikey.nix
  ];

  networking.hostName = "mk-nix-sys";

  # No local pcscd: the host daemon serves the shared socket.
  services.pcscd.enable = lib.mkForce false;
}
