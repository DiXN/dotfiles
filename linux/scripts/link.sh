#!/usr/bin/env bash

user=$(whoami)

scripts_dir="/home/$user/Documents/scripts"
mkdir -p "$scripts_dir"

DOT_DIR="$DOT_DIR/dotfiles"

cp -r -s "$DOT_DIR/linux/scripts"/* "$scripts_dir"
ln -s "$DOT_DIR/linux/.zshenv" "/home/$user/.zshenv"

mkdir -p "/home/$user/.config/"
cp -r -s "$DOT_DIR/linux/.config"/* "/home/$user/.config/"
ln -s "$DOT_DIR/linux/.gitconfig" "/home/$user/.gitconfig"

ls -a "$scripts_dir"
ls -a "/home/$user/.config"

