#!/usr/bin/env bash

# cache sudo password
if [ -n "$CI" ]; then
  {
    while :; do sudo -v; sleep 59; done
    SUDO_LOOP=$!
  } &
fi

readonly DOTFILES_DIR="/home/$(whoami)/Documents/repos"

echo "[Setup Podman ...]"
echo "$(whoami):100000:65536" | sudo tee /etc/subuid
echo "$(whoami):100000:65536" | sudo tee /etc/subgid

sudo usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$(whoami)"

echo "[Install NetworkManager ...]"
yay -S --noconfirm networkmanager
sudo systemctl enable NetworkManager

echo "[Install LightDM ...]"
yay -S --noconfirm lightdm lightdm-gtk-greeter plymouth
sudo systemctl enable lightdm

sudo mkdir -p /usr/share/backgrounds/
sudo cp "$DOTFILES_DIR/Pictures/wallpapers/4.png"  /usr/share/backgrounds/

# lightdm-gtk-greeter config
cat << EOF | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background = /usr/share/backgrounds/4.png
font-name = Cantarell 10
xft-antialias = true
icon-theme-name = Papirus
screensaver-timeout = 60
theme-name = Arc
show-clock = false
default-user-image = #face-smile
xft-hintstyle = hintfull
position = 19%,center 50%,center
clock-format = 
panel-position = bottom
hide-user-image = true
EOF

echo "[Installing zsh, antibody and tmux ...]"
yay -S --noconfirm zsh tmux antibody-bin
antibody bundle < ~/.zsh_plugin.txt > ~/.zsh_plugins.sh

echo "[Change login shell]"
sudo chsh -s /usr/bin/zsh "$(whoami)"

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

