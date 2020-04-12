#!/bin/bash

USERNAME=""
PASSWORD=""

LOGDIR=$1
PROGDIR=$(dirname -- $0)

if [ -z "$LOGDIR" ]; then
    $PROGDIR/noip-renew.py "$USERNAME" "$PASSWORD" 2
else
    cd $LOGDIR
    $PROGDIR/noip-renew.py "$USERNAME" "$PASSWORD" 0 >> $USERNAME.log
fi
