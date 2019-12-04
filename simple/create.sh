#!/bin/bash

IS_OPEN_SOURCE=FALSE

if $IS_OPEN_SOURCE; then
  SCRIPT="deployment-scripts/wso2am-ga.sh"
else
  SCRIPT="deployment-scripts/wso2am-latest.sh"
fi

cat > $SCRIPT << "EOF"
#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
# limitations under the License.
#--------------------------------------------------------------------------------

set -e

EOF

cat >> $SCRIPT << "EOF"
# bash variables
k8s_obj_file="deployment.yaml"; str_sec=""

# wso2 subscription variables
WUMUsername=''; WUMPassword=''
EOF

if $IS_OPEN_SOURCE; then
  echo 'IMG_DEST="wso2"' >> $SCRIPT
else
  echo 'IMG_DEST="docker.wso2.com"' >> $SCRIPT
fi

cat >> $SCRIPT << "EOF"

: ${namespace:="wso2"}

EOF

echo "function create_yaml(){" >> $SCRIPT
echo 'cat > $k8s_obj_file << "EOF"' >> $SCRIPT
echo 'EOF' >> $SCRIPT
echo 'if [ "$namespace" == "wso2" ]; then' >> $SCRIPT
echo 'cat > $k8s_obj_file << "EOF"' >> $SCRIPT
cat kubernetes-basics/namespace.yaml >> $SCRIPT
echo -e "EOF\nfi" >> $SCRIPT

echo 'cat >> $k8s_obj_file << "EOF"'  >> $SCRIPT
cat kubernetes-basics/svcaccount.yaml >> $SCRIPT
if ! $IS_OPEN_SOURCE; then
  cat kubernetes-basics/secrets.yaml >> $SCRIPT
fi
cat kubernetes-apim-mysql/wso2apim-mysql-conf.yaml >> $SCRIPT
cat kubernetes-apim-mysql/wso2apim-mysql-service.yaml >> $SCRIPT
cat kubernetes-apim-mysql/wso2apim-mysql-deployment.yaml >> $SCRIPT
cat kubernetes-apim-analytics/dashboard/wso2am-pattern-1-analytics-dashboard-conf.yaml>> $SCRIPT
cat kubernetes-apim-analytics/dashboard/wso2am-pattern-1-analytics-dashboard-service.yaml >> $SCRIPT
cat kubernetes-apim-analytics/dashboard/wso2am-pattern-1-analytics-dashboard-deployment.yaml >> $SCRIPT
cat kubernetes-apim-analytics/worker/wso2apim-analytics-worker-conf.yaml >> $SCRIPT
cat kubernetes-apim-analytics/worker/wso2apim-analytics-worker-service.yaml >> $SCRIPT
cat kubernetes-apim-analytics/worker/wso2apim-analytics-worker-deployment.yaml >> $SCRIPT
cat kubernetes-apim/wso2apim-conf.yaml >> $SCRIPT
cat kubernetes-apim/wso2apim-service.yaml >> $SCRIPT
cat kubernetes-apim/wso2apim-deployment.yaml >> $SCRIPT

echo -e "EOF\n}\n" >> $SCRIPT

if $IS_OPEN_SOURCE; then
  cat funcs4opensource >> $SCRIPT
else
  cat funcs >> $SCRIPT
fi

cat >> $SCRIPT << "EOF"
arg=$1
if [[ -z $arg ]]; then
    echoBold "Expected parameter is missing\n"
    usage
else
    case $arg in
      -d|--deploy)
        deploy
        ;;
      -u|--undeploy)
        undeploy
        ;;
      -h|--help)
        usage
        ;;
      *)
        echoBold "Invalid parameter : $arg\n"
        usage
        ;;
    esac
fi
EOF
