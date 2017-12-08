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

# set namespace
kubectl config set-context $(kubectl config current-context) --namespace=wso2

# volumes
kubectl create -f volumes/persistent-volumes.yaml

# Configuration Maps
kubectl create configmap apim-analytics-1-bin --from-file=../confs/apim-analytics-1/bin/
kubectl create configmap apim-analytics-1-conf --from-file=../confs/apim-analytics-1/repository/conf/
kubectl create configmap apim-analytics-1-spark --from-file=../confs/apim-analytics-1/repository/conf/analytics/spark/
kubectl create configmap apim-analytics-1-axis2 --from-file=../confs/apim-analytics-1/repository/conf/axis2/
kubectl create configmap apim-analytics-1-datasources --from-file=../confs/apim-analytics-1/repository/conf/datasources/
kubectl create configmap apim-analytics-1-tomcat --from-file=../confs/apim-analytics-1/repository/conf/tomcat/

kubectl create configmap apim-analytics-2-bin --from-file=../confs/apim-analytics-2/bin/
kubectl create configmap apim-analytics-2-conf --from-file=../confs/apim-analytics-2/repository/conf/
kubectl create configmap apim-analytics-2-spark --from-file=../confs/apim-analytics-2/repository/conf/analytics/spark/
kubectl create configmap apim-analytics-2-axis2 --from-file=../confs/apim-analytics-2/repository/conf/axis2/
kubectl create configmap apim-analytics-2-datasources --from-file=../confs/apim-analytics-2/repository/conf/datasources/
kubectl create configmap apim-analytics-2-tomcat --from-file=../confs/apim-analytics-2/repository/conf/tomcat/

kubectl create configmap apim-gw-manager-worker-bin --from-file=../confs/apim-gw-manager-worker/bin/
kubectl create configmap apim-gw-manager-worker-conf --from-file=../confs/apim-gw-manager-worker/repository/conf/
kubectl create configmap apim-gw-manager-worker-identity --from-file=../confs/apim-gw-manager-worker/repository/conf/identity/
kubectl create configmap apim-gw-manager-worker-axis2 --from-file=../confs/apim-gw-manager-worker/repository/conf/axis2/
kubectl create configmap apim-gw-manager-worker-datasources --from-file=../confs/apim-gw-manager-worker/repository/conf/datasources/
kubectl create configmap apim-gw-manager-worker-tomcat --from-file=../confs/apim-gw-manager-worker/repository/conf/tomcat/

# Comment these config maps if you deploying WSO2 Identity Server as Key Manager
kubectl create configmap apim-km-bin --from-file=../confs/apim-km/bin/
kubectl create configmap apim-km-conf --from-file=../confs/apim-km/repository/conf/
kubectl create configmap apim-km-identity --from-file=../confs/apim-km/repository/conf/identity/
kubectl create configmap apim-km-axis2 --from-file=../confs/apim-km/repository/conf/axis2/
kubectl create configmap apim-km-datasources --from-file=../confs/apim-km/repository/conf/datasources/
kubectl create configmap apim-km-tomcat --from-file=../confs/apim-km/repository/conf/tomcat/

# Uncomment the following Config maps to deploy WSO2 Identity Server as Key Manager
#kubectl create configmap apim-is-km-conf --from-file=../confs/apim-is-as-km/repository/conf/
#kubectl create configmap apim-is-km-axis2 --from-file=../confs/apim-is-as-km/repository/conf/axis2/
#kubectl create configmap apim-is-km-datasources --from-file=../confs/apim-is-as-km/repository/conf/datasources/
#kubectl create configmap apim-is-km-tomcat --from-file=../confs/apim-is-as-km/repository/conf/tomcat/

kubectl create configmap apim-pubstore-tm-1-bin --from-file=../confs/apim-pubstore-tm-1/bin/
kubectl create configmap apim-pubstore-tm-1-conf --from-file=../confs/apim-pubstore-tm-1/repository/conf/
kubectl create configmap apim-pubstore-tm-1-identity --from-file=../confs/apim-pubstore-tm-1/repository/conf/identity/
kubectl create configmap apim-pubstore-tm-1-axis2 --from-file=../confs/apim-pubstore-tm-1/repository/conf/axis2/
kubectl create configmap apim-pubstore-tm-1-datasources --from-file=../confs/apim-pubstore-tm-1/repository/conf/datasources/
kubectl create configmap apim-pubstore-tm-1-tomcat --from-file=../confs/apim-pubstore-tm-1/repository/conf/tomcat/

