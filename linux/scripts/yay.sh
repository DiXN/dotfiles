#!/bin/bash

echo '== Installing "yay".'

pushd "/tmp" || exit 1
git clone 'https://aur.archlinux.org/yay.git'

pushd "yay" || exit 1
makepkg -si --noconfirm
yay --noconfirm -R go

popd || exit 1
popd || exit 1

