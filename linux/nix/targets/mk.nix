{
  imports = [
    ./common/vm.nix
    ../modules/nixos/base.nix
    ../modules/nixos/gui.nix
    ../modules/nixos/containers.nix
    ../modules/nixos/yubikey.nix
  ];

  networking.hostName = "mk-vm";

  boot.kernelModules = [ "kvm-amd" ];
}
