#!/usr/bin/env bash

user=$(whomai)

scripts_dir="/home/$user/Documents/scripts"
mkdir -p "$scripts_dir"

ln -s "$DOT_DIR/linux/scripts/." "$scripts_dir"

