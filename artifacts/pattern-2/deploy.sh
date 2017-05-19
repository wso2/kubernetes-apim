#!/bin/bash

kubectl create -f local-volumes.yaml
kubectl create -f apim-rdbms-deployment.yaml


sleep 5
kubectl create -f wso2am-analytics-pattern-1-deployment.yaml
#kubectl create -f wso2am-pattern-2-deployment.yaml



