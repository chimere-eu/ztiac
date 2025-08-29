#!/bin/bash

sudo apt update
sudo apt install rsyslog

sudo mkdir -p /var/log/remote/
echo 'module(load="imudp")   # for UDP
input(type="imudp" port="514")

module(load="imtcp")   # for TCP
input(type="imtcp" port="514")
' >> /etc/rsyslog.conf

sudo systemctl restart rsyslog

