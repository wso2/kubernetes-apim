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
GREP=`which grep`
KUBERNETES_CLIENT=`which kubectl`
SED=`which sed`
TEST=`which test`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

read -p "Do you have a WSO2 Subscription? (y/N)" -n 1 -r
${ECHO}

if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    read -p "Enter Your WSO2 Username: " WSO2_SUBSCRIPTION_USERNAME
    ${ECHO}
    read -s -p "Enter Your WSO2 Password: " WSO2_SUBSCRIPTION_PASSWORD
    ${ECHO}

    HAS_SUBSCRIPTION=0

    if ! ${GREP} -q "imagePullSecrets" \
    ../apim-analytics/wso2apim-analytics-deployment.yaml \
    ../apim-gw/wso2apim-gateway-deployment.yaml \
    ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
    ../apim-km/wso2apim-km-deployment.yaml \
    ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
    ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then

        if ! ${SED} -i.bak -e 's|wso2/|docker.wso2.com/|' \
        ../apim-analytics/wso2apim-analytics-deployment.yaml \
        ../apim-gw/wso2apim-gateway-deployment.yaml \
        ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
        ../apim-km/wso2apim-km-deployment.yaml \
        ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
        ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
            echoBold "Could not configure to use the Docker image available at WSO2 Private Docker Registry (docker.wso2.com)"
            exit 1
        fi

        case "`uname`" in
            Darwin*)
                if ! ${SED} -i.bak -e '/serviceAccount/a \
                      \      imagePullSecrets:' \
                ../apim-analytics/wso2apim-analytics-deployment.yaml \
                ../apim-gw/wso2apim-gateway-deployment.yaml \
                ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
                ../apim-km/wso2apim-km-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create \"imagePullSecrets:\" attribute"
                    exit 1
                fi


                if ! ${SED} -i.bak -e '/imagePullSecrets/a \
                      \      - name: wso2creds' \
                ../apim-analytics/wso2apim-analytics-deployment.yaml \
                ../apim-gw/wso2apim-gateway-deployment.yaml \
                ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
                ../apim-km/wso2apim-km-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create secret name"
                    exit 1
                fi;;

            *)

                if ! ${SED} -i.bak -e '/serviceAccount/a \      imagePullSecrets:' \
                ../apim-analytics/wso2apim-analytics-deployment.yaml \
                ../apim-gw/wso2apim-gateway-deployment.yaml \
                ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
                ../apim-km/wso2apim-km-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create \"imagePullSecrets:\" attribute"
                    exit 1
                fi


                if ! ${SED} -i.bak -e '/imagePullSecrets/a \      - name: wso2creds' \
                ../apim-analytics/wso2apim-analytics-deployment.yaml \
                ../apim-gw/wso2apim-gateway-deployment.yaml \
                ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
                ../apim-km/wso2apim-km-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
                ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create secret name"
                    exit 1
                fi;;
        esac
    fi
elif [[ ${REPLY} =~ ^[Nn]$ || -z "${REPLY}" ]]; then
     HAS_SUBSCRIPTION=1

     if ! ${SED} -i.bak -e '/imagePullSecrets:/d' -e '/- name: wso2creds/d' \
     ../apim-analytics/wso2apim-analytics-deployment.yaml \
     ../apim-gw/wso2apim-gateway-deployment.yaml \
     ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
     ../apim-km/wso2apim-km-deployment.yaml \
     ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
     ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
         echoBold "Failed to remove the Kubernetes Docker image pull secret"
         exit 1
     fi

    if ! ${SED} -i.bak -e 's|docker.wso2.com|wso2|' \
     ../apim-analytics/wso2apim-analytics-deployment.yaml \
     ../apim-gw/wso2apim-gateway-deployment.yaml \
     ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml \
     ../apim-km/wso2apim-km-deployment.yaml \
     ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml \
     ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml; then
        echoBold "Could not configure to use the WSO2 Docker image available at DockerHub"
        exit 1
    fi
else
    echoBold "You have entered an invalid option."
    exit 1
fi

