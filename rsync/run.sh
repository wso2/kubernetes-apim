#!/bin/bash
set -e
echo 'scheduling artifact sync task ..'
echo "user: ${USER}"
echo "user home: ${USER_HOME}"
echo "remote host: ${REMOTE_HOST}"
echo "remote artifact location in file system: ${REMOTE_ARTIFACTS_LOCATION}"
echo "local artifact sync location: ${LOCAL_ARTIFACTS_LOCATION}"
sleep 2m
while :
do
   rsync --delete -arvOe "ssh -p 8022 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
	${USER}@${REMOTE_HOST}:${REMOTE_ARTIFACTS_LOCATION}/ ${LOCAL_ARTIFACTS_LOCATION}/ >> \
	${USER_HOME}/logs/artifact-sync.log 2>&1     
   sleep 90s
done
