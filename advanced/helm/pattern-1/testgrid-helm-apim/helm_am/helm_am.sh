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
echo "Change the configurations of axis.xml file"
OUTPUT_DIR=$4
INPUT_DIR=$2

echo "demo helm script to change necessary configurations in the helm files"

file=$INPUT_DIR/infrastructure.properties
dockerAccessUserName=$(cat $file | grep "WUMUsername" | cut -d'=' -f2)
dockerAccessPassword=$(cat $file | grep "WUMPassword" | cut -c 13- | tr -d '\')
echo $dockerAccessUserName
echo $dockerAccessPassword
echo "dockerAccessUserName=$dockerAccessUserName" >> $OUTPUT_DIR/infrastructure.properties
echo "dockerAccessPassword=$dockerAccessPassword" >> $OUTPUT_DIR/infrastructure.properties
