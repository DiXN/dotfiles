#!/usr/bin/env bash

set -euo pipefail
shopt -s nocasematch

if [[ -f "$HOME/.first_boot" ]]; then
  echo "fist boot"
  rm -f "$HOME/.first_boot"
  exit 1
  readonly DOTFILES_ROOT="$HOME/Documents/repos/dotfiles"
  git -C "$DOTFILES_ROOT" pull

  yay -S zenity --noconfirm

  PASSWD="$(zenity --password)"

  PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"

  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    PASSWORD=$PASSWD expect -f "$DOTFILES_ROOT/linux/scripts/expected"
  fi
fi

