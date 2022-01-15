#! /usr/bin/env bash
df | grep /dev/  | head -n 1 | awk '{print $5}'
