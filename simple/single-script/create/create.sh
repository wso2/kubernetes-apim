#!/bin/bash

IS_OPEN_SOURCE=TRUE

if $IS_OPEN_SOURCE; then
  SCRIPT="../wso2am-ga.sh"
else
  SCRIPT="../wso2am-latest.sh"
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
k8s_obj_file="deployment.yaml"; NODE_IP=''; str_sec=""

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
: ${randomPort:="False"}; : ${NP_1:=30443}; : ${NP_2:=30243}

# testgrid directory
OUTPUT_DIR=$4; INPUT_DIR=$2

EOF

echo "function create_yaml(){" >> $SCRIPT
echo 'cat > $k8s_obj_file << "EOF"' >> $SCRIPT
echo 'EOF' >> $SCRIPT
echo 'if [ "$namespace" == "wso2" ]; then' >> $SCRIPT
echo 'cat > $k8s_obj_file << "EOF"' >> $SCRIPT
cat ../../pre-req/wso2-namespace.yaml >> $SCRIPT
echo -e "EOF\nfi" >> $SCRIPT

echo 'cat >> $k8s_obj_file << "EOF"'  >> $SCRIPT
cat ../../pre-req/wso2-serviceaccount.yaml >> $SCRIPT
if ! $IS_OPEN_SOURCE; then
  cat ../../pre-req/wso2-secret.yaml >> $SCRIPT
fi
cat ../../configmaps/apim-conf.yaml >> $SCRIPT
cat ../../configmaps/apim-conf-datasources.yaml >> $SCRIPT
cat ../../configmaps/apim-analytics-conf-worker.yaml >> $SCRIPT
cat ../../configmaps/mysql-dbscripts.yaml >> $SCRIPT
cat ../../mysql/mysql-service.yaml >> $SCRIPT
cat ../../apim-analytics/apim-analytics-service.yaml >> $SCRIPT
cat ../../apim/wso2apim-service.yaml >> $SCRIPT
cat ../../mysql/mysql-deployment.yaml >> $SCRIPT
cat ../../apim-analytics/apim-analytics-deployment.yaml >> $SCRIPT
cat ../../apim/wso2apim-deployment.yaml >> $SCRIPT

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
