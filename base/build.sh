#!/bin/bash

# builds the base images - apim-base, analytics, rsync, sshd

this_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
rsync_dir=$(cd "${this_dir}/rsync"; pwd)
sshd_dir=$(cd "${this_dir}/sshd"; pwd)
analytics_dir=$(cd "${this_dir}/analytics"; pwd)
apim_base_dir=$(cd "${this_dir}/apim-base"; pwd)

docker build -t wso2/rsync:1.0.0 $rsync_dir --squash
docker build -t wso2/sshd:1.0.0 $sshd_dir --squash
docker build -t wso2/wso2am:2.1.0 $apim_base_dir --squash
docker build -t wso2/wso2am-analytics:2.1.0 $analytics_dir --squash
