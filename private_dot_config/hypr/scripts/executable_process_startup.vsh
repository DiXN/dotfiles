#!/usr/bin/env -S v run

import os
import net.unix

mut stream := unix.connect_stream('/tmp/hypr/${os.getenv("HYPRLAND_INSTANCE_SIGNATURE")}/.socket2.sock') or {
	eprintln('cannot connect to socket.')
	exit(-1)
}

mut buf := []u8{}

for {
	stream.read(mut buf) or {
		eprintln('connection broke.')
		stream.close() !
	}

	print(buf)
}

