#!/bin/bash
# Helpful to read output when debugging
set -x

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Stop display manager
sudo systemctl stop lightdm-plymouth.service

# sudo systemctl isolate multi-user.target

# Unload all Nvidia drivers
sudo modprobe -r nvidia_drm
sudo modprobe -r nvidia_modeset
sudo modprobe -r nvidia_uvm
sudo modprobe -r nvidia

# Unbind the GPU from display driver
sudo virsh nodedev-detach pci_0000_02_00_1

sleep 0.5
sudo virsh nodedev-detach pci_0000_02_00_0

# Load VFIO Kernel Module
sudo modprobe vfio-pci
sudo modprobe kvm_intel nested=1

sudo modprobe nvidia_drm
sudo modprobe nvidia_modeset
sudo modprobe nvidia_uvm
sudo modprobe nvidia

sleep 0.5

sudo systemctl start lightdm-plymouth.service

