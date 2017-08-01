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
# apim volumes and services
oc create -f apim-pubstore-tm-km/wso2apim-tm1-volume-claim.yaml
oc create -f apim-pubstore-tm-km/wso2apim-tm2-volume-claim.yaml

oc create -f apim-gateway/wso2apim-mgt-volume-claim.yaml
oc create -f apim-gateway/wso2apim-worker-volume-claim.yaml

oc create -f apim-pubstore-tm-km/wso2apim-service.yaml
oc create -f apim-pubstore-tm-km/wso2apim-pubstore-tm-km-1-service.yaml
oc create -f apim-pubstore-tm-km/wso2apim-pubstore-tm-km-2-service.yaml

oc create -f apim-gateway/wso2apim-worker-service.yaml
oc create -f apim-gateway/wso2apim-sv-service.yaml
oc create -f apim-gateway/wso2apim-pt-service.yaml
oc create -f apim-gateway/wso2apim-manager-worker-service.yaml

echo 'deploying apim pubstore-tm-km-1 ...'
oc create -f apim-pubstore-tm-km/wso2apim-pubstore-tm-km-1-deployment.yaml

sleep 30s
echo 'deploying apim pubstore-tm-km-2 ...'
oc create -f apim-pubstore-tm-km/wso2apim-pubstore-tm-km-2-deployment.yaml

sleep 1m
echo 'deploying apim manager-worker ...'
oc create -f apim-gateway/wso2apim-manager-worker-deployment.yaml
sleep 30s
echo 'deploying apim worker ...'
oc create -f apim-gateway/wso2apim-worker-deployment.yaml
