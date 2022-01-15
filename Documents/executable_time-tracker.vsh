#!/usr/bin/env -S v run

import os
import flag
import pg
import time

[table: 'apps']
struct Apps {
	id int [primary]
	duration int
	launches int
	name string [nonull]
	longest_session int
	product_name string
	longest_session_on string
}

db := pg.connect(pg.Config{
	host: '10.0.0.5'
	user: 'postgres'
	password: 'root'
	dbname: 'time_tracker'
}) or {
	println('Failed to connect.\n')
	println(err)
	exit(-1)
}

mut fp := flag.new_flag_parser(os.args)

fp.application('time-tracker-script')
fp.description('a small script to interface with TimeTracker.')
fp.usage_example('[options] <process>')
fp.skip_executable()

display := fp.bool('display', 0, false, 'Display data for process and return')
display_all := fp.bool('display-all', 0, false, 'Display data for process and return')
insert := fp.bool('insert', 0, false, 'Insert process if it is not already tracked')
debug := fp.bool('debug', 0, false, 'Insert process if it is not already tracked')

if !display_all {
	fp.limit_free_args(1, 1) ?
} else {
	app_query := sql db {
		select from Apps
	}

	println('Time data for all apps. \n')
	println(app_query)
	exit(0)
}

args := fp.finalize() or {
	eprintln(err)
	println(fp.usage())
	exit(-1)
}

process := args.join_lines()

if insert {
	all_apps := sql db { select from Apps order by id }

	contains := process in all_apps.map(fn (a Apps) string { return a.name })

	if !contains {
		new_id := all_apps.last().id + 1

		db.exec("INSERT INTO Apps (id, name) VALUES ($new_id, '$process')") or { eprintln('Could not insert into "Apps" for app: ${process}.') }

		if debug { println('App: "$process" has been inserted.') }
	} else {
		if debug { println('App: "$process" already exists.') }
	}
}

app_query := sql db { select from Apps where name == process }

app := app_query.first()

if display {
	println('Time data for app: "$process". \n')
	println(app)
	exit(0)
}

today := fn () string {
	now := time.now()
	return now.str().split(' ')[0]
}

init_launches := app.launches
mut duration := app.duration
longest_session := app.longest_session
mut current_duration := 0
mut launched := false

//main time tracking loop

pid := execute('xdotool search --class $process getwindowpid %1')

for execute('xdotool search --class $process').exit_code == 0 {
	time.sleep(60000 * time.millisecond)

	if launched == false {
		launches := init_launches + 1

		sql db { update Apps set launches = launches where name == process }

		launched = true
	}

	duration++
	current_duration++

	if debug { println('Total Duration: ${duration}.') }
	if debug { println('Current session duration: ${current_duration}.') }

	sql db { update Apps set duration = duration where name == process }

	now_str := today()
	db.exec("CALL upsert_timeline('$process', '$now_str')") or { eprintln('Could not update "Timeline" for app: ${process}.') }
}

println('Session detail for app: "$process" \n')
println('Total Duration: ${duration}.')
println('Current session duration: ${current_duration}.')

if current_duration > longest_session {

	sql db { update Apps set longest_session = current_duration where name == process }

	now_str := today()
	db.exec("UPDATE Apps SET longest_session_on = '$now_str' WHERE name = '$process'") or { eprintln('Could not update app: ${process}.') }

	println('New longest session for "$process" on: "$now_str" with duration: ${current_duration}.')
}

