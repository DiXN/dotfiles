{ lib, pkgs, ... }:

{
  imports = [
    ../../disko-config.nix
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "sd_mod"
    "sr_mod"
    "uas"
    "usb_storage"
    "usbhid"
    "xhci_pci"
    "ehci_pci"
    "amdgpu"
    "i915"
    "xe"
  ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.fwupd.enable = true;
}
