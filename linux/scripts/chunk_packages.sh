#!/usr/bin/env bash

OFFSET="2"
PACKAGES=$(wc -l "$FILE_IN" | awk '{ print $1 }')

PACKAGES_TOTAL=$(( PACKAGES - OFFSET ))

CHUNK_MULTIPLIER="15"
CHUNKS=$(( PACKAGES_TOTAL / CHUNK_MULTIPLIER + 1 ))

mkdir -p "/tmp/dotfiles/packages"

for i in $(seq $CHUNKS)
do
  RANGE_START=$(( (i - 1) * CHUNK_MULTIPLIER + OFFSET ))
  RANGE_END=$(( i * CHUNK_MULTIPLIER + OFFSET ))
  cat <(echo "$(printf "%s\npacman:" "---")") \
    <(awk "NR > $RANGE_START && NR < $RANGE_END { print \$0 }" "$FILE_IN") > "/tmp/dotfiles/packages/pacman_$i.yaml"
done

