FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

ARG USER=wso2user
ARG USER_ID=1000000000
ARG USER_HOME=/home/wso2user
ARG APIM_ARTIFACTS_LOCATION=${USER_HOME}/apim-artifacts

RUN apt-get install -y --no-install-recommends --no-install-suggests \
        telnet \
	openssh-client \
	rsync \
	cron

RUN useradd --system --uid ${USER_ID} --gid 0 --create-home --home-dir ${USER_HOME} \
        --no-log-init ${USER}

EXPOSE 22

COPY id_rsa artifact-sync-cron ${USER_HOME}/

RUN mkdir -p ${USER_HOME}/.ssh \
        && mv ${USER_HOME}/id_rsa ${USER_HOME}/.ssh/ \
	&& mkdir -p ${USER_HOME}/cron/logs/ \
	&& touch ${USER_HOME}/cron/logs/artifact-sync-cron.log \
        && mkdir -p ${USER_HOME}/scripts/ \
        && echo '#!/bin/bash' > ${USER_HOME}/scripts/init.sh \
	&& echo 'set -e' >> ${USER_HOME}/scripts/init.sh \
	&& echo 'echo 'starting cron deamon'' >> ${USER_HOME}/scripts/init.sh \
        && echo 'cron' >> ${USER_HOME}/scripts/init.sh \
	&& echo 'echo 'scheduling artifact sync cron job'' >> ${USER_HOME}/scripts/init.sh \
        && echo 'crontab -u ${USER} ${USER_HOME}/artifact-sync-cron' >> ${USER_HOME}/scripts/init.sh \
        && echo 'tailf ${USER_HOME}/cron/logs/artifact-sync-cron.log' >> ${USER_HOME}/scripts/init.sh \
        && chmod 0755 ${USER_HOME}/scripts/init.sh \
	&& mkdir -p ${APIM_ARTIFACTS_LOCATION}/ \
	&& chown -R ${USER_ID} ${USER_HOME} \
        && chmod 0755 ${USER_HOME} \
        && chmod 0700 ${USER_HOME}/.ssh \
        && chmod 0600 ${USER_HOME}/.ssh/id_rsa

#USER ${USER_ID}

WORKDIR ${USER_HOME}
ENV USER_HOME=${USER_HOME} USER=${USER} 

#CMD exec cron && tailf ${USER_HOME}/cron/logs/artifact-sync-cron.log 
CMD exec ${USER_HOME}/scripts/init.sh
