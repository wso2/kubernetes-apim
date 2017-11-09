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
kubectl create  -f volumes/persistent-volumes.yaml

# Configuration Maps
kubectl create  configmap apim-analytics-1-bin --from-file=../confs/apim-analytics-1/bin/
kubectl create  configmap apim-analytics-1-conf --from-file=../confs/apim-analytics-1/repository/conf/
kubectl create  configmap apim-analytics-1-spark --from-file=../confs/apim-analytics-1/repository/conf/analytics/spark/
kubectl create  configmap apim-analytics-1-axis2 --from-file=../confs/apim-analytics-1/repository/conf/axis2/
kubectl create  configmap apim-analytics-1-datasources --from-file=../confs/apim-analytics-1/repository/conf/datasources/
kubectl create  configmap apim-analytics-1-tomcat --from-file=../confs/apim-analytics-1/repository/conf/tomcat/

kubectl create configmap apim-analytics-2-bin --from-file=../confs/apim-analytics-2/bin/
kubectl create configmap apim-analytics-2-conf --from-file=../confs/apim-analytics-2/repository/conf/
kubectl create configmap apim-analytics-2-spark --from-file=../confs/apim-analytics-2/repository/conf/analytics/spark/
kubectl create configmap apim-analytics-2-axis2 --from-file=../confs/apim-analytics-2/repository/conf/axis2/
kubectl create configmap apim-analytics-2-datasources --from-file=../confs/apim-analytics-2/repository/conf/datasources/
kubectl create configmap apim-analytics-2-tomcat --from-file=../confs/apim-analytics-2/repository/conf/tomcat/

kubectl create  configmap apim-gw-manager-worker-bin --from-file=../confs/apim-gw-manager-worker/bin/
kubectl create  configmap apim-gw-manager-worker-conf --from-file=../confs/apim-gw-manager-worker/repository/conf/
kubectl create  configmap apim-gw-manager-worker-identity --from-file=../confs/apim-gw-manager-worker/repository/conf/identity/
kubectl create  configmap apim-gw-manager-worker-axis2 --from-file=../confs/apim-gw-manager-worker/repository/conf/axis2/
kubectl create  configmap apim-gw-manager-worker-datasources --from-file=../confs/apim-gw-manager-worker/repository/conf/datasources/
kubectl create  configmap apim-gw-manager-worker-tomcat --from-file=../confs/apim-gw-manager-worker/repository/conf/tomcat/

kubectl create  configmap apim-km-bin --from-file=../confs/apim-km/bin/
kubectl create  configmap apim-km-conf --from-file=../confs/apim-km/repository/conf/
kubectl create  configmap apim-km-identity --from-file=../confs/apim-km/repository/conf/identity/
kubectl create  configmap apim-km-axis2 --from-file=../confs/apim-km/repository/conf/axis2/
kubectl create  configmap apim-km-datasources --from-file=../confs/apim-km/repository/conf/datasources/
kubectl create  configmap apim-km-tomcat --from-file=../confs/apim-km/repository/conf/tomcat/

kubectl create  configmap apim-publisher-bin --from-file=../confs/apim-publisher/bin/
kubectl create  configmap apim-publisher-conf --from-file=../confs/apim-publisher/repository/conf/
kubectl create  configmap apim-publisher-identity --from-file=../confs/apim-publisher/repository/conf/identity/
kubectl create  configmap apim-publisher-axis2 --from-file=../confs/apim-publisher/repository/conf/axis2/
kubectl create  configmap apim-publisher-datasources --from-file=../confs/apim-publisher/repository/conf/datasources/
kubectl create  configmap apim-publisher-tomcat --from-file=../confs/apim-publisher/repository/conf/tomcat/

kubectl create  configmap apim-store-bin --from-file=../confs/apim-store/bin/
kubectl create  configmap apim-store-conf --from-file=../confs/apim-store/repository/conf/
kubectl create  configmap apim-store-identity --from-file=../confs/apim-store/repository/conf/identity/
kubectl create  configmap apim-store-axis2 --from-file=../confs/apim-store/repository/conf/axis2/
kubectl create  configmap apim-store-datasources --from-file=../confs/apim-store/repository/conf/datasources/
kubectl create  configmap apim-store-tomcat --from-file=../confs/apim-store/repository/conf/tomcat/

