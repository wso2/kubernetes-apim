#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
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

export product_name=${PWD##*/}

function echoDim () {
    if [ -z "$2" ]; then
        echo $'\e[2m'"${1}"$'\e[0m'
    else
        echo -n $'\e[2m'"${1}"$'\e[0m'
    fi
}

function echoError () {
    echo $'\e[1;31m'"${1}"$'\e[0m'
}

function echoSuccess () {
    echo $'\e[1;32m'"${1}"$'\e[0m'
}

function echoDot () {
    echoDim "." "append"
}

function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

function askBold () {
    echo -n $'\e[1m'"${1}"$'\e[0m'
}

function validateKubeCtlConfig() {
    {
        kubectl get nodes > /dev/null 2>&1
    } || {
        echoError "kubectl doesn't seem to work. Are Kubernetes Master details correctly configured?"
        exit 1
    }
}

function getKubeNodes() {
    # kubectl get nodes | tail -1 | awk '{print $1}'
    kubectl get nodes | awk '{if (NR!=1) print $1}'
}

function getKubeNodeIP() {
    IFS=$','
    node_ip=$(kubectl get node $1 -o template --template='{{range.status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{end}}{{end}}')
    if [ -z $node_ip ]; then
      echo $(kubectl get node $1 -o template --template='{{range.status.addresses}}{{if eq .type "InternalIP"}}{{.address}}{{end}}{{end}}')
    else
      echo $node_ip
    fi
}

# Deploy using default profile
function default {
  #bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "default" && \
  #bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "default" && \
  bash "${common_scripts_folder}/wait-until-server-starts.sh" "default" "${1}"
}

function showUsageAndExitDistributed () {
    echoBold "Usage: ./deploy.sh [OPTIONS]"
    echo
    echo "Deploy Replication Controllers and Services on Kubernetes for $(echo $product_name | awk '{print toupper($0)}')"
    echo

    echoBold "Options:"
    echo
    echo -e " \t-d  - [OPTIONAL] Deploy distributed pattern"
    echo -e " \t-h  - Show usage"
    echo

    echoBold "Ex: ./deploy.sh"
    echoBold "Ex: ./deploy.sh -d"
    echo
    exit 1
}

function showUsageAndExitDefault () {
    echoBold "Usage: ./deploy.sh [OPTIONS]"
    echo
    echo "Deploy Replication Controllers and Services on Kubernetes for $(echo $product_name | awk '{print toupper($0)}')"
    echo

    echoBold "Options:"
    echo -e " \t-h  - Show usage"
    echo

    echoBold "Ex: ./deploy.sh"
    exit 1
}
