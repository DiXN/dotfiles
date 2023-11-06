#!/usr/bin/env bash

time_tracker_processes=("openrct2", "Parkitect.x86_64")
effect_processes=("csgo_linux64", "love", "steam_app_311210", "mpv", "openrct2", "Parkitect.x86_64", "org.jellyfin.jellyfinmediaplayer", "steam_app_0")

function handle {
  local cmd=$(echo "${1}" | awk 'BEGIN { FS = ">>" } ; { print $1 }')
  local process=$(echo "${1}" | awk 'BEGIN { FS = "," } ; { print $3 }')

  if [[ ${cmd} == "openwindow" ]] && [[ " ${time_tracker_processes[*]} " =~ "$process" ]]; then
    bash -c 'notify-send "time_tracker" "$($HOME/Documents/time-tracker.vsh --short --insert '"$process"')"' &
  fi

  if [[ ${cmd} == "openwindow" ]] && [[ " ${effect_processes[*]} " =~ "$process" ]]; then
    systemctl --user restart easyeffects
  fi

  if [[ ${cmd} == "openwindow" ]] && [[ "$process" == "csgo_linux64" ]]; then
    sleep 20
    wlr-randr --output DP-2 --scale 1.1
  fi

  if [[ ${cmd} == "monitoradded" ]]; then
    ags -q; ags &
    hyprctl dispatch workspace "e+1"
  fi
}

socat - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock | while read line; do handle $line; done

