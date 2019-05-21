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

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

read -p "Do you have a WSO2 Subscription?(N/y)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
 read -p "Enter Your WSO2 Username: " WSO2_SUBSCRIPTION_USERNAME
 echo
 read -s -p "Enter Your WSO2 Password: " WSO2_SUBSCRIPTION_PASSWORD
 echo
 HAS_SUBSCRIPTION=0
 if ! grep -q "imagePullSecrets" ../apim/wso2apim-deployment.yaml; then
     if ! sed -i.bak -e 's|wso2/|docker.wso2.com/|' \
     ../apim/wso2apim-deployment.yaml  \
     ../apim-analytics/wso2apim-analytics-deployment.yaml; then
     echo "couldn't configure the docker.wso2.com"
     exit 1
     fi
     if ! sed -i.bak -e '/serviceAccount/a \
    \      imagePullSecrets:' \
     ../apim/wso2apim-deployment.yaml  \
     ../apim-analytics/wso2apim-analytics-deployment.yaml; then
     echo "couldn't configure the \"imagePullSecrets:\""
     exit 1
     fi
      if ! sed -i.bak -e '/imagePullSecrets/a \
    \      - name: wso2creds' \
     ../apim/wso2apim-deployment.yaml  \
     ../apim-analytics/wso2apim-analytics-deployment.yaml; then
     echo "couldn't configure the \"- name: wso2creds\""
     exit 1
     fi
 fi
elif [[ $REPLY =~ ^[Nn]$ || -z "$REPLY" ]]
then
 HAS_SUBSCRIPTION=1
 if ! sed -i.bak -e '/imagePullSecrets:/d' -e '/- name: wso2creds/d' \
     ../apim/wso2apim-deployment.yaml  \
     ../apim-analytics/wso2apim-analytics-deployment.yaml; then
     echo "couldn't configure the \"- name: wso2creds\""
     exit 1
 fi
 if ! sed -i.bak -e 's|docker.wso2.com|wso2|' \
     ../apim/wso2apim-deployment.yaml  \
     ../apim-analytics/wso2apim-analytics-deployment.yaml; then
  echo "couldn't configure the docker.wso2.com"
  exit 1
 fi
else
 echo "Invalid option"
 exit 1
fi

# remove backup files
test -f ../apim/*.bak && rm ../apim/*.bak
test -f ../apim-analytics/*.bak && rm ../apim-analytics/*.bak

# create a new Kubernetes Namespace
${KUBECTL} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBECTL} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBECTL} config set-context $(${KUBECTL} config current-context) --namespace=wso2

# create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
if [ ${HAS_SUBSCRIPTION} -eq 0 ]; then
 ${KUBECTL} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}
fi

# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBECTL} create -f ../../rbac/rbac.yaml

echoBold 'Creating ConfigMaps...'
${KUBECTL} create configmap apim-conf --from-file=../confs/apim/
${KUBECTL} create configmap apim-conf-datasources --from-file=../confs/apim/datasources/
${KUBECTL} create configmap apim-analytics-conf-worker --from-file=../confs/apim-analytics/conf/worker/
${KUBECTL} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

# MySQL
echoBold 'Deploying WSO2 API Manager Databases...'
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${KUBECTL} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-service.yaml
sleep 10s

echoBold 'Deploying persistent storage resources...'
${KUBECTL} create -f ../volumes/persistent-volumes.yaml

echoBold 'Deploying WSO2 API Manager Analytics...'
${KUBECTL} create -f ../apim-analytics/wso2apim-analytics-deployment.yaml
${KUBECTL} create -f ../apim-analytics/wso2apim-analytics-service.yaml
sleep 200s

echoBold 'Deploying WSO2 API Manager...'
${KUBECTL} create -f ../apim/wso2apim-volume-claim.yaml
${KUBECTL} create -f ../apim/wso2apim-deployment.yaml
${KUBECTL} create -f ../apim/wso2apim-service.yaml
sleep 10s

echoBold 'Deploying Ingresses...'
${KUBECTL} create -f ../ingresses/wso2apim-ingress.yaml

echoBold 'Finished'
