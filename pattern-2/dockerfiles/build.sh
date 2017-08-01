#!/bin/bash

# builds all images for pattern-1
this_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
apim_analytics_dir=$(cd "${this_dir}/apim-analytics"; pwd)
apim_gw_manager_worker_dir=$(cd "${this_dir}/apim-gw-manager-worker"; pwd)
apim_gw_worker_dir=$(cd "${this_dir}/apim-gw-worker"; pwd)
pubstore_tm_km_1_dir=$(cd "${this_dir}/apim-pubstore-tm-km-1"; pwd)
pubstore_tm_km_2_dir=$(cd "${this_dir}/apim-pubstore-tm-km-2"; pwd)

docker build -t wso2/wso2am-analytics-pattern-2:2.1.0 $apim_analytics_dir --squash
docker build -t wso2/wso2am-gw-manager-worker-pattern-2:2.1.0 $apim_gw_manager_worker_dir --squash
docker build -t wso2/wso2am-gw-worker-pattern-2:2.1.0 $apim_gw_worker_dir --squash
docker build -t wso2/wso2am-pubstore-tm-km-1-pattern-2:2.1.0 $pubstore_tm_km_1_dir --squash
docker build -t wso2/wso2am-pubstore-tm-km-2-pattern-2:2.1.0 $pubstore_tm_km_2_dir --squash