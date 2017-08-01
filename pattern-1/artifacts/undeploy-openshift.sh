#!/bin/bash

oc delete deployments,services,PersistentVolume,PersistentVolumeClaim -l pattern=wso2apim-pattern-1
