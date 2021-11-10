#!/bin/bash
set -x

##TOTAL_CORES="0-11"
#
##sudo systemctl set-property --runtime -- system.slice AllowedCPUs="$TOTAL_CORES"
#sudo systemctl set-property --runtime -- user.slice AllowedCPUs="$TOTAL_CORES"
#sudo systemctl set-property --runtime -- init.slice AllowedCPUs="$TOTAL_CORES"
#
#echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
#
#sudo systemctl stop lightdm-plymouth.service
#
## Unload VFIO-PCI Kernel Driver
#sudo modprobe -r vfio-pci
#sudo modprobe -r vfio_iommu_type1
#sudo modprobe -r vfio
##
## Re-Bind GPU to Nvidia Driver
#sudo virsh nodedev-reattach pci_0000_01_00_1
#sudo virsh nodedev-reattach pci_0000_01_00_0
##
## Rebind VT consoles
#echo 1 | sudo tee /sys/class/vtconsole/vtcon0/bind
## Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
## echo 1 | sudo tee /sys/class/vtconsole/vtcon1/bind
##
#nvidia-xconfig --query-gpu-info > /dev/null 2>&1
#echo "efi-framebuffer.0" | sudo tee /sys/bus/platform/drivers/efi-framebuffer/bind
#
#sudo modprobe nvidia_drm
#sudo modprobe nvidia_modeset
#sudo modprobe nvidia_uvm
#sudo modprobe nvidia
##
## sudo cp /etc/X11/_xorg.conf /etc/X11/xorg.conf
##
#sudo cp /etc/X11/nvidia_duo.xorg.conf /etc/X11/xorg.conf
#
#sudo systemctl stop vm.service
#sudo systemctl disable vm.service
##
## Restart Display Manager
#sudo systemctl start lightdm-plymouth.service

sudo cp /etc/X11/nvidia_duo.xorg.conf /etc/X11/xorg.conf

sudo systemctl stop vm.service
sudo systemctl disable vm.service

sleep 1

sudo kexec -l /boot/vmlinuz-linux-zen --initrd=/boot/initramfs-linux-zen.img --append="BOOT_IMAGE=/boot/vmlinuz-linux-zen root=UUID=226d546b-81ac-464b-af16-64e07aef58f7 rw loglevel=3 quiet quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0 intel_iommu=on" && systemctl kexec

