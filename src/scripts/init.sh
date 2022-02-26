#!/usr/bin/env bash

echo "[Adding chaotic to Pacman configuration ...]"
sudo pacman-key --init

readonly DOTFILES_DIR="/home/$(whoami)/Documents/repos"
mkdir -p "$DOTFILES_DIR"

pushd "$DOTFILES_DIR" || exit 1

sudo pacman -Syy --noconfirm chezmoi alacritty xterm
sudo pacman -S --noconfirm glibc lib32-glibc
sudo pacman -S --noconfirm libconfig libdbus libev libgl libxcursor libxi
chezmoi init --branch minimal https://github.com/DiXN/dotfiles.git -S "$DOTFILES_DIR/dotfiles"

pushd "/tmp" || exit 1
git clone 'https://aur.archlinux.org/nerd-fonts-fira-code.git'

pushd "nerd-fonts-fira-code" || exit 1
makepkg -si --noconfirm

popd || exit 1
popd || exit 1

echo "[Applying dotfiles ...]"

if [ -n "$CI" ]; then
  chezmoi apply -k --force -S "$DOTFILES_DIR/dotfiles"
else
  chezmoi apply -k --force --exclude=encrypted -S "$DOTFILES_DIR/dotfiles"

  sudo pacman -S --noconfirm tree
  tree -a -L 2 ~
fi

sudo pacman -Scc --noconfirm

