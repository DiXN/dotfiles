#! /usr/bin/env bash
printf %.0f\\n "$(free | grep Mem | awk '{print $3/$2 * 100.0}')"
