{ modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    (import ../../disko-config.nix { withSwap = false; })
  ];

  boot.initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "uas" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  disko.imageBuilder.imageFormat = "qcow2";
}
