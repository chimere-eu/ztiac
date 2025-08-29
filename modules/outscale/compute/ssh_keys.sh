#!/bin/bash
home_path=$(getent passwd 1000 | cut -d: -f6 )
cat >> $home_path/.ssh/authorized_keys <<EOL
${SSH_KEYS}
EOL