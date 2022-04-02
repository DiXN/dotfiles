#!/bin/bash
# Helpful to read output when debugging
set -x

sudo modprobe vfio-pci
sudo modprobe kvm_intel nested=1

