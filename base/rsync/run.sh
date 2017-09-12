#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2017 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

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
