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

pacman -S --noconfirm git
git clone "https://github.com/DiXN/dotfiles.git"

pushd "$DOTFILES_DIR/dotfiles" || exit 1
git checkout linux

popd || exit 1

echo "[Installing awesome config ...]"
readonly AWESOME_PATH="/home/$(whoami)/.config/awesome"
git clone "https://github.com/DiXN/awesome-cfg.git" "$AWESOME_PATH"

echo "[Setup Podman ...]"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/podman.sh"

echo "[link scripts and config ...]"
DOT_DIR="$DOTFILES_DIR" sh "$DOTFILES_DIR/dotfiles/linux/scripts/link.sh"

if ! which yay > /dev/null; then
  echo "[Installing yay ...]"
  chmod +x "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
  sh "$DOTFILES_DIR/dotfiles/linux/scripts/yay.sh"
fi

echo "[Installing Rust ...]"
sh "$DOTFILES_DIR/dotfiles/linux/scripts/rust.sh"

echo "[Installing zsh and tmux ...]"
yay -S --noconfirm zsh
yay -S --noconfirm tmux
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "[Installing spacevim ...]"
curl -sLf https://spacevim.org/install.sh | bash

echo "[Installing dotnet ...]"
yay -S --noconfirm dotnet-sdk-bin
export PATH="$PATH:/home/$(whoami)/.dotnet/tools"

sudo chmod +x /usr/bin/dotnet
dotnet --info
dotnet tool install -g dotnet-script

#invoke dotnet-script
echo "[Installing dotfiles ...]"
dotnet script -c release "$DOTFILES_DIR/dotfiles/src/scripts/dotnet/main.csx" -- "$DOTFILES_DIR/dotfiles/src/templates/base/pacman.yaml"

