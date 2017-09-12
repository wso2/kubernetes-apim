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

# service account
kubectl create serviceaccount wso2svcacct

# databases
echo 'deploying databases ...'
kubectl create -f rdbms/rdbms-persistent-volume-claim.yaml
kubectl create -f rdbms/rdbms-service.yaml
kubectl create -f rdbms/rdbms-deployment.yaml

sleep 20s
# analytics
echo 'deploying apim analytics ...'
kubectl create -f apim-analytics/wso2apim-analytics-service.yaml
kubectl create -f apim-analytics/wso2apim-analytics-1-service.yaml
kubectl create -f apim-analytics/wso2apim-analytics-2-service.yaml
kubectl create -f apim-analytics/wso2apim-analytics-1-deployment.yaml
sleep 30s
kubectl create -f apim-analytics/wso2apim-analytics-2-deployment.yaml

sleep 1m
# apim
kubectl create -f apim/wso2apim-mgt-volume-claim.yaml
kubectl create -f apim/wso2apim-worker-volume-claim.yaml
kubectl create -f apim/wso2apim-service.yaml
kubectl create -f apim/wso2apim-manager-worker-service.yaml
kubectl create -f apim/wso2apim-worker-service.yaml
echo 'deploying apim manager-worker ...'
kubectl create -f apim/wso2apim-manager-worker-deployment.yaml
sleep 1m
echo 'deploying apim worker ...'
kubectl create -f apim/wso2apim-worker-deployment.yaml
