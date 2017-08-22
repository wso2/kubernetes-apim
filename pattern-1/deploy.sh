#!/bin/bash

oc create -f activemq-service.yaml
oc create -f activemq-deployment.yaml
sleep 5
oc create -f key-manager-service.yaml
oc create -f key-manager-deployment.yaml
sleep 10
oc create -f api-core-service.yaml
sleep 5
oc create -f api-core-deployment.yaml
oc create -f api-gateway-deployment.yaml
