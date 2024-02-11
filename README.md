[![Docker Image CI](https://github.com/neothematrix/noip-renew/actions/workflows/docker-image.yml/badge.svg)](https://github.com/neothematrix/noip-renew/actions/workflows/docker-image.yml)

# Script to auto renew/confirm noip.com free hosts

[noip.com](https://www.noip.com/) free hosts expire every month.
This script auto clicks web pages to renew the hosts,
using Python/Selenium with Chrome headless mode.

NOTE: this is an up-to-date fork of loblab/noip-renew repository as it seems it's not anymore actively developed, I'll try to keep this fork up to date and working as much as possible. Feel free to contribute!

- Platform: Debian/Ubuntu/Raspbian/Arch Linux, no GUI needed (tested on Debian 9.x/10.x/11.x/Arch Linux); python 3.5+
- Chrome webdriver - tested up to version 120.0.6099.102-rpt1
- Selenium - v.3.x (python 3.5+); v. 4.0.0 (python 3.7+); v.4.10.0 and above (python 3.8+); Tested up to v. 4.17.2
- Ref: [Technical explanation for the code (Chinese)](http://www.jianshu.com/p/3c8196175147)
- Created: 11/04/2017
- Original Author: loblab
- Fork Mantainer: neothematrix
- Contributors: [Angel0ffDeath](https://github.com/Angel0ffDeath), [benyjr](https://github.com/benyjr)

![noip.com hosts](https://raw.githubusercontent.com/loblab/noip-renew/master/screenshot.png)

## Prerequisites

ChromeDriver is required for the script to interface with noip.com from within the script.
ChromeDriver must be maintained to match the installed version of Chrome.
There is no automated repository that provides ChromeDriver package beyond Ubuntu 18 LTS.
Installing Chromium via Snap and then linking chromedriver to /usr/bin/chromedriver should keep chromediver sufficiently up to date without manual intervention

## Usage

1. Clone this repository to the device you will be running it from. (`git clone https://github.com/neothematrix/noip-renew.git`)
2. Run setup.sh and set your noip.com account information,
3. Run noip-renew-USERNAME command.

Check confirmed records from multiple log files:

``` bash
grep -h Confirmed *.log | grep -v ": 0" | sort
```
## Usage with Docker

For docker users, run the following:
```sh
my_username='add username here'
my_password='add base64 encoded password here'
debug_lvl=2
echo -e "$(crontab -l)"$'\n'"12  3  *  *  1,3,5  docker run --rm --network host moebiuss/noip-renew ${my_username} ${my_password} ${debug_lvl}" | crontab -
```
NOTE: with newer versions of ChromeDriver (>v99) you might need to increase the shm size of the container otherwise ChromeDriver will crash and throw an exception. To do it, you can just add the "--shm-size="512m" flag to the docker run command.

## Remarks

The script is not designed to renew/update the dynamic DNS records, but only to renew the hostnames expiring every 30 days due to the free tier.
Check [noip.com documentation](https://www.noip.com/integrate) for that purpose.
Most wireless routers support noip.com. For more information, check [here](https://www.noip.com/support/knowledgebase/what-devices-support-no-ips-dynamic-dns-update-service/).
You can also check [DNS-O-Matic](https://dnsomatic.com/) to update multiple noip.com DNS records.
