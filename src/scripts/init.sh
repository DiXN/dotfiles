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

readonly DOTFILES_DIR="/home/$(whoami)/Documents/repos"
mkdir -p "$DOTFILES_DIR"

pushd "$DOTFILES_DIR" || exit 1

sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm chezmoi
chezmoi init --branch chezmoi https://github.com/DiXN/dotfiles.git -S "$DOTFILES_DIR/dotfiles"

echo "[Installing awesome config ...]"
readonly AWESOME_PATH="/home/$(whoami)/.config/awesome"
git clone "https://github.com/DiXN/awesome-cfg.git" "$AWESOME_PATH"

curl -L -o ~/.config/awesome/liblua_pam.so "https://raw.githubusercontent.com/afreidz/dots/master/awesome/liblua_pam.so"

echo "[Setup Podman ...]"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/podman.sh"

if ! which yay > /dev/null; then
  echo "[Installing yay ...]"
  chmod +x "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
  sh "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
fi

echo "[Install LightDM ...]"
yay -S --noconfirm lightdm lightdm-webkit2-greeter
systemctl enable lightdm

echo "[Installing zsh and tmux ...]"
yay -S --noconfirm zsh
yay -S --noconfirm tmux
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -L https://raw.githubusercontent.com/instantOS/instantSHELL/main/instantos.zsh-theme > .oh-my-zsh/themes/instantos.zsh-theme

echo "[Change login shell]"
sudo chsh -s /usr/bin/zsh "$(whoami)"

echo "[Installing spacevim ...]"
curl -sLf https://spacevim.org/install.sh | bash

echo "[Installing rustup ...]"
yay -S --noconfirm rustup

echo "[Installing dotnet ...]"
yay -S --noconfirm dotnet-sdk-bin
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"

sudo chmod +x /usr/bin/dotnet
dotnet --info
dotnet tool install -g dotnet-script

#invoke dotnet-script
echo "[Installing dotfiles ...]"
dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "$DOTFILES_DIR/dotfiles/src/templates/base/pacman.yaml" "$DOTFILES_DIR/dotfiles/src/templates/base/commands.yaml"

echo "[Applying dotfiles ...]"
chezmoi cd
chezmoi apply -v -k --force

tree -a -L 2 ~

