#!/usr/bin/env bash

echo "[Installing zsh, antibody and tmux ...]"

pushd "/tmp" || exit 1
git clone 'https://aur.archlinux.org/antibody-bin.git'

pushd "antibody-bin" || exit 1
makepkg -si --noconfirm

popd || exit 1
popd || exit 1

sudo pacman -S --noconfirm zsh tmux
antibody bundle < ~/.zsh_plugin.txt > ~/.zsh_plugins.sh

echo "[Change login shell]"
sudo chsh -s /usr/bin/zsh "$(whoami)"

echo "[Cleaning cache ...]"
sudo pacman -Scc --noconfirm

