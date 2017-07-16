#!/bin/bash
set -e
echo 'starting cron deamon'
cron
echo 'scheduling artifact sync cron job'
crontab -u ${USER} ${USER_HOME}/artifact-sync-cron
tailf ${USER_HOME}/cron/logs/artifact-sync-cron.log
