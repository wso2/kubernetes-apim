#!/bin/bash
set -x
echo 'scheduling artifact sync cron job & starting cron deamon'
crontab -u ${USER} ${USER_HOME}/artifact-sync-cron && cron \
	&& tailf ${USER_HOME}/cron/logs/artifact-sync-cron.log
