#!/bin/bash

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim,Routes -l pattern=wso2apim-pattern-2

oc delete configmaps apim-analytics-1-bin
oc delete configmaps apim-analytics-1-conf
oc delete configmaps apim-analytics-1-spark
oc delete configmaps apim-analytics-1-axis2
oc delete configmaps apim-analytics-1-datasources
oc delete configmaps apim-analytics-1-tomcat
oc delete configmaps apim-analytics-1-security

oc delete configmaps apim-analytics-2-bin
oc delete configmaps apim-analytics-2-conf
oc delete configmaps apim-analytics-2-spark
oc delete configmaps apim-analytics-2-axis2
oc delete configmaps apim-analytics-2-datasources
oc delete configmaps apim-analytics-2-tomcat
oc delete configmaps apim-analytics-2-security

oc delete configmaps apim-gw-manager-worker-bin
oc delete configmaps apim-gw-manager-worker-conf
oc delete configmaps apim-gw-manager-worker-identity
oc delete configmaps apim-gw-manager-worker-axis2
oc delete configmaps apim-gw-manager-worker-datasources
oc delete configmaps apim-gw-manager-worker-tomcat
oc delete configmaps apim-gw-manager-worker-resources-security

oc delete configmaps apim-gw-worker-bin
oc delete configmaps apim-gw-worker-conf
oc delete configmaps apim-gw-worker-identity
oc delete configmaps apim-gw-worker-axis2
oc delete configmaps apim-gw-worker-datasources
oc delete configmaps apim-gw-worker-tomcat
oc delete configmaps apim-gw-worker-resources-security

oc delete configmaps apim-km-bin
oc delete configmaps apim-km-conf
oc delete configmaps apim-km-identity
oc delete configmaps apim-km-axis2
oc delete configmaps apim-km-datasources
oc delete configmaps apim-km-tomcat
oc delete configmaps apim-km-resources-security

oc delete configmaps apim-pubstore-tm-1-bin
oc delete configmaps apim-pubstore-tm-1-conf
oc delete configmaps apim-pubstore-tm-1-identity
oc delete configmaps apim-pubstore-tm-1-axis2
oc delete configmaps apim-pubstore-tm-1-datasources
oc delete configmaps apim-pubstore-tm-1-tomcat
oc delete configmaps apim-pubstore-tm-1-resources-security

oc delete configmaps apim-pubstore-tm-2-bin
oc delete configmaps apim-pubstore-tm-2-conf
oc delete configmaps apim-pubstore-tm-2-identity
oc delete configmaps apim-pubstore-tm-2-axis2
oc delete configmaps apim-pubstore-tm-2-datasources
oc delete configmaps apim-pubstore-tm-2-tomcat
oc delete configmaps apim-pubstore-tm-2-resources-security
