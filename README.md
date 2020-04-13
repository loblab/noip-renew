# Script to auto renew/confirm noip.com free hosts

[noip.com](https://www.noip.com/) free hosts expire every month.
This script auto click web pages to renew the hosts,
using Python/Selenium with Chrome headless mode.

- Platform: Debian/Ubuntu/Raspbian Linux, no GUI needed (tested on Debian 9.x/10.x); python 2.x/3.x
- Ver: 0.9
- Ref: [Technical explanation for the code (Chinese)](http://www.jianshu.com/p/3c8196175147)
- Updated: 04/13/2020
- Created: 11/04/2017
- Author: loblab
- Contributor: IDemixI

![noip.com hosts](https://raw.githubusercontent.com/loblab/noip-renew/master/screenshot.png)

## Usage

1. Run setup.sh and set your noip.com account information,
2. Run noip-renew.sh, check results.png (if succeeded) or error.png (if failed)

For docker users, check Dockerfile, docker-compose.yml, crontab-docker-host.

Check confirmed records from multiple log files:

``` bash
grep -h Confirmed *.log | grep -v ": 0" | sort
```

## Remarks

The script is not designed to renew/update the dynamic DNS records, though the latest version does have this ability if requested.
Check [noip.com documentation](https://www.noip.com/integrate) for that purpose.
Most wireless routers support noip.com. For more information, check [here](https://www.noip.com/support/knowledgebase/what-devices-support-no-ips-dynamic-dns-update-service/).
You can also check [DNS-O-Matic](https://dnsomatic.com/) to update multiple noip.com DNS records.

## History

- 0.9 (04/13/2020): Complete refactor of code, more stability & automatic crontab scheduling.
- 0.8 (03/23/2020): Added menu to repair/install/remove script along with ability to update noip.com details.
- 0.7 (03/21/2020): Code tidyup and improved efficiency (Removed number of hosts and automatically get this)
- 0.6 (03/15/2020): Improved support for Raspberry Pi (Raspbian Buster) & Changes to setup script.
- 0.5 (01/05/2020): Support raspberry pi, try different "chromedriver" packages in setup script.
- 0.4 (01/14/2019): Add num_hosts argument, change for button renaming; support user agent.
- 0.3 (05/19/2018): Support Docker, ignore timeout, support proxy, tested on python3.
- 0.2 (11/12/2017): Deploy the script as normal user only. root user with 'no-sandbox' option is not safe for Chrome.
- 0.1 (11/05/2017): Support Debian with Chrome headless.
