#!/bin/bash
set -euo pipefail

if [ -z $(adb devices | grep -w 'device') ]
then
    echo 'no device is connected. abort...'
    exit 1
fi

echo 'starting usbaudio ...'
usbaudio &
usbaudio_pid=$!
sleep 3

echo 'starting scrcpy...'
scrcpy -f -S &
scrcpy_pid=$!
sleep 3


while true
do
read -p "1) end scrcpy & usbaudio; 2) restart usbaudio"$'\n' choice
    case $choice in
      1)
         echo 'ending scrcpy session...'
         kill $scrcpy_pid
         kill $usbaudio_pid
         exit 0
      ;;
      2)
         echo 'restarting usbaudio...'
         kill $usbaudio_pid
         usbaudio &
         usbaudio_pid=$!
      ;;
    esac
done

# while kill -0 $scrcpy_pid 2> /dev/null; do
#     sleep 1
# done

# echo 'killing usbaudio...'
# kill $usbaudio_pid

