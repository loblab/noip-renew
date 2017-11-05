#!/bin/bash
set -e

LOGDIR=/var/log/noip-renew
DSTDIR=/etc/cron.weekly
CRONJOB="47 6    * * 3   root    /etc/cron.weekly/noip-renew.sh"

function install() {
    echo "Install necessary packages..."
    sudo apt -y install chromedriver
    # Debian9 package 'python-selenium' does not work with chromedriver,
    # Install from pip, which is newer
    sudo apt -y install python-pip
    sudo pip install selenium
}

function deploy() {
    echo "Deploy the script (run twice every week)..."
    sudo mkdir -p $LOGDIR
    sudo cp noip-renew.py /usr/local/bin/
    sudo cp noip-renew.sh $DSTDIR
    sudo chmod 700 $DSTDIR/noip-renew.sh
    grep "noip-renew.sh" /etc/crontab || echo "$CRONJOB" | sudo tee -a /etc/crontab
    echo "Done."
    echo "Please confirm the account info in <$DSTDIR/noip-renew.sh>"
    echo "Also check logs in <$LOGDIR> after running the cron job"
}

install
deploy
