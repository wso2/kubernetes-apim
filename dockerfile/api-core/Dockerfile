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

WORKDIR /opt
COPY wso2apim-3.0.0-m6.zip /opt
COPY deployment.yaml /opt

RUN unzip wso2apim-3.0.0-m6.zip && \
    chown -R wso2:wso2 /opt/wso2apim-3.0.0-m6 && \
    rm -rf /opt/wso2apim-3.0.0-m6.zip && \
    cp /opt/deployment.yaml /opt/wso2apim-3.0.0-m6/conf

EXPOSE 9292

CMD ["/opt/wso2apim-3.0.0-m6/bin/carbon.sh"]
