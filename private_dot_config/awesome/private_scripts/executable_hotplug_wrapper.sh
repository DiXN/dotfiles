#!/usr/bin/env bash

set -e

mouse="$(lsusb | awk '/G502/{ print substr($4, 1, length($4)-1)}')"
keyboard="$(lsusb | awk '/K95/{ print substr($4, 1, length($4)-1)}')"

ACTION=$1 SUBSYSTEM=usb DEVTYPE=usb_device BUSNUM=001 DEVNUM="$mouse" ~/Documents/usb-libvirt-hotplug.sh "win10-uefi" && \
  ACTION=$1 SUBSYSTEM=usb DEVTYPE=usb_device BUSNUM=001 DEVNUM="$keyboard" ~/Documents/usb-libvirt-hotplug.sh "win10-uefi"

