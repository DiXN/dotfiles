#!/usr/bin/env bash

user=$(whoami)

scripts_dir="/home/$user/Documents/scripts"
mkdir -p "$scripts_dir"

DOT_DIR="$DOT_DIR/dotfiles"

# scripts
cp -r -s "$DOT_DIR/linux/scripts"/* "$scripts_dir"

# zsh
ln -s "$DOT_DIR/linux/.zshenv" "/home/$user/.zshenv"

# configs
mkdir -p "/home/$user/.config/"
cp -r -s "$DOT_DIR/linux/.config"/* "/home/$user/.config/"

# git
ln -s "$DOT_DIR/linux/.gitconfig" "/home/$user/.gitconfig"

# rofi
ln -s "$DOT_DIR/linux/launcher.rasi" "/home/$user/launcher.rasi"
ln -s "$DOT_DIR/linux/theme.rasi" "/home/$user/theme.rasi"
ln -s "$DOT_DIR/linux/global.rasi" "/home/$user/global.rasi"

ls -a "$scripts_dir"
ls -a "/home/$user/.config"

