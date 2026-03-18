#!/usr/bin/env bash

SRC_DIR="/tmp/dotfiles/linux/nix"
DEST_DIR="/etc/nixos"

echo "Syncing all files from $SRC_DIR to $DEST_DIR..."

# Generate hardware-configuration.nix if it doesn't exist in source
if [ ! -f "$SRC_DIR/hardware-configuration.nix" ]; then
    echo "Generating hardware-configuration.nix..."
    # Attempt to generate it (this works if nixos-generate-config is available)
    sudo nixos-generate-config --show-hardware-config > "$SRC_DIR/hardware-configuration.nix"
fi

# Ensure the destination exists
sudo mkdir -p "$DEST_DIR"

# Use rsync to mirror the directory structure and files
# Excluding .git and the script itself
sudo rsync -av --delete --exclude=".git/" --exclude="sync-to-nixos.sh" "$SRC_DIR/" "$DEST_DIR/"

echo "Sync complete."
