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
oc create -f apim-publisher/wso2apim-publisher-volume-claim.yaml
oc create -f apim-store/wso2apim-store-volume-claim.yaml

oc create -f apim-tm/wso2apim-tm-1-volume-claim.yaml
oc create -f apim-tm/wso2apim-tm-2-volume-claim.yaml
oc create -f apim-gateway/wso2apim-mgt-volume-claim.yaml
oc create -f apim-gateway/wso2apim-worker-volume-claim.yaml

oc create -f apim-publisher/wso2apim-publisher-local-service.yaml
oc create -f apim-publisher/wso2apim-publisher-service.yaml
oc create -f apim-store/wso2apim-store-local-service.yaml
oc create -f apim-store/wso2apim-store-service.yaml

oc create -f apim-tm/wso2apim-tm-1-service.yaml
oc create -f apim-tm/wso2apim-tm-2-service.yaml
oc create -f apim-gateway/wso2apim-worker-service.yaml
oc create -f apim-gateway/wso2apim-sv-service.yaml
oc create -f apim-gateway/wso2apim-pt-service.yaml
oc create -f apim-gateway/wso2apim-manager-worker-service.yaml

oc create -f apim-km/wso2apim-km-service.yaml
oc create -f apim-km/wso2apim-key-manager-service.yaml

echo 'deploying apim traffic manager ...'
oc create -f apim-tm/wso2apim-tm-1-deployment.yaml
oc create -f apim-tm/wso2apim-tm-2-deployment.yaml

sleep 1m
echo 'deploying apim publisher ...'
oc create -f apim-publisher/wso2apim-publisher-deployment.yaml

sleep 1m
echo 'deploying apim store...'
oc create -f apim-store/wso2apim-store-deployment.yaml

sleep 1m
echo 'deploying apim key manager...'
oc create -f apim-km/wso2apim-km-deployment.yaml

sleep 1m
echo 'deploying apim manager-worker ...'
oc create -f apim-gateway/wso2apim-manager-worker-deployment.yaml

sleep 1m
echo 'deploying apim worker ...'
oc create -f apim-gateway/wso2apim-worker-deployment.yaml
