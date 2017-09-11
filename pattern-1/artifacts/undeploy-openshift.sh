#!/bin/bash

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim,Routes -l pattern=wso2apim-pattern-1

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

oc delete configmaps apim-manager-worker-bin
oc delete configmaps apim-manager-worker-conf
oc delete configmaps apim-manager-worker-identity
oc delete configmaps apim-manager-worker-axis2
oc delete configmaps apim-manager-worker-datasources
oc delete configmaps apim-manager-worker-tomcat
oc delete configmaps apim-manager-worker-resources-security

oc delete configmaps apim-worker-bin
oc delete configmaps apim-worker-conf
oc delete configmaps apim-worker-identity
oc delete configmaps apim-worker-axis2
oc delete configmaps apim-worker-datasources
oc delete configmaps apim-worker-tomcat
oc delete configmaps apim-worker-resources-security
