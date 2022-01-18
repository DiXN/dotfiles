#!/bin/bash

set -x

echo "Hello $INST_USER"

L_USER=${INST_USER:-instantos}

pacman -Sy sudo -y --noconfirm
pacman -S git -y --noconfirm
pacman -S base-devel -y --noconfirm

echo "adding user"

useradd -m -s /bin/bash "$L_USER"
echo "$L_USER:$L_USER" | chpasswd

rgroup() {
  if ! grep -q "$1" /etc/group; then
    groupadd "$1"
  fi

  gpasswd -a "$L_USER" "$1"
}

rgroup "autologin"
rgroup "video"
rgroup "wheel"
rgroup "input"

# allow sudo
sed -i 's/# %wheel/%wheel/g' /etc/sudoers
# clear sudo password
echo "$L_USER ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
echo "" >>/etc/sudoers

cat /etc/sudoers

