#!/bin/bash

# builds all images for pattern-1
this_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
apim_analytics_dir=$(cd "${this_dir}/apim-analytics"; pwd)
apim_manager_worker_dir=$(cd "${this_dir}/apim-manager-worker"; pwd)
apim_worker_dir=$(cd "${this_dir}/apim-worker"; pwd)

docker build -t wso2/wso2am-analytics-pattern-1:2.1.0 $apim_analytics_dir --squash
docker build -t wso2/wso2am-manager-worker-pattern-1:2.1.0 $apim_manager_worker_dir --squash
docker build -t wso2/wso2am-worker-pattern-1:2.1.0 $apim_worker_dir --squash
