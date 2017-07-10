FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

# defined arguments and defaults
ARG USER=wso2user
ARG USER_ID=1000000000
#ARG GROUP=wso2
ARG USER_HOME=/home/wso2user
ARG WSO2_SERVER=wso2am-analytics
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

# set permission for the user home
RUN chgrp -R 0 ${USER_HOME} \
  && chmod -R g+rwX ${USER_HOME}

# set the user, work directory and home 
USER ${USER_ID}
WORKDIR ${USER_HOME}
ENV HOME=${USER_HOME}

# unzip the packs and remove archives
RUN unzip -q ${USER_HOME}/${WSO2_SERVER_PACK} -d ${USER_HOME}/ \
	&& mkdir -p ${JAVA_HOME} \
     	&& tar -xf ${USER_HOME}/${JDK_ARCHIVE} -C ${JAVA_HOME} --strip-components=1 \
	&& rm ${USER_HOME}/${WSO2_SERVER_PACK} \ 
	&& rm ${USER_HOME}/${JDK_ARCHIVE}

# set java home and path variables
ENV JAVA_HOME=${JAVA_HOME} PATH=$JAVA_HOME/bin:$PATH USER_HOME=${USER_HOME} \
	WSO2_SERVER=${WSO2_SERVER} WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION}

ENTRYPOINT exec ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh
