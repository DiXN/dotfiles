#!/usr/bin/env bash

echo "$(whoami):100000:65536" | sudo tee /etc/subuid
echo "$(whoami):100000:65536" | sudo tee /etc/subgid

sudo usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$(whoami)"

