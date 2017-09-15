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

kubectl create configmap apim-analytics-2-bin --from-file=../confs/apim-analytics-1/bin/
kubectl create configmap apim-analytics-2-conf --from-file=../confs/apim-analytics-1/repository/conf/
kubectl create configmap apim-analytics-2-spark --from-file=../confs/apim-analytics-1/repository/conf/analytics/spark/
kubectl create configmap apim-analytics-2-axis2 --from-file=../confs/apim-analytics-1/repository/conf/axis2/
kubectl create configmap apim-analytics-2-datasources --from-file=../confs/apim-analytics-1/repository/conf/datasources/
kubectl create configmap apim-analytics-2-tomcat --from-file=../confs/apim-analytics-1/repository/conf/tomcat/

kubectl create configmap apim-gw-manager-worker-ext-bin --from-file=../confs/apim-gw-manager-worker-ext/bin/
kubectl create configmap apim-gw-manager-worker-ext-conf --from-file=../confs/apim-gw-manager-worker-ext/repository/conf/
kubectl create configmap apim-gw-manager-worker-ext-identity --from-file=../confs/apim-gw-manager-worker-ext/repository/conf/identity/
kubectl create configmap apim-gw-manager-worker-ext-axis2 --from-file=../confs/apim-gw-manager-worker-ext/repository/conf/axis2/
kubectl create configmap apim-gw-manager-worker-ext-datasources --from-file=../confs/apim-gw-manager-worker-ext/repository/conf/datasources/
kubectl create configmap apim-gw-manager-worker-ext-tomcat --from-file=../confs/apim-gw-manager-worker-ext/repository/conf/tomcat/

kubectl create configmap apim-gw-worker-ext-bin --from-file=../confs/apim-gw-worker-ext/bin/
kubectl create configmap apim-gw-worker-ext-conf --from-file=../confs/apim-gw-worker-ext/repository/conf/
kubectl create configmap apim-gw-worker-ext-identity --from-file=../confs/apim-gw-worker-ext/repository/conf/identity/
kubectl create configmap apim-gw-worker-ext-axis2 --from-file=../confs/apim-gw-worker-ext/repository/conf/axis2/
kubectl create configmap apim-gw-worker-ext-datasources --from-file=../confs/apim-gw-worker-ext/repository/conf/datasources/
kubectl create configmap apim-gw-worker-ext-tomcat --from-file=../confs/apim-gw-worker-ext/repository/conf/tomcat/

kubectl create configmap apim-gw-manager-worker-int-bin --from-file=../confs/apim-gw-manager-worker-int/bin/
kubectl create configmap apim-gw-manager-worker-int-conf --from-file=../confs/apim-gw-manager-worker-int/repository/conf/
kubectl create configmap apim-gw-manager-worker-int-identity --from-file=../confs/apim-gw-manager-worker-int/repository/conf/identity/
kubectl create configmap apim-gw-manager-worker-int-axis2 --from-file=../confs/apim-gw-manager-worker-int/repository/conf/axis2/
kubectl create configmap apim-gw-manager-worker-int-datasources --from-file=../confs/apim-gw-manager-worker-int/repository/conf/datasources/
kubectl create configmap apim-gw-manager-worker-int-tomcat --from-file=../confs/apim-gw-manager-worker-int/repository/conf/tomcat/

kubectl create configmap apim-gw-worker-int-bin --from-file=../confs/apim-gw-worker-int/bin/
kubectl create configmap apim-gw-worker-int-conf --from-file=../confs/apim-gw-worker-int/repository/conf/
kubectl create configmap apim-gw-worker-int-identity --from-file=../confs/apim-gw-worker-int/repository/conf/identity/
kubectl create configmap apim-gw-worker-int-axis2 --from-file=../confs/apim-gw-worker-int/repository/conf/axis2/
kubectl create configmap apim-gw-worker-int-datasources --from-file=../confs/apim-gw-worker-int/repository/conf/datasources/
kubectl create configmap apim-gw-worker-int-tomcat --from-file=../confs/apim-gw-worker-int/repository/conf/tomcat/

