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

# methods
set -e

function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

echoBold "Deleting the wso2 namespace..."
kubectl delete ns wso2
sleep 50s

echoBold 'Deleting persistent storage resources...'
kubectl delete -f ../volumes/persistent-volumes.yaml
kubectl delete -f rdbms/volumes/persistent-volumes.yaml
sleep 10s

# switch the context to new 'wso2' namespace
kubectl config set-context $(kubectl config current-context) --namespace=default
