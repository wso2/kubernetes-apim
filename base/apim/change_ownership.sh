#!/bin/bash

set -e

echo 'going to change ownership of <APIM_HOME>/repository/deployment/server/ directory: '
echo "user: ${USER}"
echo "user home: ${USER_HOME}"
echo "carbon server: ${WSO2_SERVER}-${WSO2_SERVER_VERSION}"

/bin/chown -R ${USER} ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/
/bin/chgrp -R root ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/
