#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2019 WSO2, Inc. (http://wso2.com)
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

read -p "Do you have a WSO2 Subscription? (Y/N)" -n 1 -r
${ECHO}

if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    read -p "Enter Your WSO2 Username: " WSO2_SUBSCRIPTION_USERNAME
    ${ECHO}
    read -s -p "Enter Your WSO2 Password: " WSO2_SUBSCRIPTION_PASSWORD
    ${ECHO}

    HAS_SUBSCRIPTION=0

    if ! ${GREP} -q "imagePullSecrets" \
    ../apim/wso2apim-deployment.yaml \
    ../apim-analytics/wso2apim-analytics-deployment.yaml; then

        if ! ${SED} -i.bak -e 's|wso2/|docker.wso2.com/|' \
        ../apim/wso2apim-deployment.yaml \
        ../apim-analytics/wso2apim-analytics-deployment.yaml; then
            echoBold "Could not configure to use the Docker image available at WSO2 Private Docker Registry (docker.wso2.com)"
            exit 1
        fi

        case "`uname`" in
            Darwin*)
                if ! ${SED} -i.bak -e '/serviceAccount/a \
                      \      imagePullSecrets:' \
                ../apim/wso2apim-deployment.yaml \
                ../apim-analytics/wso2apim-analytics-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create \"imagePullSecrets:\" attribute"
                    exit 1
                fi

                if ! ${SED} -i.bak -e '/imagePullSecrets/a \
                      \      - name: wso2creds' \
                ../apim/wso2apim-deployment.yaml \
                ../apim-analytics/wso2apim-analytics-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create secret name"
                    exit 1
                fi;;
            *)
                if ! ${SED} -i.bak -e '/serviceAccount/a \      imagePullSecrets:' \
                ../apim/wso2apim-deployment.yaml \
                ../apim-analytics/wso2apim-analytics-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create \"imagePullSecrets:\" attribute"
                    exit 1
                fi

                if ! ${SED} -i.bak -e '/imagePullSecrets/a \      - name: wso2creds' \
                ../apim/wso2apim-deployment.yaml \
                ../apim-analytics/wso2apim-analytics-deployment.yaml; then
                    echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create secret name"
                    exit 1
                fi;;
        esac
    fi
elif [[ ${REPLY} =~ ^[Nn]$ || -z "${REPLY}" ]]; then
    HAS_SUBSCRIPTION=1

    if ! ${SED} -i.bak -e '/imagePullSecrets:/d' -e '/- name: wso2creds/d' \
    ../apim/wso2apim-deployment.yaml \
    ../apim-analytics/wso2apim-analytics-deployment.yaml; then
         echoBold "Failed to remove the Kubernetes Docker image pull secret"
         exit 1
    fi

    if ! ${SED} -i.bak -e 's|docker.wso2.com|wso2|' \
    ../apim/wso2apim-deployment.yaml \
    ../apim-analytics/wso2apim-analytics-deployment.yaml; then
        echoBold "Could not configure to use the WSO2 Docker image available at DockerHub"
        exit 1
    fi
else
    echoBold "You have entered an invalid option."
    exit 1
fi

# remove backed up files
${TEST} -f ../apim/*.bak && rm ../apim/*.bak
${TEST} -f ../apim-analytics/*.bak && rm ../apim-analytics/*.bak

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

echoBold 'Creating ConfigMaps...'
${KUBERNETES_CLIENT} create configmap apim-conf --from-file=../confs/apim/
${KUBERNETES_CLIENT} create configmap apim-conf-datasources --from-file=../confs/apim/datasources/
${KUBERNETES_CLIENT} create configmap apim-analytics-conf-worker --from-file=../confs/apim-analytics/conf/worker/
${KUBERNETES_CLIENT} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

echoBold 'Creating Azure storage classes'
${KUBERNETES_CLIENT} apply -f ../../../azure/rbac.yaml
${KUBERNETES_CLIENT} apply -f ../../../azure/storage-class.yaml
${KUBERNETES_CLIENT} apply -f ../../../azure/mysql-storage-class.yaml

# MySQL
echoBold 'Deploying WSO2 API Manager Databases...'
# ${KUBERNETES_CLIENT} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim-azure.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-service.yaml
sleep 10s

echoBold 'Deploying persistent storage resources...'
# ${KUBERNETES_CLIENT} create -f ../volumes/persistent-volumes.yaml
echoBold 'Deploying WSO2 API Manager Analytics...'
${KUBERNETES_CLIENT} create -f ../apim-analytics/wso2apim-analytics-deployment.yaml
${KUBERNETES_CLIENT} create -f ../apim-analytics/wso2apim-analytics-service.yaml
sleep 200s

echoBold 'Deploying WSO2 API Manager...'
${KUBERNETES_CLIENT} create -f ../apim/wso2apim-volume-claim-azure.yaml
${KUBERNETES_CLIENT} create -f ../apim/wso2apim-deployment.yaml
${KUBERNETES_CLIENT} create -f ../apim/wso2apim-service.yaml
sleep 10s

echoBold 'Deploying Ingresses...'
${KUBERNETES_CLIENT} create -f ../ingresses/wso2apim-ingress.yaml

echoBold 'Finished'
