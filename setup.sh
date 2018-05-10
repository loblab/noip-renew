#!/bin/bash
set -e

PYTHON=python3
USER=$(whoami)
if [ "$USER" == "root" ]; then
    USER=$1
    if [ -z "$USER" ]; then
        echo "Chrome is safer to run as normal user instead of 'root', so"
        echo "run the script as a normal user (with sudo permission), "
        echo "or specify the user: $0 <user>"
        exit 1
    fi
    HOME=/home/$USER
else
    SUDO=sudo
fi

function config() {
    LOGDIR=/var/log/noip-renew/$USER
    INSTDIR=/usr/local/bin
    INSTEXE=$INSTDIR/noip-renew-$USER
    CRONJOB="45 3    * * 1,3,5   $USER    $INSTEXE $LOGDIR"
}

function install() {
    echo "Install necessary packages..."
    $SUDO apt -y install chromedriver
    # Debian9 package 'python-selenium' does not work with chromedriver,
    # Install from pip, which is newer
    $SUDO apt -y install $PYTHON-pip
    $SUDO $PYTHON -m pip install selenium
}

function deploy() {
    echo "Deploy the script (run twice every week)..."
    $SUDO mkdir -p $LOGDIR
    $SUDO chown $USER $LOGDIR
    $SUDO cp noip-renew.py $INSTDIR
    $SUDO cp noip-renew.sh $INSTEXE
    $SUDO chown $USER $INSTEXE
    $SUDO chmod 700 $INSTEXE
    $SUDO sed -i '/noip-renew/d' /etc/crontab
    echo "$CRONJOB" | $SUDO tee -a /etc/crontab
    echo "Done."
    echo "Please confirm the account info in '$INSTEXE'"
    echo "Also check logs in '$LOGDIR' after running the cron job"
}

config
install
deploy
