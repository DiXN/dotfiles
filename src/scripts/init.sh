#!/bin/bash

# cache sudo password
if [ -n "$CI" ]; then
  {
    while :; do sudo -v; sleep 59; done
    SUDO_LOOP=$!
  } &
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
chezmoi init --branch chezmoi https://github.com/DiXN/dotfiles.git -S "$DOTFILES_DIR/dotfiles"

echo "[Applying dotfiles ...]"

if [ -n "$CI" ]; then
  chezmoi apply -k --force -S "$DOTFILES_DIR/dotfiles"
else
  chezmoi apply -k --force --exclude=encrypted -S "$DOTFILES_DIR/dotfiles"

  sudo pacman -S --noconfirm tree
  tree -a -L 2 ~
fi

echo "[Installing awesome config ...]"
readonly AWESOME_PATH="/home/$(whoami)/.config/awesome"
git clone --recursive "https://github.com/DiXN/awesome-cfg.git" "$AWESOME_PATH"

curl -L -o ~/.config/awesome/liblua_pam.so "https://raw.githubusercontent.com/afreidz/dots/master/awesome/liblua_pam.so"

echo "[Setup Podman ...]"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/podman.sh"

if ! [ -x "$(command -v 'yay')" ]; then
  echo "[Installing yay ...]"
  chmod +x "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
  sh "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
fi

echo "[Install LightDM ...]"
[ -n "$CI" ] && yay -S --noconfirm lightdm lightdm-webkit2-greeter
[ -n "$CI" ] && systemctl enable lightdm

echo "[Installing zsh, antibody and tmux ...]"
yay -S --noconfirm zsh tmux antibody-bin
antibody bundle < ~/.zsh_plugin.txt > ~/.zsh_plugins.sh

echo "[Change login shell]"
sudo chsh -s /usr/bin/zsh "$(whoami)"

echo "[Installing spacevim ...]"
yay -S --noconfirm neovim
curl -sLf https://spacevim.org/install.sh | bash

echo "[Installing rustup ...]"
[ "$TYPE" != "min" ] && yay -S --noconfirm rustup

echo "[Installing dotnet ...]"
yay -S --noconfirm dotnet-sdk-bin
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"

sudo chmod +x /usr/bin/dotnet
dotnet --info
dotnet tool install -g dotnet-script

#invoke dotnet-script
echo "[Installing dotfiles ...]"

if [ "$TYPE" = "min" ]; then
  dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "$DOTFILES_DIR/dotfiles/src/templates/base/pacman.yaml"
else
  dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "$DOTFILES_DIR/dotfiles/src/templates/base/pacman.yaml" "$DOTFILES_DIR/dotfiles/src/templates/base/commands.yaml"
fi

