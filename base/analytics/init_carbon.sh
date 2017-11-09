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

# Copy ConfigMaps
# Mount any ConfigMap to ${carbon_home}-conf location
if [ -e ${carbon_home}-conf/bin/* ]
 then cp ${carbon_home}-conf/bin/* ${carbon_home}/bin/
fi

if [ -e ${carbon_home}-conf/resources-security ]
 then cp ${carbon_home}-conf/resources-security/* ${carbon_home}/repository/resources/security/
fi

if [ -e ${carbon_home}-conf/conf ]
 then cp ${carbon_home}-conf/conf/* ${carbon_home}/repository/conf/
fi

if [ -e ${carbon_home}-conf/conf-axis2 ]
 then cp ${carbon_home}-conf/conf-axis2/* ${carbon_home}/repository/conf/axis2/
fi

if [ -e ${carbon_home}-conf/conf-datasources ]
 then cp ${carbon_home}-conf/conf-datasources/* ${carbon_home}/repository/conf/datasources/
fi

if [ -e ${carbon_home}-conf/conf-identity ]
 then cp ${carbon_home}-conf/conf-identity/* ${carbon_home}/repository/conf/identity/
fi

if [ -e ${carbon_home}-conf/conf-tomcat ]
 then cp ${carbon_home}-conf/conf-tomcat/* ${carbon_home}/repository/conf/tomcat/
fi

if [ -e ${carbon_home}-conf/conf-data-bridge ]
 then cp ${carbon_home}-conf/conf-data-bridge/* ${carbon_home}/repository/conf/data-bridge/
fi

if [ -e ${carbon_home}-conf/conf-email ]
 then cp ${carbon_home}-conf/conf-email/* ${carbon_home}/repository/conf/email/
fi

if [ -e ${carbon_home}-conf/conf-etc ]
 then cp ${carbon_home}-conf/conf-etc/* ${carbon_home}/repository/conf/etc/
fi

if [ -e ${carbon_home}-conf/conf-multitenancy ]
 then cp ${carbon_home}-conf/conf-multitenancy/* ${carbon_home}/repository/conf/multitenancy/
fi

if [ -e ${carbon_home}-conf/conf-security ]
 then cp ${carbon_home}-conf/conf-security/* ${carbon_home}/repository/conf/security/
fi

if [ -e ${carbon_home}-conf/conf-analytics ]
 then cp ${carbon_home}-conf/conf-analytics/* ${carbon_home}/repository/conf/analytics/
fi

if [ -e ${carbon_home}-conf/conf-analytics-spark ]
 then cp ${carbon_home}-conf/conf-analytics-spark/* ${carbon_home}/repository/conf/analytics/spark/
fi

if [ -e ${carbon_home}-conf/conf-cep ]
 then cp ${carbon_home}-conf/conf-cep/* ${carbon_home}/repository/conf/cep/
fi

if [ -e ${carbon_home}-conf/conf-cep-domain-template ]
 then cp ${carbon_home}-conf/conf-cep-domain-template/* ${carbon_home}/repository/conf/cep/domain-template/
fi

if [ -e ${carbon_home}-conf/conf-cep-storm ]
 then cp ${carbon_home}-conf/conf-cep-storm/* ${carbon_home}/repository/conf/cep/storm/
fi

if [ -e ${carbon_home}-conf/conf-template-manager ]
 then cp ${carbon_home}-conf/conf-template-manager/* ${carbon_home}/repository/conf/template-manager/domain-template/
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

# Start the carbon server.
${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh
