#!/usr/bin/bash

ssh nas <<-'EOF'
    cd /share/homes/admin
    echo 'killing redirect...'
    /etc/init.d/Qthttpd.sh stop
    cd /share/homes/admin/htpc
    echo 'starting HTPC...'
    /share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker-compose up -d
    cd /share/homes/admin/lancache
    echo 'starting lancache...'
    /share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker-compose up -d
EOF
