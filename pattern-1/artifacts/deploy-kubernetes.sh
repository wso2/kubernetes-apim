#!/bin/bash

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
