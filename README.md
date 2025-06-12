## Description

This code is used to send an hourly reminder to the person applying this software to send the reporting to the state

At the current moment this repo works for both mac and linux systems.

## Setup

1. clone this repository
2. if you do not host your own ntfy server create an account on [ntfy.sh](ntfy.sh)
3. create a new topic for this use case
4. Download the `ntfy` app to your phone and subscribe to your topic (enable push notifications here)
5. setup your .env file (insert the URL you got for your topic)
6. install terminal-notifier (`brew install terminal-notifier`)
7. add a cronjob to your system, calling this script

### Create a cronjob

For unix systems (mac, linux)

1. run `crontab -e`
2. insert your cronjob

Example cronjob for executing a script hourly on weekdays from 08.00 to 16.00 at minute 25:
`25 8-16 * * 1-5 /Users/path-to-your-script/reporting-notifier.sh`

To get the location of your scribt run `pwd -P`
