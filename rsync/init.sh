#!/bin/bash
set -e
echo 'scheduling artifact sync cron job'
crontab -u ${USER} ${USER_HOME}/artifact-sync-cron
echo 'starting cron deamon'
cron
tailf ${USER_HOME}/cron/logs/artifact-sync-cron.log
