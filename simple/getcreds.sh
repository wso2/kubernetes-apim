#!/bin/bash

set -e

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script creates the base64 encoded authorisation code in kubernetes secrets for WSO2 Identity Server \n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
    echoBold "--wp | --wso2-password\t\tYour WSO2 password"
    echoBold "--cap | --cluster-admin-password\tKubernetes cluster admin password\n\n"
}

WSO2_SUBSCRIPTION_USERNAME=''
WSO2_SUBSCRIPTION_PASSWORD=''
ADMIN_PASSWORD=''

# capture named arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`

    case ${PARAM} in
        -h | --help)
            usage
            exit 1
            ;;
        --wu | --wso2-username)
            WSO2_SUBSCRIPTION_USERNAME=${VALUE}
            ;;
        --wp | --wso2-password)
            WSO2_SUBSCRIPTION_PASSWORD=${VALUE}
            ;;
        --cap | --cluster-admin-password)
            ADMIN_PASSWORD=${VALUE}
            ;;
        *)
            echoBold "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

# create and encode username/password pair
auth="$WSO2_SUBSCRIPTION_USERNAME:$WSO2_SUBSCRIPTION_PASSWORD"
authb64=`echo -n $auth | base64`

# create authorisation code
authstring='{"auths":{"docker.wso2.com": {"username":"'$WSO2_SUBSCRIPTION_USERNAME'","password":"'$WSO2_SUBSCRIPTION_PASSWORD'","email":"'$WSO2_SUBSCRIPTION_USERNAME'","auth":"'$authb64'"}}}'

# encode in base64
secdata=`echo -n $authstring | base64`

# add the code to deployment.yaml
sed -i -e 's/"wso2.secret&auth.base64"/'$secdata'/g' deployment.yaml

# deploy WSO2 Identity Server in kubernetes
${KUBECTL} create -f deployment.yaml
