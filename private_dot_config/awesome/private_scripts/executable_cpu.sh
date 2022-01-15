#!/usr/bin/zsh

FIRST_PASS="$(top -n 1 -b | grep Cpu | awk '{usage=100-$8} END {print usage}')"

sleep 0.3

SECOND_PASS="$(top -n 1 -b | grep Cpu | awk '{usage=100-$8} END {print usage}')"

sleep 0.3

THIRD_PASS="$(top -n 1 -b | grep Cpu | awk '{usage=100-$8} END {print usage}')"

RESULT=$(printf %.0f\\n "$(( (FIRST_PASS + SECOND_PASS + THIRD_PASS) / 3 ))")
echo $RESULT