kubectl create configmap apim-pubstore-tm-2-bin --from-file=../confs/apim-pubstore-tm-2/bin/
kubectl create configmap apim-pubstore-tm-2-conf --from-file=../confs/apim-pubstore-tm-2/repository/conf/
kubectl create configmap apim-pubstore-tm-2-identity --from-file=../confs/apim-pubstore-tm-2/repository/conf/identity/
kubectl create configmap apim-pubstore-tm-2-axis2 --from-file=../confs/apim-pubstore-tm-2/repository/conf/axis2/
kubectl create configmap apim-pubstore-tm-2-datasources --from-file=../confs/apim-pubstore-tm-2/repository/conf/datasources/
kubectl create configmap apim-pubstore-tm-2-tomcat --from-file=../confs/apim-pubstore-tm-2/repository/conf/tomcat/

# databases
echo 'deploying databases ...'
kubectl create -f rdbms/rdbms-persistent-volume-claim.yaml
kubectl create -f rdbms/rdbms-service.yaml
kubectl create -f rdbms/rdbms-deployment.yaml

echo 'deploying services and volume claims ...'
kubectl create -f apim-analytics/wso2apim-analytics-service.yaml
kubectl create -f apim-analytics/wso2apim-analytics-1-service.yaml
kubectl create -f apim-analytics/wso2apim-analytics-2-service.yaml

kubectl create -f apim-pubstore-tm/wso2apim-service.yaml
kubectl create -f apim-pubstore-tm/wso2apim-pubstore-tm-1-service.yaml
kubectl create -f apim-pubstore-tm/wso2apim-pubstore-tm-2-service.yaml

kubectl create -f apim-gateway/wso2apim-sv-service.yaml
kubectl create -f apim-gateway/wso2apim-pt-service.yaml
kubectl create -f apim-gateway/wso2apim-manager-worker-service.yaml

# Comment these services if you deploying WSO2 Identity Server as Key Manager
kubectl create -f apim-km/wso2apim-km-service.yaml
kubectl create -f apim-km/wso2apim-key-manager-service.yaml

# Uncomment the following services to deploy WSO2 Identity Server as Key Manager
#kubectl create -f apim-is-as-km/wso2apim-is-as-km-service.yaml
#kubectl create -f apim-is-as-km/wso2apim-is-as-key-manager-service.yaml
#kubectl create -f apim-is-as-km/wso2apim-is-km-volume-claim.yaml

kubectl create -f apim-pubstore-tm/wso2apim-tm1-volume-claim.yaml
kubectl create -f apim-gateway/wso2apim-mgt-volume-claim.yaml

sleep 30s
# analytics
echo 'deploying apim analytics ...'
kubectl create -f apim-analytics/wso2apim-analytics-1-deployment.yaml
sleep 10s
kubectl create -f apim-analytics/wso2apim-analytics-2-deployment.yaml

# apim
sleep 1m
echo 'deploying apim pubstore-tm-1 ...'
kubectl create -f apim-pubstore-tm/wso2apim-pubstore-tm-1-deployment.yaml

sleep 1m
echo 'deploying apim pubstore-tm-2 ...'
kubectl create -f apim-pubstore-tm/wso2apim-pubstore-tm-2-deployment.yaml

sleep 30s
echo 'deploying apim key manager...'
# Comment this deployment if you deploying WSO2 Identity Server as Key Manager
kubectl create -f apim-km/wso2apim-km-deployment.yaml

# Uncomment the following deployment to deploy WSO2 Identity Server as Key Manager
# kubectl create -f apim-is-as-km/wso2apim-is-as-km-deployment.yaml

sleep 30s
echo 'deploying apim manager-worker ...'
kubectl create -f apim-gateway/wso2apim-manager-worker-deployment.yaml

echo 'deploying wso2apim and wso2apim-analytics ingresses ...'
kubectl create -f ingresses/nginx-default-http-backend.yaml
kubectl create -f ingresses/nginx-ingress-controller.yaml
kubectl create -f ingresses/wso2apim-analytics-ingress.yaml
kubectl create -f ingresses/wso2apim-ingress.yaml