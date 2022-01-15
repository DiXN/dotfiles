#! /usr/bin/env bash
set -x
MONITOR_NAMES=($(xrandr --verbose | awk '/connected.*[0-9]+x[0-9]+/{print $1}'| head))
MONITOR_BRIGHTNESSES=($(xrandr --verbose | awk '/Brightness/ { print $2 }'))

for i in "${!MONITOR_NAMES[@]}"; do
  if [ "$1" == "${MONITOR_NAMES[i]}" ]; then
    echo "${MONITOR_BRIGHTNESSES[i]}"
  fi
done

#xrandr --output $1 --brightness $2
