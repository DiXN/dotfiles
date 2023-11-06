#!/usr/bin/env bash

hyprctl dispatch togglespecialworkspace

hyprctl activewindow -j | gojq -e ".fullscreen == true"
exit_code=$?

if [ $exit_code -eq 0 ]; then
  # hyprctl dispatch togglefloating
fi

