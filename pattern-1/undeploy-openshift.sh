#!/bin/bash

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim -l pattern=wso2apim3-pattern-1
