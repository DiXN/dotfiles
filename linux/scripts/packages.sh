#!/usr/bin/env bash

# cache sudo password
if [ -n "$CI" ]; then
  {
    while :; do sudo -v; sleep 59; done
    SUDO_LOOP=$!
  } &
fi

if ! [ -z "$FILE_PATH" ]; then
  IDX=$(echo "$FILE_PATH" | sed -E 's|.*([0-9]).*|\1|')
  #invoke dotnet-script
  echo "[Installing dotfiles chunk $IDX from file: '$FILE_PATH' ...]"
else
  #invoke dotnet-script
  echo "[Installing dotfiles ...]"
fi

export PATH="$PATH:/home/$(whoami)/.dotnet/tools"
readonly DOTFILES_DIR="/home/$(whoami)/Documents/repos"

if [ "$INSTALL_TYPE" = "min" ]; then
  dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "${FILE_PATH:-./dotfiles/src/templates/base/pacman.yaml}"
else
  dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "${FILE_PATH:-./dotfiles/src/templates/base/pacman.yaml}" "$DOTFILES_DIR/dotfiles/src/templates/base/commands.yaml"
fi

echo "[Cleaning cache ...]"
sudo pacman -Scc --noconfirm

