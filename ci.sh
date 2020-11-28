#!/bin/bash

pacman -Sy sudo -y --noconfirm
pacman -S git -y --noconfirm
pacman -S base-devel -y --noconfirm

echo "adding user"

useradd -m -s /bin/bash instantos
echo "instantos:instantos" | chpasswd

rgroup() {
  if ! grep -q "$1" /etc/group; then
    groupadd "$1"
  fi

  gpasswd -a "instantos" "$1"
}

rgroup "autologin"
rgroup "video"
rgroup "video"
rgroup "wheel"
rgroup "input"

# allow sudo
sed -i 's/# %wheel/%wheel/g' /etc/sudoers
# clear sudo password
echo "instantos ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
echo "" >>/etc/sudoers

cat /etc/sudoers

