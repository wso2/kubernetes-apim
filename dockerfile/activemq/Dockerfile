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

FROM openjdk:8u111-jdk-alpine
MAINTAINER dev@wso2.org

WORKDIR /opt

ADD apache-activemq-5.14.0-bin.tar.gz  .
COPY activemq.sh .

EXPOSE 61616

RUN apk update && \
    addgroup -S wso2 && \
    adduser -S -g wso2 wso2 && \
    chown -R wso2:wso2 /opt/activemq.sh && \
    chown -R wso2:wso2 /opt/apache-activemq-5.14.0 && \
    chmod u+x /opt/activemq.sh

USER wso2

CMD ["/opt/activemq.sh"]
