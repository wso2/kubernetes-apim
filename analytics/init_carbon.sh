#!/bin/bash

# Copy the backed up artifacts from ${HOME}/tmp/server/. Copying the initial artifacts to ${HOME}/tmp/server/ is done in the 
# Dockerfile. This is to preserve the initial artifacts in a volume mount (the mounted directory can be empty initially). 
# The artifacts will be copied to the CARBON_HOME/repository/deployment/server location before the server is started.
if [[ -d ${HOME}/tmp/server/ ]]; then
   echo "copying artifacts from ${HOME}/tmp/server/ to ${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/ .."
   cp -rf ${HOME}/tmp/server/* ${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/
   rm -rf ${HOME}/tmp/server/
fi
# Copy customizations done by user do the CARBON_HOME location. 
if [[ -d ${HOME}/tmp/carbon/ ]]; then
   echo "copying custom configurations and artifacts from ${HOME}/tmp/carbon/ to ${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/ .."
   cp -rf ${HOME}/tmp/carbon/* ${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/
   rm -rf ${HOME}/tmp/carbon/
fi
# Start the carbon server.
${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh
