# ------------------------------------------------------------------------
#
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
#
# ------------------------------------------------------------------------

FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

ARG PRODUCT_NAME
ARG PRODUCT_VERSION

ENV PRODUCT_NAME=${PRODUCT_NAME:-wso2apim-gateway} \
    PRODUCT_VERSION=${PRODUCT_VERSION}

WORKDIR /opt

COPY ${PRODUCT_NAME}-${PRODUCT_VERSION}.zip .
COPY gateway.sh .

RUN unzip ${PRODUCT_NAME}-${PRODUCT_VERSION}.zip && \
    chown -R wso2:wso2 /opt/${PRODUCT_NAME}-${PRODUCT_VERSION} && \
    rm -rf ${PRODUCT_NAME}-${PRODUCT_VERSION}.zip && \
    chmod +x /opt/gateway.sh

EXPOSE 9090

ENTRYPOINT ["/opt/gateway.sh"]
