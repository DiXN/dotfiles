#!/usr/bin/env bash

# Add instantos mirror

sudo tee /etc/pacman.d/instantmirrorlist <<EOF
# mirror list for isntantOS amd64

# official main repo
Server = http://packages.instantos.io

Server = https://instantos.file.coffee
Server = https://instantos.netlify.app
Server = https://instantos.web.app
EOF

sudo tee -a /etc/pacman.conf <<EOF
[instant]
SigLevel = Optional TrustAll
Include = /etc/pacman.d/instantmirrorlist
EOF
