#!/bin/bash

# Copy the backed up artifacts from ${HOME}/tmp/server/. Copying the initial artifacts to ${HOME}/tmp/server/ is done in the 
# Dockerfile. This is to preserve the initial artifacts in a volume mount (the mounted directory can be empty initially). 
# The artifacts will be copied to the CARBON_HOME/repository/deployment/server location before the server is started.
carbon_home=${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}
server_artifact_location=${carbon_home}/repository/deployment/server
if [[ -d ${HOME}/tmp/server/ ]]; then
   if [[ ! "$(ls -A ${server_artifact_location}/)" ]]; then
      # There are no artifacts under CARBON_HOME/repository/deployment/server/; copy them.
      echo "copying artifacts from ${HOME}/tmp/server/ to ${server_artifact_location}/ .."
      cp -rf ${HOME}/tmp/server/* ${server_artifact_location}/
   fi
   rm -rf ${HOME}/tmp/server/
fi
# Copy customizations done by user do the CARBON_HOME location. 
if [[ -d ${HOME}/tmp/carbon/ ]]; then
   echo "copying custom configurations and artifacts from ${HOME}/tmp/carbon/ to ${carbon_home}/ .."
   cp -rf ${HOME}/tmp/carbon/* ${carbon_home}/
   rm -rf ${HOME}/tmp/carbon/
fi
# Start the carbon server.
${carbon_home}/bin/wso2server.sh
