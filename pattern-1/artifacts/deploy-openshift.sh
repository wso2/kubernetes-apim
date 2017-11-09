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

oc create configmap apim-manager-worker-bin --from-file=../confs/apim-manager-worker/bin/
oc create configmap apim-manager-worker-conf --from-file=../confs/apim-manager-worker/repository/conf/
oc create configmap apim-manager-worker-identity --from-file=../confs/apim-manager-worker/repository/conf/identity/
oc create configmap apim-manager-worker-axis2 --from-file=../confs/apim-manager-worker/repository/conf/axis2/
oc create configmap apim-manager-worker-datasources --from-file=../confs/apim-manager-worker/repository/conf/datasources/
oc create configmap apim-manager-worker-tomcat --from-file=../confs/apim-manager-worker/repository/conf/tomcat/

oc create configmap apim-worker-bin --from-file=../confs/apim-worker/bin/
oc create configmap apim-worker-conf --from-file=../confs/apim-worker/repository/conf/
oc create configmap apim-worker-identity --from-file=../confs/apim-worker/repository/conf/identity/
oc create configmap apim-worker-axis2 --from-file=../confs/apim-worker/repository/conf/axis2/
oc create configmap apim-worker-datasources --from-file=../confs/apim-worker/repository/conf/datasources/
oc create configmap apim-worker-tomcat --from-file=../confs/apim-worker/repository/conf/tomcat/

# databases
echo 'deploying databases ...'
oc create -f rdbms/rdbms-persistent-volume-claim.yaml
oc create -f rdbms/rdbms-service.yaml
oc create -f rdbms/rdbms-deployment.yaml

echo 'deploying services and volume claims ...'
oc create -f apim-analytics/wso2apim-analytics-service.yaml
oc create -f apim-analytics/wso2apim-analytics-1-service.yaml
oc create -f apim-analytics/wso2apim-analytics-2-service.yaml
oc create -f apim/wso2apim-service.yaml
oc create -f apim/wso2apim-manager-worker-service.yaml
oc create -f apim/wso2apim-worker-service.yaml
oc create -f apim/wso2apim-mgt-volume-claim.yaml

sleep 30s
# analytics
echo 'deploying apim analytics ...'
oc create -f apim-analytics/wso2apim-analytics-1-deployment.yaml
sleep 10s
oc create -f apim-analytics/wso2apim-analytics-2-deployment.yaml

sleep 1m
# apim
echo 'deploying apim manager-worker ...'
oc create -f apim/wso2apim-manager-worker-deployment.yaml
sleep 1m
echo 'deploying apim worker ...'
oc create -f apim/wso2apim-worker-deployment.yaml

echo 'deploying wso2apim and wso2apim-analytics routes ...'
oc create -f routes/wso2apim-route.yaml
oc create -f routes/wso2apim-gw-route.yaml
oc create -f routes/wso2apim-analytics-route.yaml