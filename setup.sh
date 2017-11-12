#!/bin/bash
set -e

LOGDIR=/var/log/noip-renew
DSTFILE=/etc/cron.weekly/noip-renew
CRONJOB="45 6    * * 3   root    $DSTFILE"
[ "$(whoami)" == "root" ] || SUDO=sudo

function install() {
    echo "Install necessary packages..."
    $SUDO apt -y install chromedriver
    # Debian9 package 'python-selenium' does not work with chromedriver,
    # Install from pip, which is newer
    $SUDO apt -y install python-pip
    $SUDO pip install selenium
}

function deploy() {
    echo "Deploy the script (run twice every week)..."
    $SUDO mkdir -p $LOGDIR
    $SUDO cp noip-renew.py /usr/local/bin/
    $SUDO cp noip-renew.sh $DSTFILE
    $SUDO chmod 700 $DSTFILE
    $SUDO sed -i '/noip-renew/d' /etc/crontab
    echo "$CRONJOB" | $SUDO tee -a /etc/crontab
    echo "Done."
    echo "Please confirm the account info in '$DSTFILE'"
    echo "Also check logs in '$LOGDIR' after running the cron job"
}

install
deploy
