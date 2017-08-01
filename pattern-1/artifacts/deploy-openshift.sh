#!/bin/bash
oc project default

# service account
oc create serviceaccount wso2svcacct
oc adm policy add-scc-to-user anyuid -z wso2svcacct -n default

# databases
echo 'deploying databases ...'
oc create -f rdbms/rdbms-persistent-volume-claim.yaml
oc create -f rdbms/rdbms-service.yaml
oc create -f rdbms/rdbms-deployment.yaml

sleep 20s
# analytics
echo 'deploying apim analytics ...'
oc create -f apim-analytics/wso2apim-analytics-service.yaml
oc create -f apim-analytics/wso2apim-analytics-deployment.yaml

sleep 1m
# apim
oc create -f apim/wso2apim-mgt-volume-claim.yaml
oc create -f apim/wso2apim-worker-volume-claim.yaml
oc create -f apim/wso2apim-service.yaml
oc create -f apim/wso2apim-manager-worker-service.yaml
oc create -f apim/wso2apim-worker-service.yaml
echo 'deploying apim manager-worker ...'
oc create -f apim/wso2apim-manager-worker-deployment.yaml
sleep 1m
echo 'deploying apim worker ...'
oc create -f apim/wso2apim-worker-deployment.yaml
