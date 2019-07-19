#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
# limitations under the License.
#--------------------------------------------------------------------------------

set -o xtrace
echo "deploy file is found"

OUTPUT_DIR=$4
INPUT_DIR=$2
source $INPUT_DIR/infrastructure.properties
source $OUTPUT_DIR/deployment.properties

function create_endpoints(){

    echo "KeyManagerUrl=https://${loadBalancerHostName}/services/" >> $OUTPUT_DIR/deployment.properties
    echo "PublisherUrl=https://${loadBalancerHostName}/publisher" >> $OUTPUT_DIR/deployment.properties
    echo "StoreUrl=https://${loadBalancerHostName}/store" >> $OUTPUT_DIR/deployment.properties
    echo "AdminUrl=https://${loadBalancerHostName}/admin" >> $OUTPUT_DIR/deployment.properties
    echo "CarbonServerUrl=https://${loadBalancerHostName}/services/" >> $OUTPUT_DIR/deployment.properties
    echo "GatewayHttpsUrl=https://${loadBalancerHostName}:8243" >> $OUTPUT_DIR/deployment.properties
    echo "external_ip=$external_ip" >> $OUTPUT_DIR/deployment.properties

}

create_endpoints

