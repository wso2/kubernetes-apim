FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

# defined arguments and defaults
ARG USER=wso2user
ARG USER_ID=1000000000
#ARG GROUP=wso2
ARG USER_HOME=/home/${USER}
ARG WSO2_SERVER=wso2am-analytics
ARG WSO2_SERVER_VERSION=2.1.0
ARG WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip
ARG JDK_ARCHIVE=jdk-8u121-linux-x64.tar.gz
ARG JAVA_HOME=${USER_HOME}/java
ARG STARTUP_SCRIPT=init_carbon.sh

RUN apt-get update \
        && apt-get install -y --no-install-recommends --no-install-suggests \
           zip \
           unzip \
           telnet \
           iproute2

# creates the user 
RUN useradd --system --uid ${USER_ID} --gid 0 --create-home --home-dir ${USER_HOME} \
        --no-log-init ${USER}

# copy the jdk and product packs
COPY ${WSO2_SERVER_PACK} ${STARTUP_SCRIPT} ${JDK_ARCHIVE} ${USER_HOME}/

# and creates the init script
RUN unzip -q ${USER_HOME}/${WSO2_SERVER_PACK} -d ${USER_HOME}/ \
        && mkdir -p ${JAVA_HOME} \
        && tar -xf ${USER_HOME}/${JDK_ARCHIVE} -C ${JAVA_HOME} --strip-components=1 \
        && mkdir -p ${USER_HOME}/tmp \
        && cp -r ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server ${USER_HOME}/tmp/ \
        && rm ${USER_HOME}/${WSO2_SERVER_PACK} \
        && rm ${USER_HOME}/${JDK_ARCHIVE} \
        && mkdir -p ${USER_HOME}/scripts/ \
        && cat ${USER_HOME}/${STARTUP_SCRIPT} > ${USER_HOME}/scripts/${STARTUP_SCRIPT} \
        && rm ${USER_HOME}/${STARTUP_SCRIPT} \
        && chgrp -R 0 ${USER_HOME} \
        && chown -R ${USER_ID} ${USER_HOME} \
        && chmod -R 0774 ${USER_HOME}

# set the user, work directory and home 
USER ${USER_ID}
WORKDIR ${USER_HOME}

# set java home and path variables
ENV HOME=${USER_HOME} JAVA_HOME=${JAVA_HOME} PATH=$JAVA_HOME/bin:$PATH USER_HOME=${USER_HOME} \
        WSO2_SERVER=${WSO2_SERVER} WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION}

# expose ports
EXPOSE 9763 9443 5672 9711 9611 7711 7611

ENTRYPOINT exec ${USER_HOME}/scripts/init_carbon.sh
