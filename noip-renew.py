#!/usr/bin/env python3
# Copyright 2017 loblab
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
import time
import sys
import os

class Robot:

    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:64.0) Gecko/20100101 Firefox/64.0"
    LOGIN_URL = "https://www.noip.com/login"
    HOST_URL = "https://my.noip.com/#!/dynamic-dns"

    def __init__(self, debug=0):
        self.debug = debug
        options = webdriver.ChromeOptions()

        #added for Raspbian Buster 4.0+ versions. Check https://www.raspberrypi.org/forums/viewtopic.php?t=258019 for reference.
        options.add_argument("disable-features=VizDisplayCompositor")

        options.add_argument("headless")
        options.add_argument("no-sandbox")  # need when run in docker
        options.add_argument("window-size=1200x800")
        options.add_argument("user-agent={}".format(Robot.USER_AGENT))
        if 'https_proxy' in os.environ:
            options.add_argument("proxy-server=" + os.environ['https_proxy'])
        self.browser = webdriver.Chrome(options=options)
        self.browser.set_page_load_timeout(30)

    def log_msg(self, msg, level=None):
        tstr = time.strftime('%Y/%m/%d %H:%M:%S', time.localtime(time.time()))
        if level is None:
            level = self.debug
        if level > 0:
            print("{} [{}] - {}".format(tstr, self.username, msg))

    def login(self, username, password):
        self.log_msg("Opening {}...".format(Robot.LOGIN_URL))
        self.browser.get(Robot.LOGIN_URL)
        if self.debug > 1:
            self.browser.save_screenshot("debug1.png")

        self.log_msg("Logging in...")
        ele_usr = self.browser.find_element_by_name("username")
        ele_pwd = self.browser.find_element_by_name("password")
        ele_usr.send_keys(username)
        ele_pwd.send_keys(password)
        self.log_msg("user & pass entered")
        form = self.browser.find_element_by_id("clogs")
        self.log_msg(form)
        form.submit()
        if self.debug > 1:
            self.log_msg("debug = " self.debug)
            time.sleep(1)
            self.log_msg("sleep over")
            self.browser.save_screenshot("debug2.png")

    @staticmethod
    def xpath_of_button(cls_name):
        self.log_msg(cls_name)
        return "//button[contains(@class, '%s')]" % cls_name

    def update_hosts(self, num_hosts):
        self.log_msg("Opening {}...".format(Robot.HOST_URL))
        try:
            self.browser.get(Robot.HOST_URL)
        except TimeoutException as e:
            self.browser.save_screenshot("timeout.png")
            self.log_msg("Timeout. Try to ignore")
        invalid = True
        retry = 5
        while retry > 0:
            self.log_msg("reached the retry bit - {}".format(retry))
            time.sleep(1)
            buttons_todo = self.browser.find_elements_by_xpath(Robot.xpath_of_button('btn-confirm'))
            buttons_done = self.browser.find_elements_by_xpath(Robot.xpath_of_button('btn-configure'))
            count = len(buttons_todo)
            total = len(buttons_done)
            self.log_msg("count: {} | total: {}".format(count, total))
            if count + total == num_hosts:
                invalid = False
                break
            self.log_msg("Cannot find the buttons", 2)
            retry -= 1
        if invalid:
            self.log_msg("Invalid page or something wrong. See error.png", 2)
            self.browser.save_screenshot("error.png")
            return False
        if self.debug > 1:
            self.browser.save_screenshot("debug3.png")
        self.log_msg("Hosts to be confirmed: {} / {}".format(count, total))
        for button in buttons_todo:
            button.click()
            time.sleep(1)
        self.browser.save_screenshot("result.png")
        self.log_msg("Confirmed hosts: {} / {}".format(count, total), 2)
        return True

    def run(self, username, password, num_hosts):
        rc = 0
        self.username = username
        self.log_msg("Debug level: {}".format(self.debug))
        try:
            self.login(username, password)
            if not self.update_hosts(num_hosts):
                rc = 3
        except Exception as e:
            self.log_msg(str(e), 2)
            self.browser.save_screenshot("exception.png")
            rc = 2
        finally:
            self.browser.quit()
        return rc

def main(argv=None):
    if argv is None:
        argv = sys.argv
    if len(argv) < 4:
        print("Usage: {} <username> <password> <num-hosts> [<debug-level>]".format(argv[0]))
        return 1

    username = argv[1]
    password = argv[2]
    num_hosts = int(argv[3])
    debug = 1
    if len(argv) > 4:
        debug = int(argv[4])

    robot = Robot(debug)
    return robot.run(username, password, num_hosts)

if __name__ == "__main__":
    sys.exit(main())

