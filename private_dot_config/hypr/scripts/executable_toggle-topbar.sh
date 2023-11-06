#!/usr/bin/env bash

eww windows | grep -e '\*bar'
exit_code=$?

if [ $exit_code -eq 0 ]; then
  eww close bar
  eww open osd
  eww update EVENT_BOX_WIDTH=1
else
  eww open-many bar bgdecor
  eww update EVENT_BOX_WIDTH=390
fi

