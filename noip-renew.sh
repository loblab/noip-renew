#!/bin/bash

USERNAME="change-the-username"
PASSWORD="change-the-password"

LOGDIR=$1

if [ -z "$LOGDIR" ]; then
    ./noip-renew.py "$USERNAME" "$PASSWORD" 2
else
    cd $LOGDIR
    noip-renew.py "$USERNAME" "$PASSWORD" 0 >> log
fi

