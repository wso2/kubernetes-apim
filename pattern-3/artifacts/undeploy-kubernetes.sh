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

kubectl delete deployments,services,PersistentVolume,PersistentVolumeClaim,Ingress -l pattern=wso2apim-pattern-3 -n wso2

kubectl delete deployment nginx-default-http-backend -n kube-system
kubectl delete deployment nginx-ingress-controller -n kube-system
kubectl delete service nginx-default-http-backend -n kube-system

kubectl delete configmaps apim-analytics-1-bin
kubectl delete configmaps apim-analytics-1-conf
kubectl delete configmaps apim-analytics-1-spark
kubectl delete configmaps apim-analytics-1-axis2
kubectl delete configmaps apim-analytics-1-datasources
kubectl delete configmaps apim-analytics-1-tomcat

kubectl delete configmaps apim-analytics-2-bin
kubectl delete configmaps apim-analytics-2-conf
kubectl delete configmaps apim-analytics-2-spark
kubectl delete configmaps apim-analytics-2-axis2
kubectl delete configmaps apim-analytics-2-datasources
kubectl delete configmaps apim-analytics-2-tomcat

kubectl delete configmaps apim-gw-manager-worker-bin
kubectl delete configmaps apim-gw-manager-worker-conf
kubectl delete configmaps apim-gw-manager-worker-identity
kubectl delete configmaps apim-gw-manager-worker-axis2
kubectl delete configmaps apim-gw-manager-worker-datasources
kubectl delete configmaps apim-gw-manager-worker-tomcat

kubectl delete configmaps apim-km-bin
kubectl delete configmaps apim-km-conf
kubectl delete configmaps apim-km-identity
kubectl delete configmaps apim-km-axis2
kubectl delete configmaps apim-km-datasources
kubectl delete configmaps apim-km-tomcat

kubectl delete configmaps apim-publisher-bin
kubectl delete configmaps apim-publisher-conf
kubectl delete configmaps apim-publisher-identity
kubectl delete configmaps apim-publisher-axis2
kubectl delete configmaps apim-publisher-datasources
kubectl delete configmaps apim-publisher-tomcat

kubectl delete configmaps apim-store-bin
kubectl delete configmaps apim-store-conf
kubectl delete configmaps apim-store-identity
kubectl delete configmaps apim-store-axis2
kubectl delete configmaps apim-store-datasources
kubectl delete configmaps apim-store-tomcat

kubectl delete configmaps apim-tm1-bin
kubectl delete configmaps apim-tm1-conf
kubectl delete configmaps apim-tm1-identity

kubectl delete configmaps apim-tm2-bin
kubectl delete configmaps apim-tm2-conf
kubectl delete configmaps apim-tm2-identity