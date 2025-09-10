#!/bin/bash

sudo apt update
sudo apt install rsyslog

echo '*.* @${SYSLOG_SERVER_IP}:514     # For UDP
*.* @@${SYSLOG_SERVER_IP}:514    # For TCP ' >> /etc/rsyslog.conf

sudo systemctl restart rsyslog
