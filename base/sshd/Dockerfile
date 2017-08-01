FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

ARG USER=wso2user
ARG USER_ID=1000000000
ARG USER_HOME=/home/wso2user
ARG APIM_ARTIFACTS_LOCATION=${USER_HOME}/apim-artifacts

RUN apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
        telnet \
	openssh-server \
	rsync

RUN mkdir /var/run/sshd

RUN useradd --system --uid ${USER_ID} --gid 0 --create-home --home-dir ${USER_HOME} \
        --no-log-init ${USER}

EXPOSE 8022

COPY id_rsa.pub sshd_config rsyslog.conf init.sh ${USER_HOME}/

RUN mkdir -p ${USER_HOME}/scripts \
	&& cat ${USER_HOME}/init.sh > ${USER_HOME}/scripts/init.sh \
	&& chmod 0755 ${USER_HOME}/scripts/init.sh \
	&& chown -R ${USER} /etc/ssh \
#	&& touch /var/run/rsyslogd.pid \
#	&& chown ${USER} /var/run/rsyslogd.pid \
#	&& touch /var/log/auth.log \
#	&& chown ${USER} /var/log/auth.log \
	&& mkdir -p ${USER_HOME}/.ssh \
	&& mkdir -p ${APIM_ARTIFACTS_LOCATION}/ \
	&& chmod 0774 ${APIM_ARTIFACTS_LOCATION}/ \
	&& cat ${USER_HOME}/id_rsa.pub > ${USER_HOME}/.ssh/authorized_keys \
	&& cat ${USER_HOME}/sshd_config > /etc/ssh/sshd_config \
	&& cat ${USER_HOME}/rsyslog.conf > /etc/rsyslog.conf \
	&& chmod 0744 /etc/rsyslog.conf \
	&& chmod 0744 /etc/ssh/sshd_config \
	&& chown -R ${USER} ${USER_HOME} \
	&& chmod 0755 ${USER_HOME} \
	&& chmod 0700 ${USER_HOME}/.ssh \
	&& chmod 0644 ${USER_HOME}/.ssh/authorized_keys \
	&& rm ${USER_HOME}/id_rsa.pub 

USER ${USER_ID}
WORKDIR ${USER_HOME}

ENV USER_HOME ${USER_HOME} 

CMD exec ${USER_HOME}/scripts/init.sh
