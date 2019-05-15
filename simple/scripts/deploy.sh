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
#set -o xtrace

# bash variables
k8s_obj_file="deployment.yaml"; NODE_IP=''; str_sec=""

# wso2 subscription variables
WUMUsername=''; WUMPassword=''

: ${namespace:="wso2"}
: ${randomPort:=true}; : ${NP_1:=30443}; : ${NP_2:=30243}

# testgrid directory
OUTPUT_DIR=$4; INPUT_DIR=$2; TG_PROP="$INPUT_DIR/infrastructure.properties"

# bash functions
function usage(){
  echo "Usage: "
  echo -e "-d, --deploy     Deploy WSO2 API Manager"
  echo -e "-u, --undeploy   Undeploy WSO2 API Manager"
  echo -e "-h, --help       Display usage instrusctions"
}

function undeploy(){
  echoBold "Undeploying WSO2 API Manager ... \n"
  kubectl delete -f deployment.yaml
  exit 0
}

function echoBold () {
    echo -en  $'\e[1m'"${1}"$'\e[0m'
}

function display_msg(){
    msg=$@
    echoBold "${msg}"
    exit 1
}

function st(){
  cycles=${1}
  i=0
  while [[ i -lt $cycles ]]
  do
    echoBold "* "
    let "i=i+1"
  done
}

function sp(){
  cycles=${1}
  i=0
  while [[ i -lt $cycles ]]
  do
    echoBold " "
    let "i=i+1"
  done
}

function product_name(){
  #wso2apim
  echo -e "\n"
  st 1; sp 8; st 1; sp 2; sp 1; st 3; sp 3; sp 2; st 3; sp 4; sp 1; st 3; sp 3; sp 8; sp 2; st 3; sp 1; sp 3; st 3; sp 3; st 5; sp 2; st 1; sp 8; st 1;echo ""
  st 1; sp 8; st 1; sp 2; st 1; sp 4; st 1; sp 2; st 1; sp 6; st 1; sp 2; st 1; sp 4; st 1; sp 2; sp 8; sp 1; st 1; sp 4; st 1; sp 3; st 1; sp 4; st 1; sp 2; sp 3; st 1; sp 6; st 2; sp 4; st 2;echo ""
  st 1; sp 3; st 1; sp 3; st 1; sp 2; st 1; sp 8; st 1; sp 6; st 1; sp 2; sp 6; st 1; sp 2; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp 4; st 1; sp 2; sp 3; st 1; sp 6; st 1; sp 1; st 1; sp 2; st 1; sp 1; st 1; echo ""
  st 1; sp 2; st 1; st 1; sp 2; st 1; sp 2; sp 1; st 3; sp 3; st 1; sp 6; st 1; sp 2; sp 4; st 1; sp 4; st 3; sp 2; st 5; sp 2; st 3; sp 3; sp 4; st 1; sp 6; st 1; sp 2; st 2; sp 2; st 1;  echo ""
  st 1; sp 1; st 1; sp 2; st 1; sp 1; st 1; sp 2; sp 6; st 1; sp 2; st 1; sp 6; st 1; sp 2; sp 2; st 1; sp 6; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp  7; sp 4; st 1; sp 6; st 1; sp 3; st 1; sp 3; st 1;  echo ""
  st 2; sp 4; st 2; sp 2; st 1; sp 4; st 1; sp 2; st 1; sp 6; st 1; sp 2; st 1; sp 8; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp 7; sp 4; st 1; sp 6; st 1; sp 8; st 1;  echo ""
  st 1; sp 8; st 1; sp 2; sp 1; st 3; sp 3; sp 2; st 3; sp 4; st 4; sp 2; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp 7; st 5; sp 2; st 1; sp 8; st 1;  echo -e "\n"
}

function get_creds(){
  while [[ -z "$WUMUsername" ]]
  do
        read -p "$(echoBold "Enter your WSO2 subscription username: ")" WUMUsername
        if [[ -z "$WUMUsername" ]]
        then
           echo "wso2-subscription-username cannot be empty"
        fi
  done
  while [[ -z "$WUMPassword" ]]
  do
        read -sp "$(echoBold "Enter your WSO2 subscription password: ")" WUMPassword
        echo ""
        if [[ -z "$WUMPassword" ]]
        then
          echo "wso2-subscription-password cannot be empty"
        fi
  done
}

