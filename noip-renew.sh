#!/bin/bash

USERNAME="change-the-username"
PASSWORD="change-the-password"
LOGDIR=/var/log/noip-renew

if [ "$(whoami)" == "root" ]; then
    cd /var/log/noip-renew
    /usr/local/bin/noip-renew.py "$USERNAME" "$PASSWORD" 0 >> log
else
    ./noip-renew.py "$USERNAME" "$PASSWORD" 2
fi

