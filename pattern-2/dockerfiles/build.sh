#!/bin/bash

# builds all images for pattern-2
this_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
apim_analytics_1_dir=$(cd "${this_dir}/apim-analytics-1"; pwd)
apim_analytics_2_dir=$(cd "${this_dir}/apim-analytics-2"; pwd)
apim_gw_manager_worker_dir=$(cd "${this_dir}/apim-gw-manager-worker"; pwd)
apim_gw_worker_dir=$(cd "${this_dir}/apim-gw-worker"; pwd)
pubstore_tm_1_dir=$(cd "${this_dir}/apim-pubstore-tm-1"; pwd)
pubstore_tm_2_dir=$(cd "${this_dir}/apim-pubstore-tm-2"; pwd)
km_dir=$(cd "${this_dir}/apim-km"; pwd)

docker build -t wso2/wso2am-analytics-1-pattern-2:2.1.0 $apim_analytics_1_dir --squash
docker build -t wso2/wso2am-analytics-2-pattern-2:2.1.0 $apim_analytics_2_dir --squash
docker build -t wso2/wso2am-gw-manager-worker-pattern-2:2.1.0 $apim_gw_manager_worker_dir --squash
docker build -t wso2/wso2am-gw-worker-pattern-2:2.1.0 $apim_gw_worker_dir --squash
docker build -t wso2/wso2am-pubstore-tm-1-pattern-2:2.1.0 $pubstore_tm_1_dir --squash
docker build -t wso2/wso2am-pubstore-tm-2-pattern-2:2.1.0 $pubstore_tm_2_dir --squash
docker build -t wso2/wso2am-km-pattern-2:2.1.0 $km_dir --squash
