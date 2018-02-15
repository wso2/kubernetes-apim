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

set -e
self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/base.sh"

IFS=$'\n'
kube_nodes=($(getKubeNodes))
host=$(getKubeNodeIP "${kube_nodes[0]}")
product=${PWD##*/}
profile=$1
port=$2

echo "Waiting ${product} to launch on http://${host}"
sleep 120
#until $(curl --output /dev/null --silent --head --fail http://${host}:${port}); do
#   printf '.'
#    sleep 3
#done
echo
echoSuccess "$(echo ${product} | awk '{print toupper($0)}') started successfully, profile: ${profile}"
