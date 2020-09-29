#!/usr/bin/bash

if [ $1 = 'up' ]; then
    xrandr --output DP-4 --brightness 1.0
    xrandr --output HDMI-0 --brightness 0.12
    xrandr --output DVI-D-0 --brightness 1.00
fi

if [ $1 = 'down' ]; then
    xrandr --output DP-4 --brightness 0.12
    xrandr --output HDMI-0 --brightness 1.00
    xrandr --output DVI-D-0 --brightness 0.12
fi

