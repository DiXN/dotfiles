#!/bin/bash

# cache sudo password
if ! [ -z "$CI" ] || ! [ -z "$DOCKER" ]; then
  {
    while :; do sudo -v; sleep 59; done
    SUDO_LOOP=$!
  } &
fi

[ "$INSTALL_TYPE" = "min" ] && echo "[Running minimum configuration ...]"

echo "[Adding chaotic to Pacman configuration ...]"
sudo pacman-key --init
sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

CORES="$(lscpu | awk '/^CPU\(s\):/{ print $2 }')"

cat <<EOF | sudo tee -a /etc/pacman.conf
Color
CheckSpace
ILoveCandy
ParallelDownloads=$CORES

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

readonly DOTFILES_DIR="/home/$(whoami)/Documents/repos"
mkdir -p "$DOTFILES_DIR"

pushd "$DOTFILES_DIR" || exit 1

sudo pacman -Syy --noconfirm git
sudo pacman -S --noconfirm chezmoi
sudo pacman -S --noconfirm glibc lib32-glibc
chezmoi init --branch chezmoi https://github.com/DiXN/dotfiles.git -S "$DOTFILES_DIR/dotfiles"

echo "[Applying dotfiles ...]"

if ! [ -z "$CI" ]; then
  chezmoi apply -k --force -S "$DOTFILES_DIR/dotfiles"
else
  chezmoi apply -k --force --exclude=encrypted -S "$DOTFILES_DIR/dotfiles"

  sudo pacman -S --noconfirm tree
  tree -a -L 2 ~
fi

if ! [ -x "$(command -v 'yay')" ]; then
  echo "[Installing yay ...]"
  chmod +x "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
  sh "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
fi

echo "[Installing rustup ...]"
[ "$INSTALL_TYPE" != "min" ] && yay -S --noconfirm rustup

echo "[Installing dotnet ...]"
yay -S --noconfirm dotnet-sdk-6.0 dotnet-runtime-6.0
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"

sudo chmod +x /usr/bin/dotnet
dotnet --info
dotnet tool install -g dotnet-script

if [ -z "$DOCKER" ]; then
  bash "$DOTFILES_DIR/dotfiles/linux/scripts/packages.sh"
fi

echo "[Cleaning cache ...]"
sudo pacman -Scc --noconfirm

if [ -z "$DOCKER" ] && [ -z "$CI" ]; then
  bash "$DOTFILES_DIR/dotfiles/linux/scripts/essentials.sh"
fi

