FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

ARG USER=wso2user
ARG USER_ID=1000000000
ARG USER_HOME=/home/wso2user
ARG APIM_ARTIFACTS_LOCATION=${USER_HOME}/apim-artifacts

RUN apt-get install -y --no-install-recommends --no-install-suggests \
        telnet \
	openssh-server \
	rsync

RUN mkdir /var/run/sshd

RUN useradd --system --uid ${USER_ID} --gid 0 --create-home --home-dir ${USER_HOME} \
        --no-log-init ${USER}

EXPOSE 22

#USER ${USER_ID}

COPY id_rsa.pub sshd_config init.sh ${USER_HOME}/

RUN mkdir -p ${USER_HOME}/scripts \
#        && echo '#!/bin/bash' > ${USER_HOME}/scripts/init.sh \
#	 && echo 'set -e' >> ${USER_HOME}/scripts/init.sh \
#	 && echo 'echo 'generating new server keys with ssh-keygen -A'' >> ${USER_HOME}/scripts/init.sh \
#        && echo 'ssh-keygen -A' >> ${USER_HOME}/scripts/init.sh \
#	 ### useful for debugging ssh related issues
#	 && echo 'rsyslogd' >> ${USER_HOME}/scripts/init.sh \
#	 && echo 'echo 'starting sshd deamon'' >> ${USER_HOME}/scripts/init.sh \
#        && echo '/usr/sbin/sshd -D' >> ${USER_HOME}/scripts/init.sh \
	&& cat ${USER_HOME}/init.sh > ${USER_HOME}/scripts/init.sh \
	&& chmod 0755 ${USER_HOME}/scripts/init.sh \
	# && chown -R ${USER} /etc/ssh \
	&& mkdir -p ${USER_HOME}/.ssh \
	&& mkdir -p ${APIM_ARTIFACTS_LOCATION}/ \
	&& chmod 0774 ${APIM_ARTIFACTS_LOCATION}/ \
	&& cat ${USER_HOME}/id_rsa.pub > ${USER_HOME}/.ssh/authorized_keys \
	&& cat ${USER_HOME}/sshd_config > /etc/ssh/sshd_config \
	&& chmod 0744 /etc/ssh/sshd_config \
	&& chown -R ${USER} ${USER_HOME} \
	&& chmod 0755 ${USER_HOME} \
	&& chmod 0700 ${USER_HOME}/.ssh \
	&& chmod 0644 ${USER_HOME}/.ssh/authorized_keys \
	&& rm ${USER_HOME}/id_rsa.pub 

ENV USER_HOME ${USER_HOME} 

#CMD ["/usr/sbin/sshd", "-D"]  
CMD exec ${USER_HOME}/scripts/init.sh
