#!/usr/bin/env bash

kubectl create ns wso2
kubectl config set-context $(kubectl config current-context) --namespace wso2

kubectl create -f ../kubernetes-basics/svcaccount.yaml
#kubectl create -f secrets.yaml

kubectl create -f ../kubernetes-apim-mysql/wso2apim-mysql-conf.yaml
kubectl create -f ../kubernetes-apim-mysql/wso2apim-mysql-service.yaml
kubectl create -f ../kubernetes-apim-mysql/wso2apim-mysql-deployment.yaml

kubectl create -f ../kubernetes-apim-analytics/dashboard/wso2am-pattern-1-analytics-dashboard-conf.yaml
kubectl create -f ../kubernetes-apim-analytics/dashboard/wso2am-pattern-1-analytics-dashboard-service.yaml
kubectl create -f ../kubernetes-apim-analytics/dashboard/wso2am-pattern-1-analytics-dashboard-deployment.yaml

kubectl create -f ../kubernetes-apim-analytics/worker/wso2apim-analytics-worker-conf.yaml
kubectl create -f ../kubernetes-apim-analytics/worker/wso2apim-analytics-worker-service.yaml
kubectl create -f ../kubernetes-apim-analytics/worker/wso2apim-analytics-worker-deployment.yaml

kubectl create -f ../kubernetes-apim/wso2apim-conf.yaml
kubectl create -f ../kubernetes-apim/wso2apim-service.yaml
kubectl create -f ../kubernetes-apim/wso2apim-deployment.yaml


echo "Done"
