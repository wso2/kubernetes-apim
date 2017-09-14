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

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim,Routes -l pattern=wso2apim-pattern-3 -n wso2

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

oc delete configmaps apim-gw-worker-bin
oc delete configmaps apim-gw-worker-conf
oc delete configmaps apim-gw-worker-identity
oc delete configmaps apim-gw-worker-axis2
oc delete configmaps apim-gw-worker-datasources
oc delete configmaps apim-gw-worker-tomcat

oc delete configmaps apim-km-bin
oc delete configmaps apim-km-conf
oc delete configmaps apim-km-identity
oc delete configmaps apim-km-axis2
oc delete configmaps apim-km-datasources
oc delete configmaps apim-km-tomcat

oc delete configmaps apim-publisher-bin
oc delete configmaps apim-publisher-conf
oc delete configmaps apim-publisher-identity
oc delete configmaps apim-publisher-axis2
oc delete configmaps apim-publisher-datasources
oc delete configmaps apim-publisher-tomcat

oc delete configmaps apim-store-bin
oc delete configmaps apim-store-conf
oc delete configmaps apim-store-identity
oc delete configmaps apim-store-axis2
oc delete configmaps apim-store-datasources
oc delete configmaps apim-store-tomcat

oc delete configmaps apim-tm1-bin
oc delete configmaps apim-tm1-conf
oc delete configmaps apim-tm1-identity

oc delete configmaps apim-tm2-bin
oc delete configmaps apim-tm2-conf
oc delete configmaps apim-tm2-identity