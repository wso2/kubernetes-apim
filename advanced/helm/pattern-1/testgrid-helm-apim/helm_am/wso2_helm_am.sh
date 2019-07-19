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

set -e

#installation of database differs accoring to the type of database resource found.
#This function is to deploy the database correctly as found in the test plan.

function helm_deploy(){ 

  create_value_yaml

  #install resources using helm
  helmDeployment="wso2product$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)"
  resources_deployment
  helm install $helmDeployment $deploymentRepositoryLocation/deploymentRepository/helm_am/product/

  
}

function create_value_yaml(){

file=$INPUT_DIR/infrastructure.properties
dockerAccessUserName=$(cat $file | grep "dockerAccessUserName" | cut -d'=' -f2)
dockerAccessPassword=$(cat $file | grep "dockerAccessPassword" | cut -c 22- | tr -d '\')
echo $dockerAccessUserName
echo $dockerAccessPassword
echo $namespace

DB=$(echo $DBEngine | cut -d'-' -f 1  | tr '[:upper:]' '[:lower:]')
OS=$(echo $OS | cut -d'-' -f 1  | tr '[:upper:]' '[:lower:]')
JDK=$(echo $JDK | cut -d'-' -f 1  | tr '[:upper:]' '[:lower:]')

echo "creation of values.yaml file"

cat > values.yaml << EOF
username: $dockerAccessUserName
password: $dockerAccessPassword
email: $dockerAccessUserName
namespace: $namespace
svcaccount: "wso2svc-account"
dbType: $DBEngine
operatingSystem: $OS
jdkType: $JDK
EOF
yes | cp -rf $deploymentRepositoryLocation/values.yaml $deploymentRepositoryLocation/deploymentRepository/helm_am/product/
}

function resources_deployment(){


    if [ "$DB" == "mysql" ]
    then
        helm install wso2-rdbms-service -f $deploymentRepositoryLocation/deploymentRepository/helm_am/mysql/values.yaml stable/mysql
        sleep 30s
    fi
    if [ "$DB" == "postgres" ]
    then
        helm install wso2-rdbms-service -f $deploymentRepositoryLocation/deploymentRepository/helm/postgresql/values.yaml stable/postgresql
        sleep 30s
    fi
    if [ "$DB" == "mssql" ]
    then
        helm install wso2-rdbms-service -f $deploymentRepositoryLocation/deploymentRepository/helm/mssql/values.yaml stable/mssql-linux
        kubectl create -f $deploymentRepositoryLocation/deploymentRepository/helm/jobs/db_provisioner_job.yaml --namespace $namespace
        sleep 30s
    fi

}


helm_deploy
