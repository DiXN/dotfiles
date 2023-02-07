#!/usr/bin/env bash

# cache sudo password
if [ -n "$CI" ]; then
  {
    while :; do sudo -v; sleep 59; done
    SUDO_LOOP=$!
  } &
fi

echo "[Setup Podman ...]"
echo "$(whoami):100000:65536" | sudo tee /etc/subuid
echo "$(whoami):100000:65536" | sudo tee /etc/subgid

sudo usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$(whoami)"

echo "[Install NetworkManager ...]"
yay -S --noconfirm networkmanager
sudo systemctl enable NetworkManager

echo "[Install LightDM ...]"
yay -S --noconfirm lightdm lightdm-webkit2-greeter lightdm-gtk-greeter plymouth
sudo systemctl enable lightdm

echo "[Installing zsh, antibody and tmux ...]"
yay -S --noconfirm zsh tmux antibody-bin
antibody bundle < ~/.zsh_plugin.txt > ~/.zsh_plugins.sh

echo "[Change login shell]"
sudo chsh -s /usr/bin/zsh "$(whoami)"

echo "[Installing spacevim ...]"
yay -S --noconfirm neovim
curl -sLf https://spacevim.org/install.sh | bash -s -- --install neovim
mkdir -p ~/.local/share/nvim/shada
touch ~/.local/share/nvim/shada/main.shada

echo "[Installing awesome config ...]"
readonly AWESOME_PATH="/home/$(whoami)/.config/awesome"
git clone --recursive "https://github.com/DiXN/awesome-cfg.git" "$AWESOME_PATH"

yay -S --noconfirm lua-pam-git
sudo ln -s /usr/lib/lua-pam/liblua_pam.so /usr/lib/lua/5.4

echo "[Installing piavpn ...]"
yay -S --noconfirm piavpn-bin
sudo systemctl enable piavpn.service

echo "[Cleaning cache ...]"
sudo pacman -Scc --noconfirm

