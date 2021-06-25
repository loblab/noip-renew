#!/bin/bash
USER=
SUDO=sudo
LOGDIR=/var/log/noip-renew/$USER
INSTDIR=/usr/local/bin
INSTEXE=$INSTDIR/noip-renew-$USER
CRONJOB="30 0 * * *   $USER    ${INSTEXE}.sh $LOGDIR"
NEWCJOB="30 0 $1 $2 *   $USER    ${INSTEXE}.sh $LOGDIR"
$SUDO crontab -u $USER -l | grep -v '/noip-renew*'  | $SUDO crontab -u $USER -
if [[ $3 = "True" ]]; then
    ($SUDO crontab -u $USER -l; echo "$NEWCJOB") | $SUDO crontab -u $USER -
else
    ($SUDO crontab -u $USER -l; echo "$CRONJOB") | $SUDO crontab -u $USER -
fi

exit 0
