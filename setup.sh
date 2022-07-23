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
    INSTEXE=$INSTDIR/noip-renew-$USER.sh
    CRONJOB="0 1    * * *   $INSTEXE $LOGDIR"
}

function install() {
    OS=$(hostnamectl | grep -i "operating system")
    echo "$OS"
    case $OS in
        *Arch?Linux*)
            install_arch
            ;;
        *)
            install_debian
            ;;
    esac
    # Debian9 package 'python-selenium' does not work with chromedriver,
    # Install from pip, which is newer
    $SUDO $PYTHON -m pip install selenium
}

function install_arch(){
    $SUDO pacman -Qi cronie > /dev/null ||  $SUDO pacman -S cronie
    $SUDO pacman -Qi python > /dev/null ||  $SUDO pacman -S python
    $SUDO pacman -Qi python-pip > /dev/null ||  $SUDO pacman -S python-pip
    $SUDO pacman -Qi chromium > /dev/null || $SUDO pacman -S chromium
}

function install_debian(){
    echo "Installing necessary packages..."
        deb_arch=$(dpkg --print-architecture)
        if [ "$deb_arch" == "amd64" ]; then
            wget=/usr/bin/wget
            if [ ! -x "$wget" ]; then
              $SUDO apt -y install wget
            fi
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
            wget -O- https://dl.google.com/linux/linux_signing_key.pub |gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg
        fi

        read -p 'Perform apt-get update? (y/n): ' update
        if [ "${update^^}" = "Y" ]
        then
            $SUDO apt-get update
        fi

        $SUDO apt -y install chromium-chromedriver || \
        $SUDO apt -y install chromium-driver || \
        $SUDO apt -y install chromedriver

        $SUDO apt -y install cron 

        PYV=`python3 -c "import sys;t='{v[0]}{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`
        if [[ "$PYV" -lt "36" ]] || ! hash python3;
        then
            echo "This script requires Python version 3.6 or higher. Attempting to install..."
            $SUDO apt-get -y install python3
        fi

        $SUDO apt -y install chromium-browser || \
        $SUDO apt -y install chromium # Update Chromium Browser or script won't work.
        
        $SUDO apt -y install $PYTHON-pip
}

function deploy() {
    echo "Deploying the script..."

    # Remove current installation first.
    if ls $INSTDIR/*noip-renew* 1> /dev/null 2>&1; then
        $SUDO rm $INSTDIR/*noip-renew*
    fi

    $SUDO mkdir -p $LOGDIR
    $SUDO chown $USER $LOGDIR
    $SUDO cp noip-renew.py $INSTDIR
    $SUDO cp noip-renew-skd.sh $INSTDIR
    $SUDO cp noip-renew.sh $INSTEXE
    $SUDO chown $USER $INSTEXE
    $SUDO chown $USER $INSTDIR/noip-renew-skd.sh
    $SUDO chmod 700 $INSTEXE
    noip
    $SUDO crontab -u $USER -l | grep -v '/noip-renew*'  | $SUDO crontab -u $USER -
    ($SUDO crontab -u $USER -l; echo "$CRONJOB") | $SUDO crontab -u $USER -
    $SUDO sed -i 's/USER=/USER='$USER'/1' $INSTDIR/noip-renew-skd.sh
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
    $SUDO rm $INSTDIR/*noip-renew*
    read -p 'Do you want to remove all log files? (y/n): ' clearLogs
    if [ "${clearLogs^^}" = "Y" ]
    then
      $SUDO rm -rf $LOGDIR
    fi
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
            config
            if ls $INSTDIR/*noip-renew* 1> /dev/null 2>&1; then
                uninstall
                echo "Script successfully uninstalled."
            else
                echo "Script is not installed."
            fi
            break
            ;;
        "Exit setup.sh")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
