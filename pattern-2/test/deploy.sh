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

# methods
set -e

function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

# create a new Kubernetes Namespace
kubectl create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
kubectl create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
kubectl config set-context $(kubectl config current-context) --namespace=wso2

#kubectl create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=<username> --docker-password=<password> --docker-email=<email>

# create Kubernetes role and role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
kubectl create --username=admin --password=<cluster-admin-password> -f ../../rbac/rbac.yaml

echoBold 'Creating ConfigMaps...'
kubectl create configmap apim-gateway-conf --from-file=../confs/apim-gateway/
kubectl create configmap apim-gateway-conf-axis2 --from-file=../confs/apim-gateway/axis2/
kubectl create configmap apim-gateway-conf-datasources --from-file=../confs/apim-gateway/datasources/
kubectl create configmap apim-analytics-conf --from-file=../confs/apim-analytics/
kubectl create configmap apim-analytics-conf-datasources --from-file=../confs/apim-analytics/datasources/
kubectl create configmap mysql-dbscripts --from-file=confs/rdbms/mysql/dbscripts/

# MySQL
echoBold 'Deploying WSO2 API Manager Databases...'
kubectl create -f rdbms/mysql/mysql-persistent-volume-claim.yaml
kubectl create -f rdbms/volumes/persistent-volumes.yaml
kubectl create -f rdbms/mysql/mysql-deployment.yaml
kubectl create -f rdbms/mysql/mysql-service.yaml
sleep 10s

echoBold 'Deploying persistent storage resources...'
kubectl create -f ../volumes/persistent-volumes.yaml

echoBold 'Deploying WSO2 API Manager Analytics...'
kubectl create -f ../apim-analytics/wso2apim-analytics-volume-claim.yaml
kubectl create -f ../apim-analytics/wso2apim-analytics-deployment.yaml
kubectl create -f ../apim-analytics/wso2apim-analytics-service.yaml
sleep 200s

echoBold 'Deploying WSO2 API Manager...'
kubectl create -f ../apim/wso2apim-gateway-volume-claim.yaml
kubectl create -f ../apim/wso2apim-gateway-deployment.yaml
kubectl create -f ../apim/wso2apim-gateway-service.yaml
sleep 10s

echoBold 'Deploying Ingresses...'
kubectl create -f ../ingresses/wso2apim-ingress.yaml
kubectl create -f ../ingresses/wso2apim-analytics-ingress.yaml
