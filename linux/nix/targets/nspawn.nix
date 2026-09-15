{
  imports = [
    ./common/container.nix
    ../modules/nixos/base.nix
    ../modules/nixos/gui.nix
    ../modules/nixos/containers.nix
  ];

  networking.hostName = "mk-nix-sys";
}
