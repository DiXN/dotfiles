#!/bin/bash

# cache sudo password
if ! [ -z $CI ]; then
  while :; do sudo -v; sleep 59; done &
  SUDO_LOOP=$!
fi

# echo -n "Enter password to start dotfiles process: "
# read -s firstpassword
# echo
# read -s -p "Retype password: " secondpassword
# echo
# if [ $firstpassword != $secondpassword ]; then
  # echo "You have entered different passwords."
  # exit 1
# fi

readonly DOTFILES_DIR=$(mktemp --tmpdir --directory dotfiles.XXXXXX)
pushd "$DOTFILES_DIR" || exit 1

git clone "https://github.com/DiXN/dotfiles.git"

pushd "$DOTFILES_DIR/dotfiles" || exit 1
git checkout linux

echo "[Installing yay ...]"
chmod +x "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"

echo "[Installing Rust ...]"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/rust.sh"

echo "[Setup Podman ...]"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/podman.sh"

echo "[Installing dotnet ...]"

yay -S --noconfirm dotnet-sdk-bin
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"

sudo chmod +x /usr/bin/dotnet
dotnet --info
dotnet tool install -g dotnet-script

#invoke dotnet-script
echo "[Installing dotfiles ...]"
dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "$DOTFILES_DIR/dotfiles/src/templates/base/pacman.yaml"

