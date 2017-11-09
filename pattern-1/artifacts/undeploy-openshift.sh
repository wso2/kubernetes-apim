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

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim,Routes -l pattern=wso2apim-pattern-1 -n wso2

oc delete configmaps apim-analytics-1-bin
oc delete configmaps apim-analytics-1-conf
oc delete configmaps apim-analytics-1-spark
oc delete configmaps apim-analytics-1-axis2
oc delete configmaps apim-analytics-1-datasources
oc delete configmaps apim-analytics-1-tomcat

oc delete configmaps apim-analytics-2-bin
oc delete configmaps apim-analytics-2-conf
oc delete configmaps apim-analytics-2-spark
oc delete configmaps apim-analytics-2-axis2
oc delete configmaps apim-analytics-2-datasources
oc delete configmaps apim-analytics-2-tomcat

oc delete configmaps apim-manager-worker-bin
oc delete configmaps apim-manager-worker-conf
oc delete configmaps apim-manager-worker-identity
oc delete configmaps apim-manager-worker-axis2
oc delete configmaps apim-manager-worker-datasources
oc delete configmaps apim-manager-worker-tomcat

oc delete configmaps apim-worker-bin
oc delete configmaps apim-worker-conf
oc delete configmaps apim-worker-identity
oc delete configmaps apim-worker-axis2
oc delete configmaps apim-worker-datasources
oc delete configmaps apim-worker-tomcat