kubectl create configmap apim-km-bin --from-file=../confs/apim-km/bin/
kubectl create configmap apim-km-conf --from-file=../confs/apim-km/repository/conf/
kubectl create configmap apim-km-identity --from-file=../confs/apim-km/repository/conf/identity/
kubectl create configmap apim-km-axis2 --from-file=../confs/apim-km/repository/conf/axis2/
kubectl create configmap apim-km-datasources --from-file=../confs/apim-km/repository/conf/datasources/
kubectl create configmap apim-km-tomcat --from-file=../confs/apim-km/repository/conf/tomcat/

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

kubectl create -f apim-gateway-ext/wso2apim-worker-service.yaml
kubectl create -f apim-gateway-ext/wso2apim-sv-service.yaml
kubectl create -f apim-gateway-ext/wso2apim-pt-service.yaml
kubectl create -f apim-gateway-ext/wso2apim-manager-worker-service.yaml

kubectl create -f apim-gateway-int/wso2apim-worker-service.yaml
kubectl create -f apim-gateway-int/wso2apim-sv-service.yaml
kubectl create -f apim-gateway-int/wso2apim-pt-service.yaml
kubectl create -f apim-gateway-int/wso2apim-manager-worker-service.yaml

kubectl create -f apim-km/wso2apim-km-service.yaml
kubectl create -f apim-km/wso2apim-key-manager-service.yaml

kubectl create -f apim-pubstore-tm/wso2apim-tm1-volume-claim.yaml
kubectl create -f apim-pubstore-tm/wso2apim-tm2-volume-claim.yaml
kubectl create -f apim-gateway-ext/wso2apim-mgt-volume-claim.yaml
kubectl create -f apim-gateway-ext/wso2apim-worker-volume-claim.yaml
kubectl create -f apim-gateway-int/wso2apim-mgt-volume-claim.yaml
kubectl create -f apim-gateway-int/wso2apim-worker-volume-claim.yaml

#sleep 30s
# analytics
echo 'deploying apim analytics ...'
kubectl create -f apim-analytics/wso2apim-analytics-1-deployment.yaml
#sleep 10s
kubectl create -f apim-analytics/wso2apim-analytics-2-deployment.yaml

# apim
#sleep 1m
echo 'deploying apim pubstore-tm-1 ...'
kubectl create -f apim-pubstore-tm/wso2apim-pubstore-tm-1-deployment.yaml

#sleep 1m
echo 'deploying apim pubstore-tm-2 ...'
kubectl create -f apim-pubstore-tm/wso2apim-pubstore-tm-2-deployment.yaml

#sleep 30s
echo 'deploying apim key manager...'
kubectl create -f apim-km/wso2apim-km-deployment.yaml

#sleep 30s
echo 'deploying apim manager-worker external ...'
kubectl create -f apim-gateway-ext/wso2apim-manager-worker-deployment.yaml
#sleep 30s
echo 'deploying apim worker external ...'
kubectl create -f apim-gateway-ext/wso2apim-worker-deployment.yaml

#sleep 30s
echo 'deploying apim manager-worker internal ...'
kubectl create -f apim-gateway-int/wso2apim-manager-worker-deployment.yaml
#sleep 30s
echo 'deploying apim worker internal ...'
kubectl create -f apim-gateway-int/wso2apim-worker-deployment.yaml

echo 'deploying wso2apim and wso2apim-analytics ingress resources ...'
kubectl create -f ingresses/nginx-default-http-backend.yaml
kubectl create -f ingresses/nginx-ingress-controller.yaml
kubectl create -f ingresses/wso2apim-analytics-ingress.yaml
kubectl create -f ingresses/wso2apim-ingress.yaml