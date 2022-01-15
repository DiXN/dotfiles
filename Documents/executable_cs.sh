#!/usr/bin/env bash

sudo mount /dev/sdb2 /mnt/f

user_dir="userdata/84363336/730/local/cfg"
second_acc="userdata/40503414/730/local/cfg"

pushd "/mnt/f/Program Files (x86)/Steam/${user_dir}" || exit 1

backup="/home/mk/Documents/cs"
mkdir -p ${backup}

cp config.cfg ${backup}

popd || exit 1

pushd "/home/mk/.local/share/Steam/${user_dir}" || exit 1

sudo cp "${backup}/config.cfg" "config.cfg"
chmod -w "config.cfg"

popd || exit 1

pushd "/home/mk/.local/share/Steam/${second_acc}" || exit 1

sudo cp "${backup}/config.cfg" "config.cfg"
chmod -w "config.cfg"

