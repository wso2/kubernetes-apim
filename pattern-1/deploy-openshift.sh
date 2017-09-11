#!/bin/bash
# ------------------------------------------------------------------------
#
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
#
# ------------------------------------------------------------------------

oc create -f wso2apim3-namespace.yaml
oc create -f activemq-service.yaml -n wso2apim3
oc create -f key-manager-service.yaml -n wso2apim3
oc create -f api-core-service.yaml -n wso2apim3

oc create -f activemq-deployment.yaml -n wso2apim3
sleep 5

oc create -f key-manager-deployment.yaml -n wso2apim3

oc create -f api-core-deployment.yaml -n wso2apim3

oc create -f api-gateway-deployment.yaml -n wso2apim3
