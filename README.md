# Script to auto renew/confirm noip.com free hosts

[noip.com](https://www.noip.com/) free hosts expire every month.
This script auto clicks web pages to renew the hosts,
using Python/Selenium with Chrome headless mode.

- Platform: Debian/Ubuntu/Raspbian/Arch Linux, no GUI needed (tested on Debian 9.x/10.x/Arch Linux); python 3.6+
- Ver: 1.2
- Ref: [Technical explanation for the code (Chinese)](http://www.jianshu.com/p/3c8196175147)
- Updated: 1/2/2021
- Created: 11/04/2017
- Author: loblab
- Contributor: [IDemixI](https://www.github.com/IDemixI)

![noip.com hosts](https://raw.githubusercontent.com/loblab/noip-renew/master/screenshot.png)

## Usage

1. Clone this repository to the device you will be running it from. (`git clone https://github.com/loblab/noip-renew.git`)
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
my_password='add password here'
my_host_num='add number of hosts here'
debug_lvl=2
docker build -t loblab/selenium:debian .
echo -e "$(crontab -l)"$'\n'"12  3  *  *  1,3,5  docker run --network host loblab/selenium:debian ${my_username} ${my_password} ${my_host_num} ${debug_lvl}" | crontab -
```

## Remarks

The script is not designed to renew/update the dynamic DNS records, though the latest version does have this ability if requested.
Check [noip.com documentation](https://www.noip.com/integrate) for that purpose.
Most wireless routers support noip.com. For more information, check [here](https://www.noip.com/support/knowledgebase/what-devices-support-no-ips-dynamic-dns-update-service/).
You can also check [DNS-O-Matic](https://dnsomatic.com/) to update multiple noip.com DNS records.

If you need notification functionality, please try [IDemixI's branch](https://github.com/IDemixI/noip-renew/tree/notifications).

## History
- 1.2 (01/02/2021): Merged all pull requests in latest months: make it work for updated noip.com site.
- 1.1 (06/05/2020): Fixed error when attempting to update an expired host.
- 1.0 (05/18/2020): Minor fixes to an xpath & a try catch pass to avoid an exception. Also fixed versioning.
- 1.0 (04/16/2020): Catches "Would you like to upgrade?" page & stops script accordingly. Manual intervention still required.
- 0.9 (04/13/2020): Complete refactor of code, more stability & automatic crontab scheduling.
- 0.8 (03/23/2020): Added menu to repair/install/remove script along with ability to update noip.com details.
- 0.7 (03/21/2020): Code tidyup and improved efficiency (Removed number of hosts and automatically get this)
- 0.6 (03/15/2020): Improved support for Raspberry Pi (Raspbian Buster) & Changes to setup script.
- 0.5 (01/05/2020): Support raspberry pi, try different "chromedriver" packages in setup script.
- 0.4 (01/14/2019): Add num_hosts argument, change for button renaming; support user agent.
- 0.3 (05/19/2018): Support Docker, ignore timeout, support proxy, tested on python3.
- 0.2 (11/12/2017): Deploy the script as normal user only. root user with 'no-sandbox' option is not safe for Chrome.
- 0.1 (11/05/2017): Support Debian with Chrome headless.
