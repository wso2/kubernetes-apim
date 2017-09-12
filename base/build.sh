#!/bin/bash

# ------------------------------------------------------------------------
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
# ------------------------------------------------------------------------

# builds the base images - apim-base, analytics, rsync, sshd

this_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
rsync_dir=$(cd "${this_dir}/rsync"; pwd)
sshd_dir=$(cd "${this_dir}/sshd"; pwd)
analytics_dir=$(cd "${this_dir}/analytics"; pwd)
apim_dir=$(cd "${this_dir}/apim"; pwd)
mysql_dir=$(cd "${this_dir}/mysql"; pwd)

docker build -t wso2/rsync:1.0.0 $rsync_dir --squash
docker build -t wso2/sshd:1.0.0 $sshd_dir --squash
docker build -t wso2/wso2am:2.1.0 $apim_dir --squash
docker build -t wso2/wso2am-analytics:2.1.0 $analytics_dir --squash
docker build -t docker.wso2.com/apim-rdbms-kubernetes:2.1.0 $mysql_dir --squash
