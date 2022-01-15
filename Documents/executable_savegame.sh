#!/usr/bin/env bash

sudo modprobe nbd
sudo qemu-nbd --connect=/dev/nbd0 $HOME/.local/share/vm/win10-uefi.qcow2
sudo mount -t ntfs3 -o uid=1000,gid=1000,rw,user,exec,umask=000 /dev/nbd0p3 /mnt/c

