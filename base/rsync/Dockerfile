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

FROM ubuntu:latest
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

ARG USER=wso2user
ARG USER_ID=1000000000
ARG USER_HOME=/home/wso2user
ARG LOCAL_ARTIFACTS_LOCATION=${USER_HOME}/apim-artifacts
ARG REMOTE_HOST=localhost
ARG REMOTE_ARTIFACTS_LOCATION=${USER_HOME}/apim-artifacts

RUN apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
        telnet \
	openssh-client \
	rsync

RUN useradd --system --uid ${USER_ID} --gid 0 --create-home --home-dir ${USER_HOME} \
        --no-log-init ${USER}

COPY id_rsa run.sh ${USER_HOME}/

RUN mkdir -p ${USER_HOME}/.ssh \
        && mv ${USER_HOME}/id_rsa ${USER_HOME}/.ssh/ \
	&& mkdir -p ${USER_HOME}/logs/ \
	# && touch ${USER_HOME}/logs/artifact-sync.log \
	&& ln -sf /dev/stdout ${USER_HOME}/logs/artifact-sync.log \
	&& chown ${USER} ${USER_HOME}/logs/artifact-sync.log \
        && mkdir -p ${USER_HOME}/scripts/ \
	&& cat  ${USER_HOME}/run.sh > ${USER_HOME}/scripts/run.sh \
        && chmod 0755 ${USER_HOME}/scripts/run.sh \
	&& mkdir -p ${LOCAL_ARTIFACTS_LOCATION}/ \
	&& chmod 0774 ${LOCAL_ARTIFACTS_LOCATION}/ \
	&& chown -R ${USER_ID} ${USER_HOME} \
        && chmod 0755 ${USER_HOME} \
        && chmod 0700 ${USER_HOME}/.ssh \
        && chmod 0600 ${USER_HOME}/.ssh/id_rsa

USER ${USER_ID}
WORKDIR ${USER_HOME}
ENV USER_HOME=${USER_HOME} USER=${USER} \
	LOCAL_ARTIFACTS_LOCATION=${LOCAL_ARTIFACTS_LOCATION} \
	REMOTE_HOST=${REMOTE_HOST} \
	REMOTE_ARTIFACTS_LOCATION=${REMOTE_ARTIFACTS_LOCATION}

CMD exec ${USER_HOME}/scripts/run.sh
