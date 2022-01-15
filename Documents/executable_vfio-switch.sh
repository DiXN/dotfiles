#!/usr/bin/env bash

MODE=$1
VM="win10-uefi"

if [ -z "$MODE" ]; then
  echo "an argument has to be provided."
  exit 1
fi

echo "$MODE" | sudo tee /etc/libvirt/storage/mode

HOOK_PATH="/etc/libvirt/hooks/qemu.d/$VM"

if [ "$MODE" = "full" ]; then
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-full/start.sh?$RANDOM" | sudo tee "$HOOK_PATH/prepare/begin/start.sh"
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-full/revert.sh?$RANDOM" | sudo tee "$HOOK_PATH/release/end/revert.sh"
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-full/qemu.conf?$RANDOM" | sudo tee /etc/libvirt/qemu.conf
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-full/win10-uefi.xml?$RANDOM"| sudo tee /etc/libvirt/qemu/win10-uefi.xml
  sudo systemctl enable vm.service && sudo kexec -l /boot/vmlinuz-linux-vfio --initrd=/boot/initramfs-linux-vfio.img --append="default_hugepagesz=1G hugepagesz=1G hugepages=12 pcie_acs_override=downstream,multifunction mitigations=off" --reuse-cmdline && systemctl kexec
fi

if [ "$MODE" = "stream" ]; then
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-stream/start.sh?$RANDOM" | sudo tee "$HOOK_PATH/prepare/begin/start.sh"
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-stream/revert.sh?$RANDOM"| sudo tee "$HOOK_PATH/release/end/revert.sh"
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-stream/qemu.conf?$RANDOM"| sudo tee /etc/libvirt/qemu.conf
  curl -L "https://raw.githubusercontent.com/DiXN/dotfiles/linux/linux/vfio/win10-stream/win10-uefi.xml?$RANDOM" | sudo tee /etc/libvirt/qemu/win10-uefi.xml
  sudo systemctl enable vm.service && sudo kexec -l /boot/vmlinuz-linux-vfio --initrd=/boot/initramfs-linux-vfio.img --append="default_hugepagesz=1G hugepagesz=1G hugepages=6 pcie_acs_override=downstream,multifunction" --reuse-cmdline && systemctl kexec
fi
