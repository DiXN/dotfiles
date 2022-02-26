#!/usr/bin/env bash

echo "[Installing zsh, antibody and tmux ...]"
yay -S --noconfirm zsh tmux antibody-bin
antibody bundle < ~/.zsh_plugin.txt > ~/.zsh_plugins.sh

echo "[Change login shell]"
sudo chsh -s /usr/bin/zsh "$(whoami)"

echo "[Installing spacevim ...]"
yay -S --noconfirm neovim
curl -sLf https://spacevim.org/install.sh | bash
mkdir -p ~/.local/share/nvim/shada
touch ~/.local/share/nvim/shada/main.shada

echo "[Installing awesome config ...]"
readonly AWESOME_PATH="/home/$(whoami)/.config/awesome"
git clone --recursive "https://github.com/DiXN/awesome-cfg.git" "$AWESOME_PATH"

yay -S --noconfirm lua-pam-git
sudo ln -s /usr/lib/lua-pam/liblua_pam.so /usr/lib/lua/5.4

echo "[Cleaning cache ...]"
sudo pacman -Scc --noconfirm

