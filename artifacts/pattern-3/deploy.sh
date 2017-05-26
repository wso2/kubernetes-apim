#!/bin/bash

kubectl create -f local-volumes.yaml
kubectl create -f apim-rdbms-deployment.yaml


sleep 10
kubectl create -f wso2am-analytics-deployment.yaml
sleep 20
kubectl create -f wso2am-key-manager-deployment.yaml



