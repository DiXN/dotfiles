#!/usr/bin/env bash
set -e

# Short url: https://is.gd/pmakpq

# Default disk if not specified
TARGET_DISK=${1:-"/dev/sda"}

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
echo "Formatting disk: $TARGET_DISK with disko..."
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko --arg targetDisk "\"$TARGET_DISK\"" /tmp/nixos-config/linux/nix/disko-config.nix

# Copy your configuration to the target system
echo "Copying NixOS configuration..."
mkdir -p /mnt/etc/nixos
cp -r /tmp/nixos-config/linux/nix/* /mnt/etc/nixos/

# Generate hardware configuration for this specific machine
echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

##Print config
cat /mnt/etc/nixos/hardware-configuration.nix

# Install NixOS
echo "Installing NixOS..."
nixos-install --flake /mnt/etc/nixos#mk

echo "Installation complete! You can reboot now."
