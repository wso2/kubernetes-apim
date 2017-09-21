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

oc project wso2

# volumes
oc create -f volumes/persistent-volumes.yaml

# Configuration Maps
oc create configmap apim-analytics-1-bin --from-file=../confs/apim-analytics-1/bin/
oc create configmap apim-analytics-1-conf --from-file=../confs/apim-analytics-1/repository/conf/
oc create configmap apim-analytics-1-spark --from-file=../confs/apim-analytics-1/repository/conf/analytics/spark/
oc create configmap apim-analytics-1-axis2 --from-file=../confs/apim-analytics-1/repository/conf/axis2/
oc create configmap apim-analytics-1-datasources --from-file=../confs/apim-analytics-1/repository/conf/datasources/
oc create configmap apim-analytics-1-tomcat --from-file=../confs/apim-analytics-1/repository/conf/tomcat/

oc create configmap apim-analytics-2-bin --from-file=../confs/apim-analytics-2/bin/
oc create configmap apim-analytics-2-conf --from-file=../confs/apim-analytics-2/repository/conf/
oc create configmap apim-analytics-2-spark --from-file=../confs/apim-analytics-2/repository/conf/analytics/spark/
oc create configmap apim-analytics-2-axis2 --from-file=../confs/apim-analytics-2/repository/conf/axis2/
oc create configmap apim-analytics-2-datasources --from-file=../confs/apim-analytics-2/repository/conf/datasources/
oc create configmap apim-analytics-2-tomcat --from-file=../confs/apim-analytics-2/repository/conf/tomcat/

oc create configmap apim-gw-manager-worker-bin --from-file=../confs/apim-gw-manager-worker/bin/
oc create configmap apim-gw-manager-worker-conf --from-file=../confs/apim-gw-manager-worker/repository/conf/
oc create configmap apim-gw-manager-worker-identity --from-file=../confs/apim-gw-manager-worker/repository/conf/identity/
oc create configmap apim-gw-manager-worker-axis2 --from-file=../confs/apim-gw-manager-worker/repository/conf/axis2/
oc create configmap apim-gw-manager-worker-datasources --from-file=../confs/apim-gw-manager-worker/repository/conf/datasources/
oc create configmap apim-gw-manager-worker-tomcat --from-file=../confs/apim-gw-manager-worker/repository/conf/tomcat/

oc create configmap apim-km-bin --from-file=../confs/apim-km/bin/
oc create configmap apim-km-conf --from-file=../confs/apim-km/repository/conf/
oc create configmap apim-km-identity --from-file=../confs/apim-km/repository/conf/identity/
oc create configmap apim-km-axis2 --from-file=../confs/apim-km/repository/conf/axis2/
oc create configmap apim-km-datasources --from-file=../confs/apim-km/repository/conf/datasources/
oc create configmap apim-km-tomcat --from-file=../confs/apim-km/repository/conf/tomcat/

oc create configmap apim-publisher-bin --from-file=../confs/apim-publisher/bin/
oc create configmap apim-publisher-conf --from-file=../confs/apim-publisher/repository/conf/
oc create configmap apim-publisher-identity --from-file=../confs/apim-publisher/repository/conf/identity/
oc create configmap apim-publisher-axis2 --from-file=../confs/apim-publisher/repository/conf/axis2/
oc create configmap apim-publisher-datasources --from-file=../confs/apim-publisher/repository/conf/datasources/
oc create configmap apim-publisher-tomcat --from-file=../confs/apim-publisher/repository/conf/tomcat/

oc create configmap apim-store-bin --from-file=../confs/apim-store/bin/
oc create configmap apim-store-conf --from-file=../confs/apim-store/repository/conf/
oc create configmap apim-store-identity --from-file=../confs/apim-store/repository/conf/identity/
oc create configmap apim-store-axis2 --from-file=../confs/apim-store/repository/conf/axis2/
oc create configmap apim-store-datasources --from-file=../confs/apim-store/repository/conf/datasources/
oc create configmap apim-store-tomcat --from-file=../confs/apim-store/repository/conf/tomcat/

oc create configmap apim-tm1-bin --from-file=../confs/apim-tm-1/bin/
oc create configmap apim-tm1-conf --from-file=../confs/apim-tm-1/repository/conf/
oc create configmap apim-tm1-identity --from-file=../confs/apim-tm-1/repository/conf/identity/

oc create configmap apim-tm2-bin --from-file=../confs/apim-tm-2/bin/
oc create configmap apim-tm2-conf --from-file=../confs/apim-tm-2/repository/conf/
oc create configmap apim-tm2-identity --from-file=../confs/apim-tm-2/repository/conf/identity/

# databases
echo 'deploying databases ...'
oc create -f rdbms/rdbms-persistent-volume-claim.yaml
oc create -f rdbms/rdbms-service.yaml
oc create -f rdbms/rdbms-deployment.yaml

echo 'deploying services and volume claims ...'
oc create -f apim-analytics/wso2apim-analytics-service.yaml
oc create -f apim-analytics/wso2apim-analytics-1-service.yaml
oc create -f apim-analytics/wso2apim-analytics-2-service.yaml

oc create -f apim-gateway/wso2apim-sv-service.yaml
oc create -f apim-gateway/wso2apim-pt-service.yaml
oc create -f apim-gateway/wso2apim-manager-worker-service.yaml

oc create -f apim-km/wso2apim-km-service.yaml
oc create -f apim-km/wso2apim-key-manager-service.yaml

oc create -f apim-publisher/wso2apim-publisher-local-service.yaml
oc create -f apim-publisher/wso2apim-publisher-service.yaml

oc create -f apim-store/wso2apim-store-local-service.yaml
oc create -f apim-store/wso2apim-store-service.yaml

oc create -f apim-tm/wso2apim-tm-service.yaml
oc create -f apim-tm/wso2apim-tm-1-service.yaml
oc create -f apim-tm/wso2apim-tm-2-service.yaml

oc create -f apim-publisher/wso2apim-publisher-volume-claim.yaml
oc create -f apim-store/wso2apim-store-volume-claim.yaml
oc create -f apim-gateway/wso2apim-mgt-volume-claim.yaml
oc create -f apim-tm/wso2apim-tm-1-volume-claim.yaml

sleep 30s
# analytics
echo 'deploying apim analytics ...'
oc create -f apim-analytics/wso2apim-analytics-1-deployment.yaml
sleep 10s
oc create -f apim-analytics/wso2apim-analytics-2-deployment.yaml

# apim
sleep 30s
echo 'deploying apim traffic manager ...'
oc create -f apim-tm/wso2apim-tm-1-deployment.yaml
oc create -f apim-tm/wso2apim-tm-2-deployment.yaml

echo 'deploying apim key manager...'
oc create -f apim-km/wso2apim-km-deployment.yaml

sleep 1m
echo 'deploying apim publisher ...'
oc create -f apim-publisher/wso2apim-publisher-deployment.yaml

sleep 30s
echo 'deploying apim store...'
oc create -f apim-store/wso2apim-store-deployment.yaml

sleep 30s
echo 'deploying apim manager-worker ...'
oc create -f apim-gateway/wso2apim-manager-worker-deployment.yaml

echo 'deploying wso2apim and wso2apim-analytics routes ...'
oc create -f routes/wso2apim-publisher-route.yaml
oc create -f routes/wso2apim-store-route.yaml
oc create -f routes/wso2apim-gw-route.yaml
oc create -f routes/wso2apim-analytics-route.yaml

