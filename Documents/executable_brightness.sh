#!/usr/bin/sh




if [ $1 = 'up' ]; then
    xrandr --output DP-4 --brightness 1.00

    if ! iconf -i ultra; then
      xrandr --output HDMI-0 --brightness 0.12
      xrandr --output DVI-D-0 --brightness 1.00
    else
      xrandr --output HDMI-0 --brightness 1.00
    fi
fi

if [ $1 = 'down' ]; then
    xrandr --output DP-4 --brightness 0.12

    if ! iconf -i ultra; then
      xrandr --output HDMI-0 --brightness 1.00
      xrandr --output DVI-D-0 --brightness 0.12
    else
      xrandr --output DP-3 --brightness 1.00
      xrandr --output HDMI-0 --brightness 0.12
    fi
fi

