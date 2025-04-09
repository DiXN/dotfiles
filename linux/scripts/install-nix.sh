#!/usr/bin/env bash
set -e

# Short url: https://is.gd/pmakpq

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Ensure git is available
echo "Ensuring git is installed..."
if ! command -v git &> /dev/null; then
  echo "Git not found, installing..."
  nix-env -iA nixos.git
fi

# Clone your NixOS configuration
if [ ! -d "/tmp/nixos-config" ]; then
  echo "Cloning DiXN/dotfiles repository (chezmoi branch)..."
  git clone --branch chezmoi https://github.com/DiXN/dotfiles.git /tmp/nixos-config
fi

# Format disks using disko
echo "Formatting disks with disko..."
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko /tmp/nixos-config/linux/nix/disko-config.nix

# Mount the partitions (disko should have done this already, but just in case)
echo "Mounting partitions..."
mount -o subvol=root /dev/mapper/mainpool-root /mnt
mkdir -p /mnt/{boot,home,nix}
mount /dev/disk/by-label/ESP /mnt/boot
mount -o subvol=home /dev/mapper/mainpool-home /mnt/home
mount -o subvol=nix /dev/mapper/mainpool-nix /mnt/nix

# Copy your configuration to the target system
echo "Copying NixOS configuration..."
mkdir -p /mnt/etc/nixos
cp -r /tmp/nixos-config/linux/nix/* /mnt/etc/nixos/

# Install NixOS
echo "Installing NixOS..."
nixos-install --flake /mnt/etc/nixos#mk

echo "Installation complete! You can reboot now."
