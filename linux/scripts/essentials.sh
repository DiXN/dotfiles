#!/usr/bin/env bash

readonly DOTFILES_DIR="/home/$(whoami)/Documents/repos/dotfiles"

echo "[Applying dotfiles ...]"

if [[ -z "$CI" ]] || [[ -z "$DOCKER" ]]; then
  PASSWD="$(zenity --password)"

  PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"

  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"
  fi
else
  chezmoi apply -k --force --exclude=encrypted -S "$DOTFILES_DIR"
fi

echo "[Install NetworkManager ...]"
yay -S --noconfirm networkmanager
sudo systemctl enable NetworkManager

echo "[Install LightDM ...]"
yay -S --noconfirm lightdm lightdm-gtk-greeter plymouth
sudo systemctl enable lightdm

echo "[Install Docker ...]"
yay -S --noconfirm docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker mk

echo "[Install Syncthing ...]"
yay -S --noconfirm syncthing
sudo systemctl enable syncthing@root.service

sudo mkdir -p /usr/share/backgrounds/
sudo cp "$DOTFILES_DIR/Pictures/wallpapers/4.jpg"  /usr/share/backgrounds/

# lightdm-gtk-greeter config
cat << EOF | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background = /usr/share/backgrounds/4.jpg
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

readonly AWESOME_PATH="/home/$(whoami)/.config/awesome"

if [[ -z "$RERUN" ]]; then
  echo "[Setup Podman ...]"
  echo "$(whoami):100000:65536" | sudo tee /etc/subuid
  echo "$(whoami):100000:65536" | sudo tee /etc/subgid

  sudo usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$(whoami)"

  echo "[Installing zsh, antibody and tmux ...]"
  yay -S --noconfirm zsh tmux antibody-bin
  antibody bundle < ~/.zsh_plugin.txt > ~/.zsh_plugins.sh

  echo "[Change login shell]"
  sudo chsh -s /usr/bin/zsh "$(whoami)"

  echo "[Installing awesome config ...]"
  git clone --recursive "https://github.com/DiXN/awesome-cfg.git" "$AWESOME_PATH"

  yay -S --noconfirm lua-pam-git
  sudo ln -s /usr/lib/lua-pam/liblua_pam.so /usr/lib/lua/5.4
else
  git -c "$AWESOME_PATH" pull
fi

sudo ln -sf "$DOTFILES_DIR/linux/scripts/system.vsh" /usr/bin

echo "[Installing piavpn ...]"
yay -S --noconfirm piavpn-bin
sudo systemctl enable piavpn.service

echo "[Cleaning cache ...]"
sudo pacman -Scc --noconfirm
