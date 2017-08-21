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
oc create -f apim-analytics/wso2apim-analytics-1-service.yaml
oc create -f apim-analytics/wso2apim-analytics-2-service.yaml
oc create -f apim-analytics/wso2apim-analytics-1-deployment.yaml
sleep 30s
oc create -f apim-analytics/wso2apim-analytics-2-deployment.yaml

sleep 1m
# apim volumes and services
oc create -f apim-pubstore-tm/wso2apim-tm1-volume-claim.yaml
oc create -f apim-pubstore-tm/wso2apim-tm2-volume-claim.yaml

oc create -f apim-gateway-int/wso2apim-mgt-volume-claim.yaml
oc create -f apim-gateway-int/wso2apim-worker-volume-claim.yaml

oc create -f apim-gateway-ext/wso2apim-mgt-volume-claim.yaml
oc create -f apim-gateway-ext/wso2apim-worker-volume-claim.yaml

oc create -f apim-pubstore-tm/wso2apim-service.yaml
oc create -f apim-pubstore-tm/wso2apim-pubstore-tm-1-service.yaml
oc create -f apim-pubstore-tm/wso2apim-pubstore-tm-2-service.yaml

oc create -f apim-gateway-int/wso2apim-worker-service.yaml
oc create -f apim-gateway-int/wso2apim-sv-service.yaml
oc create -f apim-gateway-int/wso2apim-pt-service.yaml
oc create -f apim-gateway-int/wso2apim-manager-worker-service.yaml

oc create -f apim-gateway-ext/wso2apim-worker-service.yaml
oc create -f apim-gateway-ext/wso2apim-sv-service.yaml
oc create -f apim-gateway-ext/wso2apim-pt-service.yaml
oc create -f apim-gateway-ext/wso2apim-manager-worker-service.yaml

oc create -f apim-km/wso2apim-km-service.yaml
oc create -f apim-km/wso2apim-key-manager-service.yaml

echo 'deploying apim pubstore-tm-1 ...'
oc create -f apim-pubstore-tm/wso2apim-pubstore-tm-1-deployment.yaml

sleep 1m
echo 'deploying apim pubstore-tm-2 ...'
oc create -f apim-pubstore-tm/wso2apim-pubstore-tm-2-deployment.yaml

sleep 1m
echo 'deploying apim key manager...'
oc create -f apim-km/wso2apim-km-deployment.yaml

sleep 1m
echo 'deploying apim manager-worker internal...'
oc create -f apim-gateway-int/wso2apim-manager-worker-deployment.yaml
sleep 1m
echo 'deploying apim worker internal...'
oc create -f apim-gateway-int/wso2apim-worker-deployment.yaml

sleep 1m
echo 'deploying apim manager-worker external...'
oc create -f apim-gateway-ext/wso2apim-manager-worker-deployment.yaml
sleep 1m
echo 'deploying apim worker external...'
oc create -f apim-gateway-ext/wso2apim-worker-deployment.yaml
