#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2018 WSO2, Inc. (http://wso2.com)
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

export KUBERNETES_MASTER=$1

# Log Message should be parsed $1
log(){
 TIME=`date`
 #echo "$TIME : $1" >> "$LOG_FILE_LOCATION"
 echo "$TIME : $1"
 return
}


temp=${1#*//}
Master_IP=${temp%:*}
prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_scripts_folder=$(cd "${script_path}/common/scripts/"; pwd)
source "${common_scripts_folder}/base.sh"

while getopts :h FLAG; do
    case $FLAG in
        h)
            showUsageAndExitDefault
            ;;
        \?)
            showUsageAndExitDefault
            ;;
    esac
done

#kubectl create secret docker-registry registrykey --docker-server=$2 --docker-username=$3 --docker-password=$4 --docker-email=$5

validateKubeCtlConfig

# download APIm 2.1.0 docker images
nodes=$(kubectl get nodes --output=jsonpath='{ $.items[*].status.addresses[?(@.type=="LegacyHostIP")].address }')
delete=($Master_IP)
nodes=( "${nodes[@]/$delete}" )
for node in $nodes; do
    LOGIN_MSG=$(ssh core@$node "docker login docker.wso2.com -u $5 -p $4")
	if [[ ${LOGIN_MSG} != *"Login Succeeded"* ]]; then
		log "Docker login Error."
		exit 1
	fi
	echo "Docker login succeeded"
    ssh core@$node "docker pull docker.wso2.com/sshd-kubernetes:1.0.0 &&
		docker pull docker.wso2.com/rsync-kubernetes:1.0.0 &&
		docker pull docker.wso2.com/wso2am-analytics-kubernetes:2.1.0 &&
		docker pull docker.wso2.com/wso2am-kubernetes:2.1.0 &&
		docker pull docker.wso2.com/apim-rdbms-kubernetes:2.1.0"
done

#clone APIM kubernetes artifacts repo
env -i git clone https://github.com/wso2/kubernetes-apim.git
env -i git checkout tags/v2.1.0-1

#create a namespace
kubectl create namespace wso2
#create a service account
kubectl create serviceaccount wso2svcacct -n wso2
#create kubeconfig file
kubectl config --kubeconfig=config set-cluster scratch --server=$1 --insecure-skip-tls-verify
kubectl config --kubeconfig=config set-credentials experimenter --username=exp --password=exp
kubectl config --kubeconfig=config set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter
kubectl config --kubeconfig=config use-context exp-scratch
mv config ~/.kube/

# Change the pattern no accordingly.
cd kubernetes-apim/pattern-1/artifacts
#deploy artifacts
source deploy-kubernetes.sh

sleep 30

if [ ! -z "$IS_TESTGRID" ]; then
   source privileged_deploy.sh
fi

bash "${common_scripts_folder}/wait-until-server-starts.sh" "default" "${1}"

#create deployment.json
json='{ "hosts" : ['
ingress=$(kubectl get ingress --output=jsonpath={.items[*].spec.rules[*].host})
for item in $ingress; do
         json+='{"ip" :"'$item'", "label" :"'$item'", "ports" :['
            json+='{'
            json+='"protocol" : "servlet-http",  "portNumber" :"80"},{'
            json+='"protocol" : "servlet-https",  "portNumber" :"443"'
            json+="}"
         json+="]},"
done
json=${json:0:${#json}-1}

json+="]}"
echo $json;

cat > $script_path/deployment.json << EOF1
$json
EOF1
