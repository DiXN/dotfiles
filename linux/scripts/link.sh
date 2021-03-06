#!/usr/bin/env bash

user=$(whomai)

scripts_dir="/home/$user/Documents/scripts"
mkdir -p "$scripts_dir"

ln -s "$DOT_DIR/linux/scripts/." "$scripts_dir"
ln -s "$DOT_DIR/linux/.zshenv" "/home/$user/.zshenv"
ln -s "$DOT_DIR/linux/.config/." "/home/$user/.config/"
ln -s "$DOT_DIR/linux/.gitconfig" "/home/$user/.gitconfig"

