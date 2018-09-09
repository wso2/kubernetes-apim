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

function usage () {
    echoBold "This script automates the installation of WSO2 EI Integrator Analytics Kubernetes resources\n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
    echoBold "--wp | --wso2-password\t\tYour WSO2 password"
    echoBold "--cap | --cluster-admin-password\tKubernetes cluster admin password\n\n"
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

# create a new Kubernetes Namespace
${KUBECTL} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBECTL} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBECTL} config set-context $(${KUBECTL} config current-context) --namespace=wso2

# create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
${KUBECTL} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}

# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBECTL} create --username=admin --password=${ADMIN_PASSWORD} -f ../../rbac/rbac.yaml

echoBold 'Creating ConfigMaps...'
# create the APIM Gateway ConfigMaps
${KUBECTL} create configmap apim-gateway-conf --from-file=../confs/apim-gateway/
${KUBECTL} create configmap apim-gateway-conf-axis2 --from-file=../confs/apim-gateway/axis2/
${KUBECTL} create configmap apim-gateway-conf-datasources --from-file=../confs/apim-gateway/datasources/
${KUBECTL} create configmap apim-gateway-conf-identity --from-file=../confs/apim-gateway/identity/
# create the APIM Analytics ConfigMaps
${KUBECTL} create configmap apim-analytics-conf --from-file=../confs/apim-analytics/
${KUBECTL} create configmap apim-analytics-conf-datasources --from-file=../confs/apim-analytics/datasources/
# create the APIM Publisher-Store-Traffic-Manager ConfigMaps
${KUBECTL} create configmap apim-pubstore-tm-1-conf --from-file=../confs/apim-pubstore-tm-1/
${KUBECTL} create configmap apim-pubstore-tm-1-conf-axis2 --from-file=../confs/apim-pubstore-tm-1/axis2/
${KUBECTL} create configmap apim-pubstore-tm-1-conf-datasources --from-file=../confs/apim-pubstore-tm-1/datasources/
${KUBECTL} create configmap apim-pubstore-tm-1-conf-identity --from-file=../confs/apim-pubstore-tm-1/identity/
${KUBECTL} create configmap apim-pubstore-tm-2-conf --from-file=../confs/apim-pubstore-tm-2/
${KUBECTL} create configmap apim-pubstore-tm-2-conf-axis2 --from-file=../confs/apim-pubstore-tm-2/axis2/
${KUBECTL} create configmap apim-pubstore-tm-2-conf-datasources --from-file=../confs/apim-pubstore-tm-2/datasources/
${KUBECTL} create configmap apim-pubstore-tm-2-conf-identity --from-file=../confs/apim-pubstore-tm-2/identity/
# create the APIM KeyManager ConfigMaps
${KUBECTL} create configmap apim-km-conf --from-file=../confs/apim-km/
${KUBECTL} create configmap apim-km-conf-axis2 --from-file=../confs/apim-km/axis2/
${KUBECTL} create configmap apim-km-conf-datasources --from-file=../confs/apim-km/datasources/
${KUBECTL} create configmap apim-km-conf-identity --from-file=../confs/apim-km/identity/

${KUBECTL} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

${KUBECTL} create -f ../apim-pubstore-tm/wso2apim-pubstore-tm-1-service.yaml
${KUBECTL} create -f ../apim-pubstore-tm/wso2apim-pubstore-tm-2-service.yaml
${KUBECTL} create -f ../apim-pubstore-tm/wso2apim-service.yaml
${KUBECTL} create -f ../apim-km/wso2apim-km-service.yaml
${KUBECTL} create -f ../apim-gw/wso2apim-gateway-service.yaml
${KUBECTL} create -f ../apim-analytics/wso2apim-analytics-service.yaml

# MySQL
echoBold 'Deploying WSO2 API Manager Databases...'
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${KUBECTL} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-service.yaml
sleep 30s

echoBold 'Deploying persistent storage resources...'
${KUBECTL} create -f ../volumes/persistent-volumes.yaml

echoBold 'Deploying WSO2 API Manager Analytics...'
${KUBECTL} create -f ../apim-analytics/wso2apim-analytics-volume-claim.yaml
${KUBECTL} create -f ../apim-analytics/wso2apim-analytics-deployment.yaml
sleep 3m

echoBold 'Deploying WSO2 API Manager Publisher-Store-Traffic-Manager...'
${KUBECTL} create -f ../apim-pubstore-tm/wso2apim-pubstore-tm-1-deployment.yaml
sleep 1m
${KUBECTL} create -f ../apim-pubstore-tm/wso2apim-pubstore-tm-2-deployment.yaml
sleep 3m

echoBold 'Deploying WSO2 API Manager Key Manager...'
${KUBECTL} create -f ../apim-km/wso2apim-km-deployment.yaml
sleep 2m

${KUBECTL} create -f ../apim-gw/wso2apim-gateway-volume-claim.yaml
${KUBECTL} create -f ../apim-gw/wso2apim-gateway-deployment.yaml
sleep 2m

echoBold 'Deploying Ingresses...'
${KUBECTL} create -f ../ingresses/wso2apim-gateway-ingress.yaml
${KUBECTL} create -f ../ingresses/wso2apim-ingress.yaml
${KUBECTL} create -f ../ingresses/wso2apim-analytics-ingress.yaml

echoBold 'Finished'
echo 'To access the WSO2 API Manager Management console, try https://wso2apim/carbon in your browser.'
echo 'To access the WSO2 API Manager Publisher, try https://wso2apim/publisher in your browser.'
echo 'To access the WSO2 API Manager Store, try https://wso2apim/store in your browser.'
echo 'To access the WSO2 API Manager Analytics management console, try https://wso2apim-analytics/carbon in your browser.'
