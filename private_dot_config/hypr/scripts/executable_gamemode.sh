#!/usr/bin/env sh
#
HYPRGAMEMODE=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ]; then
	hyprctl --batch "\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        "

	hyprctl keyword xwayland:force_zero_scaling false
	hyprctl keyword monitor DP-1,highrr,auto,1
	exit

fi

hyprctl reload
