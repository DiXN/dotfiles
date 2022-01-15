#!/usr/bin/env bash

set -x

if [ $# -eq 0 ]; then
  echo "No services provided."
  exit 1
fi

DOCKER_LOCATION='/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker'

echo 'Stopping container:'
ssh nas "$DOCKER_LOCATION stop adguard"

FILE_ROOT='/mnt/nas/share/homes/admin/adguard/config/'

ls $FILE_ROOT 2> /dev/null || sshfs nas:/ /mnt/nas

echo 'Looking for cache domains:'

readarray -t cache_domains < <(for service in "${@}"; do
  readarray -t service_domains < <(while read -r line; do
    echo "{ \"domain\": \"${line}\", \"answer\": \"internal.kaltschm.id\" }"
  done < <(curl -L "https://raw.githubusercontent.com/uklans/cache-domains/master/${service}.txt"))

  echo "${service_domains[@]}"
done)

echo 'Looking for local domains:'

readarray -t local_domains < <(while read -r line; do
  echo "{ \"domain\": \"${line}\", \"answer\": \"internal.kaltschm.id\" }"
done < <(ssh nas <<'EOF' | pcregrep -o1 'Host\(`(.*\.kaltschm\.id)'
  $DOCKER_LOCATION ps | awk 'NR > 1 {print $1}' | \
    xargs -I '{}' $DOCKER_LOCATION inspect -f '{{ range $k, $v := .Config.Labels -}} {{ $k }}={{ $v }} {{ end -}}' "{}"
EOF
))

all_domains=("{ \"domain\": \"internal.kaltschm.id\", \"answer\": \"nas.kaltschm.id\" }" "${cache_domains[@]}" "${local_domains[@]}")

GENERATED_YAML=$(yq -y --raw-output ".dns.rewrites = $(jq --slurp '.' < <(echo "${all_domains[@]}"))" "$FILE_ROOT/AdGuardHome.yaml")

echo "$GENERATED_YAML" > "$FILE_ROOT/AdGuardHome.yaml"

umount /mnt/nas

echo 'Starting container: '
ssh nas "$DOCKER_LOCATION start adguard"

