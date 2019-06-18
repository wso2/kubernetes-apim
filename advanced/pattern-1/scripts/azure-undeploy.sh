#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2019 WSO2, Inc. (http://wso2.com)
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

# delete the created Kubernetes Namespace
${KUBERNETES_CLIENT} delete namespace wso2

${KUBERNETES_CLIENT} delete -f ../extras/rdbms/mysql/mysql-persistent-volume-claim-azure.yaml
${KUBERNETES_CLIENT} delete -f ../apim/wso2apim-volume-claim-azure.yaml

echoBold 'Deleting Azure storage classes'
${KUBERNETES_CLIENT} delete -f ../../../azure/rbac.yaml
${KUBERNETES_CLIENT} delete -f ../../../azure/storage-class.yaml
${KUBERNETES_CLIENT} delete -f ../../../azure/mysql-storage-class.yaml
sleep 50s

# switch the context to default namespace
${KUBERNETES_CLIENT} config set-context $(kubectl config current-context) --namespace=default

echoBold 'Finished'