function validate_ip(){
    ip_check=$1
    if [[ $ip_check =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      IFS='.'
      ip=$ip_check
      set -- $ip
      if [[ $1 -le 255 ]] && [[ $2 -le 255 ]] && [[ $3 -le 255 ]] && [[ $4 -le 255 ]]; then
        IFS=''
        NODE_IP=$ip_check
      else
        IFS=''
        echo "Invalid IP. Please try again."
        NODE_IP=""
      fi
    else
      echo "Invalid IP. Please try again."
      NODE_IP=""
    fi
}

function get_node_ip(){
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}')
  if [[ -z $NODE_IP ]]
  then
      if [[ $(kubectl config current-context)="minikube" ]]
      then
          NODE_IP=$(minikube ip)
      else
        echo "We could not find your cluster node-ip."
        while [[ -z "$NODE_IP" ]]
        do
              read -p "$(echo "Enter one of your cluster Node IPs to provision instant access to server: ")" NODE_IP
              if [[ -z "$NODE_IP" ]]
              then
                echo "cluster node ip cannot be empty"
              else
                validate_ip $NODE_IP
              fi
        done
      fi
  fi
  set -- $NODE_IP; NODE_IP=$1
}

function get_nodePorts(){
  LOWER=30000; UPPER=32767;
  if [ "$randomPort" == "True" ]; then
    NP_1=0; NP_2=0;
    while [ $NP_1 -lt $LOWER ] || [ $NP_2 -lt $LOWER ]
    do
      NP_1=$RANDOM; NP_2=$RANDOM
      let "NP_1 %= $UPPER"; let "NP_2 %= $UPPER"
    done
  fi
  echo -e "[INFO] nodePorts  are set to $NP_1 and $NP_2"
}

function create_yaml(){
    echo "starting"
cat > $k8s_obj_file << "EOF"
EOF
    echo "starting->phase 1"
    if [ "$namespace" == "wso2" ]; then
      echo "step0"
      cat ../pre-req/wso2-namespace.yaml >> $k8s_obj_file
    fi
    echo "step1"
    cat ../pre-req/wso2-secret.yaml >> $k8s_obj_file
    echo "step2"
    cat ../pre-req/wso2-serviceaccount.yaml >> $k8s_obj_file
    cat ../configmaps/apim-conf.yaml >> $k8s_obj_file
    cat ../configmaps/apim-conf-datasources.yaml >> $k8s_obj_file
    cat ../configmaps/apim-analytics-conf-worker.yaml >> $k8s_obj_file
    cat ../configmaps/mysql-dbscripts.yaml >> $k8s_obj_file
    cat ../mysql/mysql-service.yaml >> $k8s_obj_file
    cat ../apim-analytics/wso2apim-analytics-service.yaml >> $k8s_obj_file
    cat ../apim/wso2apim-service.yaml >> $k8s_obj_file
    cat ../mysql/mysql-deployment.yaml >> $k8s_obj_file
    cat ../apim-analytics/apim-analytics-deployment.yaml >> $k8s_obj_file
    cat ../apim/wso2apim-deployment.yaml >> $k8s_obj_file
}

function progress_bar(){

  dep_status=$(kubectl get deployments -n wso2 -o jsonpath='{.items[?(@.spec.selector.matchLabels.product=="wso2am")].status.conditions[?(@.type=="Available")].status}')
  pod_status=$(kubectl get pods -n wso2 -o jsonpath='{.items[?(@.metadata.labels.product=="wso2am")].status.conditions[*].status}')

  num_true_const=0; progress_unit="";num_true=0; time_proc=0;

  arr_dep=($dep_status); arr_pod=($pod_status)

  let "length_total= ${#arr_pod[@]} + ${#arr_dep[@]}";

  echo ""

  while [[ $num_true -lt $length_total ]]
  do

      sleep 4

      num_true=0
      dep_status=$(kubectl get deployments -n wso2 -o jsonpath='{.items[?(@.spec.selector.matchLabels.product=="wso2am")].status.conditions[?(@.type=="Available")].status}')
      pod_status=$(kubectl get pods -n wso2 -o jsonpath='{.items[?(@.metadata.labels.product=="wso2am")].status.conditions[*].status}')

      arr_dep=($dep_status); arr_pod=($pod_status); let "length_total= ${#arr_pod[@]} + ${#arr_dep[@]}";

      for ele_dep in $dep_status
      do
          if [ "$ele_dep" = "True" ]
          then
              let "num_true=num_true+1"
          fi
      done

      for ele_pod in $pod_status
      do
          if [ "$ele_pod" = "True" ]
          then
              let "num_true=num_true+1"
          fi
      done

      printf "Processing WSO2 API Manager ... |"

      printf "%-$((5 * ${length_total-1}))s| $(($num_true_const * 100/ $length_total))"; echo -en ' % \r'

      printf "Processing WSO2 API Manager ... |"
      s=$(printf "%-$((5 * ${num_true_const}))s" "H")
      echo -en "${s// /H}"

      printf "%-$((5 * $(($length_total - $num_true_const))))s| $((100 * $(($num_true_const))/ $length_total))"; echo -en ' %\r '

      if [ $num_true -ne $num_true_const ]
      then
          i=0
          while [[ $i -lt  $((5 * $((${num_true} - ${num_true_const})))) ]]
          do
              let "i=i+1"
              progress_unit=$progress_unit"H"
              printf "Processing WSO2 API Manager ... |"
              echo -n $progress_unit
              printf "%-$((5 * $((${length_total} - ${num_true_const})) - $i))s| $(($(( 100 * $(($num_true_const))/ $length_total)) +  $((20 * $i/$length_total)) ))"; echo -en ' %\r '
              sleep 0.25
          done
          num_true_const=$num_true
          time_proc=0
        else
            let "time_proc=time_proc + 5"
      fi

      printf "Processing WSO2 API Manager ... |"

      printf "%-$((5 * ${length_total-1}))s| $(($num_true_const * 100/ $length_total))"; echo -en ' %\r '

      printf "Processing WSO2 API Manager ... |"
      s=$(printf "%-$((5 * ${num_true_const}))s" "H")
      echo -en "${s// /H}"

      printf "%-$((5 * $(($length_total - $num_true_const))))s| $((100 * $(($num_true_const))/ $length_total))"; echo -en ' %\r '

      sleep 1

      if [[ $time_proc -gt 250 ]]
      then
          echoBold "\n\nSomething went wrong! Please Follow < FAQ-Link > for more information\n"
          exit 2
      fi

  done

  echo -e "\n"

}

function deploy(){
    #checking for required command line tools
    if [[ ! $(which kubectl) ]]
    then
       display_msg "Please install Kubernetes command-line tool (kubectl) before you start with the setup\n"
    fi

    if [[ ! $(which base64) ]]
    then
       display_msg "Please install base64 before you start with the setup\n"
    fi

    echoBold "Checking for an enabled cluster... Your patience is appreciated... "
    cluster_isReady=$(kubectl cluster-info) > /dev/null 2>&1  || true

    if [[ ! $cluster_isReady == *"KubeDNS"* ]]
    then
        display_msg "\nPlease enable your cluster before running the setup.\n\nIf you don't have a kubernetes cluster, follow: https://kubernetes.io/docs/setup/\n\n"
    fi

    echoBold "Done\n"

    #displaying wso2 product name
    product_name

    # check if testgrid
    if test -f $TG_PROP; then
      source $TG_PROP
    else
      get_creds
    fi

    echo $namespace

    # get node-ip
    get_node_ip

    # create and encode username/password pair
    auth="$WUMUsername:$WUMPassword"
    authb64=`echo -n $auth | base64`

    # create authorisation code
    authstring='{"auths":{"docker.wso2.com":{"username":"'${WUMUsername}'","password":"'${WUMPassword}'","email":"'${WUMUsername}'","auth":"'${authb64}'"}}}'

    # encode in base64
    secdata=`echo -n $authstring | base64`

    for i in $secdata; do
      str_sec=$str_sec$i
    done

    get_nodePorts

    echo "creating yaml"
    # create kubernetes object yaml
    create_yaml

    sed -i '' 's/"$ns.k8s.&.wso2.apim"/'$namespace'/g' $k8s_obj_file
    sed -i '' 's/"$string.&.secret.auth.data"/'$secdata'/g' $k8s_obj_file
    sed -i '' 's/"ip.node.k8s.&.wso2.apim"/'$NODE_IP'/g' $k8s_obj_file
    sed -i '' 's/"$nodeport.k8s.&.1.wso2apim"/'$NP_1'/g' $k8s_obj_file
    sed -i '' 's/"$nodeport.k8s.&.1.wso2apim"/'$NP_2'/g' $k8s_obj_file


    if ! test -f $TG_PROP; then
        echoBold "\nDeploying WSO2 API Manager ....\n"

        # Deploy wso2am
        #kubectl create -f $k8s_obj_file

        # waiting until deployment is ready
        #progress_bar
        echoBold "Successfully deployed WSO2 API Manager.\n\n"

        echoBold "1. Try navigating to https://$NODE_IP:30443/carbon/ from your favourite browser using \n"
        echoBold "\tusername: admin\n"
        echoBold "\tpassword: admin\n"
        echoBold "2. Follow <getting-started-link> to start using WSO2 API Manager.\n\n"
    fi
}

deploy
