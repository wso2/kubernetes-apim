#!/bin/bash

# Get MB HOST and PORT from env and update configs  
if [[ ! -z "${ACTIVEMQ_SERVICE_HOST}" ]];then
    if [[ ! -z "${ACTIVEMQ_SERVICE_PORT}" ]];then
	find org/wso2/carbon/apimgt/gateway/ -type f -print0 | xargs -0 sed -i -e "s/localhost\:61616/${ACTIVEMQ_SERVICE_HOST}:${ACTIVEMQ_SERVICE_PORT}/g"
    else
        find org/wso2/carbon/apimgt/gateway/ -type f -print0 | xargs -0 sed -i -e "s/localhost\:61616/${ACTIVEMQ_SERVICE_HOST}:61616/g"
    fi
fi

bin/ballerina run service services.bsz
