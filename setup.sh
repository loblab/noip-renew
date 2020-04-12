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
    CRONJOB="05 0    * * 1,3,5   $USER    $INSTEXE $LOGDIR"
}

function install() {
    echo "Installing necessary packages..."
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
      $SUDO apt-get -y install python3
    fi

    # Debian9 package 'python-selenium' does not work with chromedriver,
    # Install from pip, which is newer
    $SUDO apt -y install chromium-browser # Update Chromium Browser or script won't work.
    $SUDO apt -y install $PYTHON-pip
    $SUDO $PYTHON -m pip install selenium
}

function deploy() {
    echo "Deploying the script - Runs Mon, Weds & Fri..."
    $SUDO mkdir -p $LOGDIR
    $SUDO chown $USER $LOGDIR
    $SUDO cp noip-renew.py $INSTDIR
    $SUDO cp noip-renew.sh $INSTEXE
    $SUDO chown $USER $INSTEXE
    $SUDO chmod 700 $INSTEXE
    noip
    $SUDO sed -i '/noip-renew/d' /etc/crontab
    echo "$CRONJOB" | $SUDO tee -a /etc/crontab
    echo "Installation Complete."
    echo "To change noip.com account details, please run setup.sh again."
    echo "Logs can be found in '$LOGDIR'"
}

function noip() {
    echo "Enter your No-IP Account details..."
    read -p 'Username: ' uservar
    read -sp 'Password: ' passvar

    passvar=`echo -n $passvar | base64`
    echo

    $SUDO sed -i 's/USERNAME=".*"/USERNAME="'$uservar'"/1' $INSTEXE
    $SUDO sed -i 's/PASSWORD=".*"/PASSWORD="'$passvar'"/1' $INSTEXE
}

function installer() {
    config
    install
    deploy
}

function uninstall() {
    $SUDO sed -i '/noip-renew/d' /etc/crontab
    cd /usr/local/bin
    $SUDO rm *noip-renew*
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
            uninstall
            echo "Script successfully uninstalled."
            break
            ;;
        "Exit setup.sh")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
