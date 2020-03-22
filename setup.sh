#!/bin/bash
set -e

# Under install ask user if they want to update packages or not! - Do some smart checks to see versions?

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
    CRONJOB="05 0    * * 1,3,5   $USER    $INSTEXE $LOGDIR"
}

function install() {
    echo "Install necessary packages..."
    read -p 'Perform apt-get update? (y/n): ' update
    if [ "${update^^}" = "Y" ]
    then
      $SUDO apt-get update
    fi

    $SUDO apt -y install chromium-chromedriver || \
      $SUDO apt -y install chromium-driver || \
      $SUDO apt -y install chromedriver


    PYV=`python3 -c "import sys;t='{v[0]}{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`

    if [[ "$PYV" -lt "36" ]] || ! hash python3;
    then
      echo "This script requires Python version 3.6 or higher. Attempting to install..."
      $SUDO apt-get install python3
    fi

    # Debian9 package 'python-selenium' does not work with chromedriver,
    # Install from pip, which is newer
    $SUDO apt -y install chromium-browser # Update Chromium Browser or script won't work.
    $SUDO apt -y install $PYTHON-pip
    $SUDO $PYTHON -m pip install selenium
}

function deploy() {
    echo "Deploying the script - Will run on Monday, Wednesday & Friday..."
    $SUDO mkdir -p $LOGDIR
    $SUDO chown $USER $LOGDIR
    $SUDO cp noip-renew.py $INSTDIR
    $SUDO cp noip-renew.sh $INSTEXE
    $SUDO chown $USER $INSTEXE
    $SUDO chmod 700 $INSTEXE
    noip
    $SUDO sed -i '/noip-renew/d' /etc/crontab
    echo "$CRONJOB" | $SUDO tee -a /etc/crontab
    echo "Done."
    echo "Please confirm the No-IP Account details in '$INSTEXE'"
    echo "Check logs in '$LOGDIR' after running the cron job"
}

function noip() {
    echo "Enter your No-IP Account details..."
    read -p 'Username: ' uservar
    read -sp 'Password: ' passvar
    $SUDO sed -i 's/USERNAME=""/USERNAME="$uservar"/1' $INSTEXE
    $SUDO sed -i 's/PASSWORD=""/PASSWORD="$passvar"/1' $INSTEXE
}

function installer() {
    config
    install
    deploy
}

PS3='Select an option: '
options=("Install/Repair Script" "Update noip.com account details" "Uninstall Script" "Exit setup.sh")
echo "No-IP Auto Renewal Script Setup."
select opt in "${options[@]}"
do
    case $opt in
        "Install/Repair Script")
            installer
            break
            ;;
        "Update noip.com account details")
            config
            noip
            echo "noip.com account settings updated."
            break
            ;;
        "Uninstall Script")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Exit setup.sh")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
