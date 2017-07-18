#!/bin/bash

oc delete -f activemq-service.yaml
oc delete -f activemq-deployment.yaml
oc delete -f key-manager-service.yaml
oc delete -f key-manager-deployment.yaml
oc delete -f api-core-service.yaml
oc delete -f api-core-deployment.yaml
oc delete -f api-gateway-deployment.yaml