# remove backed up files
${TEST} -f ../apim-analytics/*.bak && rm ../apim-analytics/*.bak
${TEST} -f ../apim-gw/*.bak && rm ../apim-gw/*.bak
${TEST} -f ../apim-is-as-km/*.bak && rm ../apim-is-as-km/*.bak
${TEST} -f ../apim-km/*.bak && rm ../apim-km/*.bak
${TEST} -f ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml.bak && rm ../apim-pub-store-tm/*.bak

# create a new Kubernetes Namespace
${KUBERNETES_CLIENT} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBERNETES_CLIENT} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBERNETES_CLIENT} config set-context $(${KUBERNETES_CLIENT} config current-context) --namespace=wso2

if [[ ${HAS_SUBSCRIPTION} -eq 0 ]]; then
    # create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
    ${KUBERNETES_CLIENT} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}
fi

# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBERNETES_CLIENT} create -f ../../rbac/rbac.yaml

echoBold 'Creating Kubernetes ConfigMaps for WSO2 product configurations...'
# create the APIM Analytics ConfigMaps
${KUBERNETES_CLIENT} create configmap apim-analytics-conf-worker --from-file=../confs/apim-analytics/
# create the Kubernetes ConfigMaps for API Manager's KeyManager
${KUBERNETES_CLIENT} create configmap apim-km-conf --from-file=../confs/apim-km/
# ${KUBERNETES_CLIENT} create configmap apim-km-conf-axis2 --from-file=../confs/apim-km/axis2/
${KUBERNETES_CLIENT} create configmap apim-km-conf-datasources --from-file=../confs/apim-km/datasources/
# create the Kubernetes ConfigMaps for Identity Server as Key Manager
#${KUBERNETES_CLIENT} create configmap apim-is-as-km-conf --from-file=../confs/apim-is-as-km/
#${KUBERNETES_CLIENT} create configmap apim-is-as-km-conf-axis2 --from-file=../confs/apim-is-as-km/axis2/
#${KUBERNETES_CLIENT} create configmap apim-is-as-km-conf-datasources --from-file=../confs/apim-is-as-km/datasources/
# create the Kubernetes ConfigMaps for API Manager's Publisher-Store-TM
${KUBERNETES_CLIENT} create configmap apim-pub-store-tm-1-conf --from-file=../confs/apim-pub-store-tm-1/
${KUBERNETES_CLIENT} create configmap apim-pub-store-tm-1-conf-datasources --from-file=../confs/apim-pub-store-tm-1/datasources/
${KUBERNETES_CLIENT} create configmap apim-pub-store-tm-2-conf --from-file=../confs/apim-pub-store-tm-2/
${KUBERNETES_CLIENT} create configmap apim-pub-store-tm-2-conf-datasources --from-file=../confs/apim-pub-store-tm-2/datasources/
# create the Kubernetes ConfigMaps for API Manager's Gateway
${KUBERNETES_CLIENT} create configmap apim-gateway-conf --from-file=../confs/apim-gateway/
${KUBERNETES_CLIENT} create configmap apim-gateway-conf-axis2 --from-file=../confs/apim-gateway/axis2

# Kubernetes MySQL deployment (recommended only for evaluation purposes)
echoBold 'Deploying WSO2 API Manager Databases in MySQL...'
# create a Kubernetes ConfigMap for MySQL database initialization script
${KUBERNETES_CLIENT} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/
# create Kubernetes persistent storage resources for persisting database data
${KUBERNETES_CLIENT} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
# create a Kubernetes Deployment for MySQL
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
# create a Kubernetes Service for MySQL
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-service.yaml

echoBold 'Creating Kubernetes Services...'
${KUBERNETES_CLIENT} create -f ../apim-analytics/wso2apim-analytics-service.yaml
${KUBERNETES_CLIENT} create -f ../apim-km/wso2apim-km-service.yaml
#${KUBERNETES_CLIENT} create -f ../apim-is-as-km/wso2apim-is-as-km-service.yaml
${KUBERNETES_CLIENT} create -f ../apim-pub-store-tm/wso2apim-pub-store-tm-1-service.yaml
${KUBERNETES_CLIENT} create -f ../apim-pub-store-tm/wso2apim-pub-store-tm-2-service.yaml
${KUBERNETES_CLIENT} create -f ../apim-pub-store-tm/wso2apim-pub-store-tm-service.yaml
${KUBERNETES_CLIENT} create -f ../apim-gw/wso2apim-gateway-service.yaml

echoBold 'Deploying Kubernetes persistent storage resources...'
${KUBERNETES_CLIENT} create -f ../volumes/persistent-volumes.yaml

echoBold 'Deploying WSO2 API Manager Analytics...'
${KUBERNETES_CLIENT} create -f ../apim-analytics/wso2apim-analytics-deployment.yaml

echoBold 'Deploying WSO2 API Manager Key Manager...'
${KUBERNETES_CLIENT} create -f ../apim-km/wso2apim-km-deployment.yaml

#echoBold 'Deploying WSO2 Identity Server as Key Manager...'
#${KUBERNETES_CLIENT} create -f ../apim-is-as-km/wso2apim-is-as-km-volume-claim.yaml
#${KUBERNETES_CLIENT} create -f ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml

echoBold 'Deploying WSO2 API Manager Publisher-Store-Traffic-Manager...'
${KUBERNETES_CLIENT} create -f ../apim-pub-store-tm/wso2apim-pub-store-tm-volume-claim.yaml
${KUBERNETES_CLIENT} create -f ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml
${KUBERNETES_CLIENT} create -f ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml

echoBold 'Deploying WSO2 API Manager Gateway...'
${KUBERNETES_CLIENT} create -f ../apim-gw/wso2apim-gateway-volume-claim.yaml
${KUBERNETES_CLIENT} create -f ../apim-gw/wso2apim-gateway-deployment.yaml

echoBold 'Deploying Kubernetes Ingresses...'
${KUBERNETES_CLIENT} create -f ../ingresses/wso2apim-gateway-ingress.yaml
${KUBERNETES_CLIENT} create -f ../ingresses/wso2apim-ingress.yaml
sleep 5m

echoBold 'Finished'
echo 'To access the WSO2 API Manager Management console, try https://wso2apim/carbon in your browser.'
echo 'To access the WSO2 API Manager Publisher, try https://wso2apim/publisher in your browser.'
echo 'To access the WSO2 API Manager Store, try https://wso2apim/store in your browser.'
