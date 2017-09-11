#!/bin/bash

echo "APIM Core: ${API_CORE_URL}"
/opt/${PRODUCT_NAME}-${PRODUCT_VERSION}/bin/ballerina run service /opt/${PRODUCT_NAME}-${PRODUCT_VERSION}/services.bsz
