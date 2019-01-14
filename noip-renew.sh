#!/bin/bash

USERNAME="change-the-username"
PASSWORD="change-the-password"
NUM_HOSTS=3 # make sure to change this to the number of configured dynamic hosts on your no-ip account

LOGDIR=$1
PROGDIR=$(dirname $0)

if [ -z "$LOGDIR" ]; then
    $PROGDIR/noip-renew.py "$USERNAME" "$PASSWORD" $NUM_HOSTS 2
else
    cd $LOGDIR
    $PROGDIR/noip-renew.py "$USERNAME" "$PASSWORD" $NUM_HOSTS 0 >> $USERNAME.log
fi

