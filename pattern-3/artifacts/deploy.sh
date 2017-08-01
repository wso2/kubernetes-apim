#!/bin/bash

kubectl create -f local-volumes.yaml
kubectl create -f apim-rdbms-deployment.yaml


sleep 10
kubectl create -f wso2am-pattern-1-deployment.yaml


