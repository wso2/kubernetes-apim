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

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim,Routes -l pattern=wso2apim-pattern-2 -n wso2

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

oc delete configmaps apim-gw-manager-worker-bin
oc delete configmaps apim-gw-manager-worker-conf
oc delete configmaps apim-gw-manager-worker-identity
oc delete configmaps apim-gw-manager-worker-axis2
oc delete configmaps apim-gw-manager-worker-datasources
oc delete configmaps apim-gw-manager-worker-tomcat

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
