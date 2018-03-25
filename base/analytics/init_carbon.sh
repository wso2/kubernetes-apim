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
server_artifact_location=${WSO2_SERVER_HOME}/repository/deployment/server

# Copy artifacts copied to ${USER_HOME}/tmp-server/ directory in the docker image build process
# to ${WSO2_SERVER_HOME}/repository/deployment/server once the persistent volume is attached for the first time
if [[ -d ${USER_HOME}/tmp-server/ ]]; then
   if [[ ! "$(ls -A ${server_artifact_location}/)" ]]; then
      # There are no artifacts under ${WSO2_SERVER_HOME}/repository/deployment/server, copy them
      echo "copying artifacts from ${USER_HOME}/tmp-server/ to ${server_artifact_location}/ ..."
      cp -rf ${USER_HOME}/tmp-server/* ${server_artifact_location}/
   fi
   rm -rf ${USER_HOME}/tmp-server/
fi

# Copy customizations done by user do the CARBON_HOME location
if [[ -d ${USER_HOME}/tmp-carbon/ ]]; then
   echo "copying custom configurations and artifacts from ${USER_HOME}/tmp-carbon/ to ${WSO2_SERVER_HOME}/ ..."
   cp -rf ${USER_HOME}/tmp-carbon/* ${WSO2_SERVER_HOME}/
   rm -rf ${USER_HOME}/tmp-carbon/
fi

# Copy ConfigMaps
# Mount any ConfigMap to ${WSO2_SERVER_HOME}-conf location
if [[ -d ${WSO2_SERVER_HOME}-conf/ ]]; then
   echo "copying config maps from ${WSO2_SERVER_HOME}-conf to ${WSO2_SERVER_HOME}/ ..."
fi

if [ -e ${WSO2_SERVER_HOME}-conf/bin/* ]
 then cp ${WSO2_SERVER_HOME}-conf/bin/* ${WSO2_SERVER_HOME}/bin/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/resources-security ]
 then cp ${WSO2_SERVER_HOME}-conf/resources-security/* ${WSO2_SERVER_HOME}/repository/resources/security/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf ]
 then cp ${WSO2_SERVER_HOME}-conf/conf/* ${WSO2_SERVER_HOME}/repository/conf/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-axis2 ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-axis2/* ${WSO2_SERVER_HOME}/repository/conf/axis2/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-datasources ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-datasources/* ${WSO2_SERVER_HOME}/repository/conf/datasources/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-identity ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-identity/* ${WSO2_SERVER_HOME}/repository/conf/identity/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-tomcat ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-tomcat/* ${WSO2_SERVER_HOME}/repository/conf/tomcat/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-data-bridge ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-data-bridge/* ${WSO2_SERVER_HOME}/repository/conf/data-bridge/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-email ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-email/* ${WSO2_SERVER_HOME}/repository/conf/email/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-etc ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-etc/* ${WSO2_SERVER_HOME}/repository/conf/etc/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-multitenancy ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-multitenancy/* ${WSO2_SERVER_HOME}/repository/conf/multitenancy/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-security ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-security/* ${WSO2_SERVER_HOME}/repository/conf/security/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-analytics ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-analytics/* ${WSO2_SERVER_HOME}/repository/conf/analytics/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-analytics-spark ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-analytics-spark/* ${WSO2_SERVER_HOME}/repository/conf/analytics/spark/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-cep ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-cep/* ${WSO2_SERVER_HOME}/repository/conf/cep/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-cep-domain-template ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-cep-domain-template/* ${WSO2_SERVER_HOME}/repository/conf/cep/domain-template/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-cep-storm ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-cep-storm/* ${WSO2_SERVER_HOME}/repository/conf/cep/storm/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-template-manager ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-template-manager/* ${WSO2_SERVER_HOME}/repository/conf/template-manager/domain-template/
fi

# Overwrite localMemberHost element value in axis2.xml with container ip
export local_docker_ip=$(ip route get 1 | awk '{print $NF;exit}')
export  SPARK_LOCAL_IP=$local_docker_ip
axi2_xml_location=${WSO2_SERVER_HOME}/repository/conf/axis2/axis2.xml
if [[ ! -z ${local_docker_ip} ]]; then
   sed -i "s#<parameter\ name=\"localMemberHost\".*#<parameter\ name=\"localMemberHost\">${local_docker_ip}<\/parameter>#" "${axi2_xml_location}"
   if [[ $? == 0 ]]; then
      echo "successfully updated localMemberHost with ${local_docker_ip}"
   else
      echo "error occurred while updating localMemberHost with ${local_docker_ip}"
   fi
fi

# Start the carbon server
${WSO2_SERVER_HOME}/bin/wso2server.sh
