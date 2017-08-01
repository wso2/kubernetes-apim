#!/bin/bash

# builds all images for pattern-1
this_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
apim_analytics_dir=$(cd "${this_dir}/apim-analytics"; pwd)
apim_gw_manager_worker_dir=$(cd "${this_dir}/apim-gw-manager-worker"; pwd)
apim_gw_worker_dir=$(cd "${this_dir}/apim-gw-worker"; pwd)
pubstore_tm_1_dir=$(cd "${this_dir}/apim-pubstore-tm-1"; pwd)
pubstore_tm_2_dir=$(cd "${this_dir}/apim-pubstore-tm-2"; pwd)
km_dir=$(cd "${this_dir}/apim-km"; pwd)
manager_worker_rsync_dir=$(cd "${this_dir}/manager-worker-rsync"; pwd)
tm_rsync_dir=$(cd "${this_dir}/tm-rsync"; pwd)

docker build -t wso2/wso2am-analytics-pattern-3:2.1.0 $apim_analytics_dir --squash
docker build -t wso2/wso2am-gw-manager-worker-pattern-3:2.1.0 $apim_gw_manager_worker_dir --squash
docker build -t wso2/wso2am-gw-worker-pattern-3:2.1.0 $apim_gw_worker_dir --squash
docker build -t wso2/wso2am-pubstore-tm-1-pattern-3:2.1.0 $pubstore_tm_1_dir --squash
docker build -t wso2/wso2am-pubstore-tm-2-pattern-3:2.1.0 $pubstore_tm_2_dir --squash
docker build -t wso2/wso2am-km-pattern-3:2.1.0 $km_dir --squash
docker build -t wso2/wso2am-gw-rsync-pattern-3:2.1.0 $manager_worker_rsync_dir --squash
docker build -t wso2/wso2am-tm-rsync-pattern-3:2.1.0 $tm_rsync_dir --squash
