#!/bin/bash

set -e

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

# overwrite localMemberHost element value in axis2.xml with container ip
export local_docker_ip=$(ip route get 1 | awk '{print $NF;exit}')
axi2_xml_location=${carbon_home}/repository/conf/axis2/axis2.xml
if [[ ! -z ${local_docker_ip} ]]; then
   sed -i "s#<parameter\ name=\"localMemberHost\".*#<parameter\ name=\"localMemberHost\">${local_docker_ip}<\/parameter>#" "${axi2_xml_location}"
   if [[ $? == 0 ]]; then
      echo "Successfully updated localMemberHost with ${local_docker_ip}"
   else
      echo "Error occurred while updating localMemberHost with ${local_docker_ip}"
   fi
fi

# start of analytics specific configs

# export local ip from bin/load-spark-env-vars.sh script
echo 'export SPARK_LOCAL_IP=${local_docker_ip}' >> ${carbon_home}/bin/load-spark-env-vars.sh
# replace hostName of eventSync configuration with local ip
event_processor_xml_file_path=${carbon_home}/repository/conf/event-processor.xml
sed -i "/<eventSync>/,/<\/eventSync>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${local_docker_ip}</hostName>|g" ${event_processor_xml_file_path} \
  && echo "Replaced eventSync/hostName with ${local_docker_ip}"
# replace hostName of management configuration with local ip
sed -i "/<management>/,/<\/management>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${local_docker_ip}</hostName>|g" ${event_processor_xml_file_path} \
  && echo "Replaced management/hostName with ${local_docker_ip}"
# replace hostName of presentation configuration with local ip
sed -i "/<presentation>/,/<\/presentation>/ s|<hostName>[0-9a-z.]\{1,\}</hostName>|<hostName>${local_docker_ip}</hostName>|g" ${event_processor_xml_file_path} \
  && echo "Replaced presentation/hostName with ${local_docker_ip}"

# end of analytics specifc configs

# Start the carbon server.
${carbon_home}/bin/wso2server.sh
