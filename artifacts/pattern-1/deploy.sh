#!/bin/bash

kubectl create -f local-volumes.yaml
kubectl create -f mysql-apimdb-deployment.yaml
kubectl create -f mysql-govdb-deployment.yaml
kubectl create -f mysql-userdb-deployment.yaml

sleep 10
kubectl create -f wso2am-default-deployment.yaml


