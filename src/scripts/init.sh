#!/usr/bin/env bash

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

if [ -n "$CI" ]; then
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
  sudo pacman -R --noconfirm go
fi

yay -S --noconfirm python python-dbus \
  imagemagick openssh nautilus rofi alacritty \
  network-manager-applet xorg-xinput awesome-git pamixer python-pynvim \
  xclip exa mesa-utils ttf-material-design-icons-desktop-git \
  picom numlockx otf-nerd-fonts-fira-code fzf playerctl arc-gtk-theme \
  papirus-icon-theme age expect zenity nitrogen scrot

sudo pacman -Scc --noconfirm

