FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

# defined arguments and defaults
ARG USER=wso2user
ARG USER_ID=1000000000
#ARG GROUP=wso2
ARG USER_HOME=/home/wso2user
ARG WSO2_SERVER=wso2am
ARG WSO2_SERVER_VERSION=2.1.0
ARG WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip
ARG JDK_ARCHIVE=jdk-8u121-linux-x64.tar.gz
ARG JAVA_HOME=${USER_HOME}/java

RUN apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
       	   zip \
           unzip \
           telnet

# creates the user 
#RUN groupadd ${GROUP} --gid 10000 --system && useradd --system --uid 1000000000 \
#	--gid 10000 --create-home --home-dir ${USER_HOME}  --no-log-init ${USER}
RUN useradd --system --uid ${USER_ID} --gid 0 --create-home --home-dir ${USER_HOME} \
	--no-log-init ${USER}

# copy the jdk and product packs
COPY ${WSO2_SERVER_PACK} ${JDK_ARCHIVE} ${USER_HOME}/

# set permission for the user home to the group root
RUN chgrp -R 0 ${USER_HOME} \
        && chmod -R g+rwX ${USER_HOME}

# set the user, work directory and home 
USER ${USER_ID}
WORKDIR ${USER_HOME}
ENV HOME=${USER_HOME}

# unzip the packs, copy the <APIM_HOME>/repository/deployment/server to a temp location
# and creates the init script
RUN unzip -q ${USER_HOME}/${WSO2_SERVER_PACK} -d ${USER_HOME}/ \
        && mkdir -p ${JAVA_HOME} \
        && tar -xf ${USER_HOME}/${JDK_ARCHIVE} -C ${JAVA_HOME} --strip-components=1 \
        && mkdir -p ${USER_HOME}/tmp \
        && cp -r ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server ${USER_HOME}/tmp/ \
        && rm ${USER_HOME}/${WSO2_SERVER_PACK} \
        && rm ${USER_HOME}/${JDK_ARCHIVE} \
	&& mkdir -p ${USER_HOME}/scripts/ \
        && echo '#!/bin/bash' > ${USER_HOME}/scripts/init_carbon.sh \
        && echo 'if [[ -d ${HOME}/tmp/server/ ]]; then' >> ${USER_HOME}/scripts/init_carbon.sh  \
        && echo '   echo "copying artifacts from ${HOME}/tmp/server/ to ${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/ .."' >> ${USER_HOME}/scripts/init_carbon.sh \
        && echo '   cp -rf ${HOME}/tmp/server/* ${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/' >> ${USER_HOME}/scripts/init_carbon.sh \
        && echo '   rm -rf ${HOME}/tmp/server/' >> ${USER_HOME}/scripts/init_carbon.sh \
        && echo 'fi' >> ${USER_HOME}/scripts/init_carbon.sh \
        && echo '${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh' >> ${USER_HOME}/scripts/init_carbon.sh \
	&& chmod +x ${USER_HOME}/scripts/init_carbon.sh

# set java home and path variables
ENV JAVA_HOME=${JAVA_HOME} PATH=$JAVA_HOME/bin:$PATH USER_HOME=${USER_HOME} \
        WSO2_SERVER=${WSO2_SERVER} WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION}

# expose ports
EXPOSE 8280 8243 9763 9443 5672 9711 9611 7711 7611

#ENTRYPOINT exec ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh
ENTRYPOINT exec ${USER_HOME}/scripts/init_carbon.sh
