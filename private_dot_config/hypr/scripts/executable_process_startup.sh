#!/usr/bin/env bash

time_tracker_processes=("openrct2" "Parkitect.x86_64" "steam_app_2369390")
effect_processes=("cs2" "love" "steam_app_311210" "mpv" "openrct2" "Parkitect.x86_64" "org.jellyfin.jellyfinmediaplayer" "steam_app_0" "steam_app_2369390")

function handle {
	local cmd=$(echo "${1}" | awk 'BEGIN { FS = ">>" } ; { print $1 }')
	local fullscreen_val=$(echo "${1}" | awk 'BEGIN { FS = ">>" } ; { print $2 }')
	local process=$(echo "${1}" | awk 'BEGIN { FS = "," } ; { print $3 }')

	if [[ ${cmd} == "openwindow" ]] && [[ ${time_tracker_processes[*]} =~ (^|[[:space:]])"$process"($|[[:space:]]) ]]; then
		bash -c 'notify-send "time_tracker" "$($HOME/Documents/time-tracker.vsh --short --insert '"$process"')"' &
	fi

	if [[ ${cmd} == "openwindow" ]] && [[ ${effect_processes[*]} =~ (^|[[:space:]])"$process"($|[[:space:]]) ]]; then
		systemctl --user restart easyeffects
	fi

	# if [[ ${cmd} == "openwindow" ]] && [[ "$process" == "cs2" ]]; then
	# fi

	# if [[ ${cmd} == "fullscreen" ]]; then
	#   bash ~/.config/hypr/scripts/gamemode.sh
	# fi

	if [[ ${cmd} == "monitoradded" ]]; then
		sleep 2
		# hyprctl dispatch workspace "e+1"
		ags -q
		ags &
	fi
}

socat - UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | while read line; do handle $line; done
