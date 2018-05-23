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

FROM ubuntu:16.04
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"

# set user configurations
ARG USER=wso2carbon
ARG USER_ID=802
ARG USER_GROUP=wso2
ARG USER_GROUP_ID=802
ARG USER_HOME=/home/${USER}
# set dependant files directory
ARG FILES=./files
# set jdk configurations
ARG JDK=jdk1.8.0*
ARG JAVA_HOME=${USER_HOME}/java
# set wso2 product configurations
ARG WSO2_SERVER=wso2am-analytics
ARG WSO2_SERVER_VERSION=2.1.0
ARG WSO2_SERVER_DIST=${WSO2_SERVER}-${WSO2_SERVER_VERSION}
ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}

# install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    iproute2 curl && \
    rm -rf /var/lib/apt/lists/*

# create a user group and a user
RUN groupadd --system -g ${USER_GROUP_ID} ${USER_GROUP} && \
    useradd --system --create-home --home-dir ${USER_HOME} --no-log-init -g ${USER_GROUP_ID} -u ${USER_ID} ${USER}

# copy init_carbon.sh, jdk and wso2 product distribution to user's home directory
COPY --chown=wso2carbon:wso2 init_carbon.sh ${USER_HOME}/
COPY --chown=wso2carbon:wso2 ${FILES}/${JDK} ${USER_HOME}/java/
COPY --chown=wso2carbon:wso2 ${FILES}/${WSO2_SERVER_DIST} ${USER_HOME}/${WSO2_SERVER_DIST}

# copy files found in repository/deployment/server to a temporary location to be copied back at the container
# startup once the persistent volume is attached for the first time
COPY --chown=wso2carbon:wso2 ${FILES}/${WSO2_SERVER_DIST}-server ${USER_HOME}/tmp-server/

# copy client truststore, keystore, mysql connector jar, kubernetes membership scheme jar and dnsjava jar to the server distribution
COPY --chown=wso2carbon:wso2 ${FILES}/*.jks ${USER_HOME}/${WSO2_SERVER_DIST}/repository/resources/security/
COPY --chown=wso2carbon:wso2 ${FILES}/mysql-connector-java-*-bin.jar ${USER_HOME}/${WSO2_SERVER_DIST}/repository/components/lib/
COPY --chown=wso2carbon:wso2 ${FILES}/kubernetes-membership-scheme-*.jar ${USER_HOME}/${WSO2_SERVER_DIST}/repository/components/dropins/
COPY --chown=wso2carbon:wso2 ${FILES}/dnsjava-2.1.8.jar ${USER_HOME}/${WSO2_SERVER_DIST}/repository/components/lib/

# set the user and work directory
USER ${USER_ID}
WORKDIR ${USER_HOME}

# set environment variables
ENV USER_HOME=${USER_HOME} \
    JAVA_HOME=${JAVA_HOME} \
    PATH=$JAVA_HOME/bin:$PATH \
    WSO2_SERVER_HOME=${WSO2_SERVER_HOME}

# expose ports
EXPOSE 9764 9444 7712 7612 11225 10006 11001 11501 8082 4041 18081 12501 13001 13501 14001 14501 7078 6067 12000-12005

ENTRYPOINT exec ${USER_HOME}/init_carbon.sh
