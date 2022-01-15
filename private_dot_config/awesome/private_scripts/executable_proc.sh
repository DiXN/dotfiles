#!/usr/bin/env bash

while IFS= read -r line; do
  echo "$line"
done <<< "$(ps -eo comm:50,%mem,%cpu --sort=-%cpu,-%mem | head -n 6)"

