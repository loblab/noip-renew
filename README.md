# Script to auto renew/confirm noip.com free hosts

[noip.com](https://www.noip.com/) free hosts expire every month. 
This script auto click web pages to renew the hosts,
using Python/Selenium with Chrome headless mode.

- Platform: Debian/Ubuntu Linux, no GUI needed (tested on Debian 9.2)
- Ver: 0.1
- Ref: [Technical explanation for the code (Chinese)](http://www.jianshu.com/p/3c8196175147)
- Updated: 11/5/2017
- Created: 11/4/2017
- Author: loblab

![noip.com hosts](https://raw.githubusercontent.com/loblab/noip-renew/master/screenshot.png)

## Usage

1. Set your noip.com account info in noip-renew.sh,
2. Run setup.sh,
3. Run noip-renew.sh, check result.png (if succeeded) or error.png (if failed)

## Remarks

The script is not designed to renew/update the dynamic DNS recrods.
Check [noip.com document](https://www.noip.com/integrate) for that purpose.
And most wireless routers support noip.com.
You can also check [DNS-O-Matic](https://dnsomatic.com/) to update multiple noip.com DNS recrods.

## History

- 0.1 (11/5/2017) : Supported Debian with Chrome headless.

