docker tag ${1}:2.1.0 docker.wso2.com/${1}:2.1.0
gcloud docker -- push docker.wso2.com/${1}:2.1.0

