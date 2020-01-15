#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2018 WSO2, Inc. (http://wso2.com)
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
GREP=`which grep`
oc=`which oc`
SED=`which sed`


# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of WSO2 Identity Server Openshift resources\n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
    echoBold "--wp | --wso2-password\t\tYour WSO2 password"
    echoBold "--cap | --cluster-admin-password\tOpenshift cluster admin password\n\n"
}

WSO2_SUBSCRIPTION_USERNAME=''
WSO2_SUBSCRIPTION_PASSWORD=''
ADMIN_PASSWORD=''

# capture named arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`

    case ${PARAM} in
        -h | --help)
            usage
            exit 1
            ;;
        --wu | --wso2-username)
            WSO2_SUBSCRIPTION_USERNAME=${VALUE}
            ;;
        --wp | --wso2-password)
            WSO2_SUBSCRIPTION_PASSWORD=${VALUE}
            ;;
        --cap | --cluster-admin-password)
            ADMIN_PASSWORD=${VALUE}
            ;;
        *)
            echoBold "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

# create a new Openshift Project
${oc}  new-project wso2 --description="wso2" --display-name="wso2"

# swith to the created Project
${oc}  project wso2

# create a new service account in 'wso2' Openshift Project
${oc} create serviceaccount wso2svc-account -n wso2
${oc} adm policy add-scc-to-user privileged -n wso2 -z wso2svc-account

# create a Openshift Secret for passing WSO2 Private Docker Registry credentials
${oc} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}

# create Openshift ConfigMaps    
echoBold 'Creating Openshift ConfigMaps...'
# create the APIM Analytics ConfigMaps
${oc} create configmap apim-analytics-conf-worker --from-file=../confs/apim-analytics/
# create the Kubernetes ConfigMaps for API Manager's KeyManager
#${oc} create configmap apim-km-conf --from-file=../confs/apim-km/
#${oc} create configmap apim-km-conf-datasources --from-file=../confs/apim-km/datasources/
# create the Kubernetes ConfigMaps for Identity Server as Key Manager
${oc} create configmap apim-is-as-km-conf --from-file=../confs/apim-is-as-km/
${oc} create configmap apim-is-as-km-conf-datasources --from-file=../confs/apim-is-as-km/datasources/
# create the Kubernetes ConfigMaps for Publisher
${oc} create configmap apim-pub-conf --from-file=../confs/apim-publisher/
${oc} create configmap apim-pub-conf-datasources --from-file=../confs/apim-publisher/datasources/
# create the Kubernetes ConfigMaps for Store
${oc} create configmap apim-store-conf --from-file=../confs/apim-store/
${oc} create configmap apim-store-conf-datasources --from-file=../confs/apim-store/datasources/
# create the Kubernetes ConfigMaps for API Manager's TM
${oc} create configmap apim-tm-1-conf --from-file=../confs/apim-tm-1/
${oc} create configmap apim-tm-1-conf-axis2 --from-file=../confs/apim-tm-1/axis2/
${oc} create configmap apim-tm-1-conf-identity --from-file=../confs/apim-tm-1/identity/
${oc} create configmap apim-tm-2-conf --from-file=../confs/apim-tm-2/
${oc} create configmap apim-tm-2-conf-axis2 --from-file=../confs/apim-tm-2/axis2/
${oc} create configmap apim-tm-2-conf-identity --from-file=../confs/apim-tm-2/identity/
# create the Kubernetes ConfigMaps for API Manager's Gateway
${oc} create configmap apim-gateway-conf --from-file=../confs/apim-gateway/
${oc} create configmap apim-gateway-conf-axis2 --from-file=../confs/apim-gateway/axis2


# Kubernetes MySQL deployment (recommended only for evaluation purposes)
echoBold 'Deploying WSO2 API Manager Databases in MySQL...'
# create a Kubernetes ConfigMap for MySQL database initialization script
${oc} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/
# create Kubernetes persistent storage resources for persisting database data
${oc} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
${oc} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
# create a Kubernetes Deployment for MySQL
${oc} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
sleep 10s
# create a Kubernetes Service for MySQL
${oc} create -f ../extras/rdbms/mysql/mysql-service.yaml
sleep 10s

echoBold 'Creating Kubernetes Services...'
${oc} create -f ../apim-analytics/wso2apim-analytics-service.yaml
#${oc} create -f ../apim-km/wso2apim-km-service.yaml
${oc} create -f ../apim-is-as-km/wso2apim-is-as-km-service.yaml
${oc} create -f ../apim-publisher/wso2apim-publisher-service.yaml
${oc} create -f ../apim-store/wso2apim-store-service.yaml
${oc} create -f ../apim-tm/wso2apim-tm-1-service.yaml
${oc} create -f ../apim-tm/wso2apim-tm-2-service.yaml
${oc} create -f ../apim-gateway/wso2apim-gateway-service.yaml

echoBold 'Deploying Kubernetes persistent storage resources...'
${oc} create -f ../volumes/persistent-volumes.yaml



echoBold '======================================Deploying WSO2 Servers============'

echoBold 'Deploying WSO2 API Manager Analytics...'
${oc} create -f ../apim-analytics/wso2apim-analytics-deployment.yaml

    # echoBold 'Deploying WSO2 API Manager Key Manager...'
    # ${oc} create -f ../apim-km/wso2apim-km-deployment.yaml

#echoBold 'Deploying WSO2 Identity Server as Key Manager...'
${oc} create -f ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml
sleep 3m

echoBold 'Deploying WSO2 API Manager Publisher...'
${oc} create -f ../apim-publisher/wso2apim-publisher-deployment.yaml

echoBold 'Deploying WSO2 API Manager Store...'
${oc} create -f ../apim-store/wso2apim-store-deployment.yaml

echoBold 'Deploying WSO2 API Manager Traffic Manager...'
${oc} create -f ../apim-tm/wso2apim-tm-volume-claim.yaml
${oc} create -f ../apim-tm/wso2apim-tm-1-deployment.yaml
${oc} create -f ../apim-tm/wso2apim-tm-2-deployment.yaml

echoBold 'Deploying WSO2 API Manager Gateway...'
${oc} create -f ../apim-gateway/wso2apim-gateway-volume-claim.yaml
${oc} create -f ../apim-gateway/wso2apim-gateway-deployment.yaml

echoBold 'Deploying Routes...'
${oc} create -f ../routes/wso2apim-gateway-route.yaml
${oc} create -f ../routes/wso2apim-publisher-route.yaml
${oc} create -f ../routes/wso2apim-store-route.yaml
${oc} create -f ../routes/wso2apim-km-route.yaml

sleep 5m

echoBold 'Finished'
echo 'To access the WSO2 API Manager Publisher, try https://wso2apim-publisher/publisher in your browser.'
echo 'To access the WSO2 API Manager Store, try https://wso2apim-store/store in your browser.'

echoBold '========================= DONE =============================='