kubectl create  configmap apim-tm1-bin --from-file=../confs/apim-tm-1/bin/
kubectl create  configmap apim-tm1-conf --from-file=../confs/apim-tm-1/repository/conf/
kubectl create  configmap apim-tm1-identity --from-file=../confs/apim-tm-1/repository/conf/identity/

kubectl create  configmap apim-tm2-bin --from-file=../confs/apim-tm-2/bin/
kubectl create  configmap apim-tm2-conf --from-file=../confs/apim-tm-2/repository/conf/
kubectl create  configmap apim-tm2-identity --from-file=../confs/apim-tm-2/repository/conf/identity/

# databases
echo 'deploying databases ...'
kubectl create  -f rdbms/rdbms-persistent-volume-claim.yaml
kubectl create  -f rdbms/rdbms-service.yaml
kubectl create  -f rdbms/rdbms-deployment.yaml

echo 'deploying services and volume claims ...'
kubectl create  -f apim-analytics/wso2apim-analytics-service.yaml
kubectl create  -f apim-analytics/wso2apim-analytics-1-service.yaml
kubectl create  -f apim-analytics/wso2apim-analytics-2-service.yaml

kubectl create  -f apim-gateway/wso2apim-sv-service.yaml
kubectl create  -f apim-gateway/wso2apim-pt-service.yaml
kubectl create  -f apim-gateway/wso2apim-manager-worker-service.yaml

kubectl create  -f apim-km/wso2apim-km-service.yaml
kubectl create  -f apim-km/wso2apim-key-manager-service.yaml

kubectl create  -f apim-publisher/wso2apim-publisher-local-service.yaml
kubectl create  -f apim-publisher/wso2apim-publisher-service.yaml

kubectl create  -f apim-store/wso2apim-store-local-service.yaml
kubectl create  -f apim-store/wso2apim-store-service.yaml

kubectl create  -f apim-tm/wso2apim-tm-service.yaml
kubectl create  -f apim-tm/wso2apim-tm-1-service.yaml
kubectl create  -f apim-tm/wso2apim-tm-2-service.yaml

kubectl create  -f apim-publisher/wso2apim-publisher-volume-claim.yaml
kubectl create  -f apim-store/wso2apim-store-volume-claim.yaml
kubectl create  -f apim-gateway/wso2apim-mgt-volume-claim.yaml
kubectl create  -f apim-tm/wso2apim-tm-1-volume-claim.yaml

sleep 30s
# analytics
echo 'deploying apim analytics ...'
kubectl create  -f apim-analytics/wso2apim-analytics-1-deployment.yaml
sleep 10s
kubectl create  -f apim-analytics/wso2apim-analytics-2-deployment.yaml

# apim
sleep 30s
echo 'deploying apim traffic manager ...'
kubectl create  -f apim-tm/wso2apim-tm-1-deployment.yaml
kubectl create  -f apim-tm/wso2apim-tm-2-deployment.yaml

echo 'deploying apim key manager...'
kubectl create  -f apim-km/wso2apim-km-deployment.yaml

sleep 1m
echo 'deploying apim publisher ...'
kubectl create  -f apim-publisher/wso2apim-publisher-deployment.yaml

sleep 30s
echo 'deploying apim store...'
kubectl create  -f apim-store/wso2apim-store-deployment.yaml

sleep 30s
echo 'deploying apim manager-worker ...'
kubectl create  -f apim-gateway/wso2apim-manager-worker-deployment.yaml

echo 'deploying wso2apim and wso2apim-analytics ingress resources ...'
kubectl create -f ingresses/nginx-default-http-backend.yaml
kubectl create -f ingresses/nginx-ingress-controller.yaml
kubectl create -f ingresses/wso2apim-analytics-ingress.yaml
kubectl create -f ingresses/wso2apim-ingress.yaml