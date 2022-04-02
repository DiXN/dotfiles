#!/bin/bash
# Helpful to read output when debugging
set -x

VIRT_CORES="0,6"

sudo systemctl set-property --runtime -- system.slice AllowedCPUs="$VIRT_CORES"
sudo systemctl set-property --runtime -- user.slice AllowedCPUs="$VIRT_CORES"
sudo systemctl set-property --runtime -- init.scope AllowedCPUs="$VIRT_CORES"

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Stop display manager
sudo systemctl stop lightdm-plymouth.service

# sudo systemctl isolate multi-user.target

# Unbind VTconsoles
echo 0 | sudo tee /sys/class/vtconsole/vtcon0/bind
# echo 0 | sudo tee /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 | sudo tee /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
sleep 2

# Unload all Nvidia drivers
sudo modprobe -r nvidia_drm
sudo modprobe -r nvidia_modeset
sudo modprobe -r nvidia_uvm
sudo modprobe -r nvidia

# Unbind the GPU from display driver
sudo virsh nodedev-detach pci_0000_01_00_1

sleep 0.5
sudo virsh nodedev-detach pci_0000_01_00_0

# Load VFIO Kernel Module
sudo modprobe vfio-pci
sudo modprobe kvm_intel nested=1

# Start SSH session
# ssh mk -f "ping google.com"

# Change to DisplayPort on Monitor
ddccontrol -r 0x60 -w 15 dev:/dev/i2c-4

sudo cp /etc/X11/simple_intel_xorg.conf /etc/X11/xorg.conf

sleep 0.5

sudo systemctl start lightdm-plymouth.service
