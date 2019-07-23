#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2017 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

ECHO=`which echo`
KUBERNETES_CLIENT=`which kubectl`

# methods
function echoBold () {
    ${ECHO} $'\e[1m'"${1}"$'\e[0m'
}

# delete the created Kubernetes Deployments
${KUBERNETES_CLIENT} delete -f ../apim-gw/wso2apim-gateway-deployment.yaml
sleep 20s
${KUBERNETES_CLIENT} delete -f ../apim-pub-store-tm/wso2apim-pub-store-tm-1-deployment.yaml
${KUBERNETES_CLIENT} delete -f ../apim-pub-store-tm/wso2apim-pub-store-tm-2-deployment.yaml
sleep 20s
#${KUBERNETES_CLIENT} delete -f ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml
${KUBERNETES_CLIENT} delete -f ../apim-km/wso2apim-km-deployment.yaml
${KUBERNETES_CLIENT} delete -f ../apim-analytics/wso2apim-analytics-deployment.yaml
sleep 30s

# delete the created Kubernetes Namespace
${KUBERNETES_CLIENT} delete ns wso2

# persistent storage
echoBold 'Deleting persistent storage...'
${KUBERNETES_CLIENT} delete -f ../volumes/persistent-volumes.yaml
${KUBERNETES_CLIENT} delete -f ../extras/rdbms/volumes/persistent-volumes.yaml
sleep 50s

# switch the context to default namespace
${KUBERNETES_CLIENT} config set-context $(kubectl config current-context) --namespace=default

echoBold 'Finished'
