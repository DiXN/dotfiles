#!/usr/bin/env -S v run

import time

fn is_process_running(process string, debug bool) bool {
	if debug { println('Checking if "$process" is running.') }

	if getenv('XDG_CURRENT_DESKTOP') == 'Hyprland' {
		return execute('hyprctl clients -j | jq -e \'any(.[]; .class == "$process")\'').exit_code == 0
	} else {
		return execute('xdotool search $process').exit_code == 0
	}
}

mut zone := 0
execute('openrgb -c FFFFFF -m static -b 50')

for {
  time.sleep(1000 * time.millisecond)
  if is_process_running('org.jellyfin.jellyfinmediaplayer', false) {
    if zone != 4 {
      println("Setting rgb for zone 4.")
      execute('openrgb -c FFFFFF -m static -b 10')
    }

    zone = 4
    continue
  }

  res := execute('sensors | awk "/Tccd1/{print \\$2}" | grep -Po "\\d+" | head -n 1')

  temp := res.output.int()
  println("Current temperature: $temp")

  match temp {
    60...69 {
      if zone != 1 {
        println("Setting rgb for zone 1.")
        execute('openrgb -c FFFF00 -m static -b 50')
      }

      zone = 1
    }
    70...90 {
      if zone != 2 {
        println("Setting rgb for zone 2.")
        execute('openrgb -c FF0000 -m static -b 50')
      }

      zone = 2
    }
    else {
      if zone != 0 {
        println("Setting rgb for zone 0.")
        execute('openrgb -c FFFFFF -m static -b 50')
      }

      zone = 0
    }
  }

}

