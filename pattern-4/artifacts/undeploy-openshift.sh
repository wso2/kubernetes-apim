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

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim,Routes -l pattern=wso2apim-pattern-4 -n wso2

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

oc delete configmaps apim-gw-manager-worker-int-bin
oc delete configmaps apim-gw-manager-worker-int-conf
oc delete configmaps apim-gw-manager-worker-int-identity
oc delete configmaps apim-gw-manager-worker-int-axis2
oc delete configmaps apim-gw-manager-worker-int-datasources
oc delete configmaps apim-gw-manager-worker-int-tomcat

oc delete configmaps apim-gw-worker-int-bin
oc delete configmaps apim-gw-worker-int-conf
oc delete configmaps apim-gw-worker-int-identity
oc delete configmaps apim-gw-worker-int-axis2
oc delete configmaps apim-gw-worker-int-datasources
oc delete configmaps apim-gw-worker-int-tomcat

oc delete configmaps apim-gw-manager-worker-ext-bin
oc delete configmaps apim-gw-manager-worker-ext-conf
oc delete configmaps apim-gw-manager-worker-ext-identity
oc delete configmaps apim-gw-manager-worker-ext-axis2
oc delete configmaps apim-gw-manager-worker-ext-datasources
oc delete configmaps apim-gw-manager-worker-ext-tomcat

oc delete configmaps apim-gw-worker-ext-bin
oc delete configmaps apim-gw-worker-ext-conf
oc delete configmaps apim-gw-worker-ext-identity
oc delete configmaps apim-gw-worker-ext-axis2
oc delete configmaps apim-gw-worker-ext-datasources
oc delete configmaps apim-gw-worker-ext-tomcat

oc delete configmaps apim-km-bin
oc delete configmaps apim-km-conf
oc delete configmaps apim-km-identity
oc delete configmaps apim-km-axis2
oc delete configmaps apim-km-datasources
oc delete configmaps apim-km-tomcat

oc delete configmaps apim-pubstore-tm-1-bin
oc delete configmaps apim-pubstore-tm-1-conf
oc delete configmaps apim-pubstore-tm-1-identity
oc delete configmaps apim-pubstore-tm-1-axis2
oc delete configmaps apim-pubstore-tm-1-datasources
oc delete configmaps apim-pubstore-tm-1-tomcat

oc delete configmaps apim-pubstore-tm-2-bin
oc delete configmaps apim-pubstore-tm-2-conf
oc delete configmaps apim-pubstore-tm-2-identity
oc delete configmaps apim-pubstore-tm-2-axis2
oc delete configmaps apim-pubstore-tm-2-datasources
oc delete configmaps apim-pubstore-tm-2-tomcat
