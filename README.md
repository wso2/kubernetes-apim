# WSO2 API Manager 2.1.0 Kubernetes/Openshift Resources 
*Kubernetes/Openshift Resources for container-based deployments of WSO2 API Manager (APIM)*

## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of 
[`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/) git repository. 

##### 1. Checkout WSO2 kubernetes-apim  repository using `git clone`:
```
git clone https://github.com/wso2/kubernetes-apim.git
git checkout tags/v2.1.0-1
```

##### 2. Pull required Docker images from [`WSO2 Docker Registry`](https://docker.wso2.com) using `docker pull`:
```
docker login docker.wso2.com

docker pull docker.wso2.com/sshd-kubernetes:1.0.0
docker pull docker.wso2.com/rsync-kubernetes:1.0.0
docker pull docker.wso2.com/wso2am-analytics-kubernetes:2.1.0
docker pull docker.wso2.com/wso2am-kubernetes:2.1.0
docker pull docker.wso2.com/apim-rdbms-kubernetes:2.1.0
```

> You can also build the docker images by following the guide in `KUBERNETES_HOME/base/README.md`. Same images can be used for Openshift.

##### 3. Copy the Images into Kubernetes/Openshift nodes or to a Registry:
Copy the required Docker images over to the Kubernetes Nodes (ex: use `docker save` to create a tar file of the 
required image, `scp` the tar file to each node, and then use `docker load` to load the image from the copied tar file 
on the nodes). Alternatively, if a private Docker registry is used, transfer the images there.

##### 4. Deploy Kubernetes/Openshift Resources:

* Deploy on Kubernetes 

    1. Create a namespace called wso2.
    ```
    kubectl create namespace wso2
    ```
    2. Create a service account called wso2svcacct in wso2 namespace.
    ```
    kubectl create serviceaccount wso2svcacct -n wso2
    ```
    3. Deploy any pattern by running `deploy-kubernetes.sh` script inside pattern folder (KUBERNETES_HOME/pattern-X/).
    ```
    ./deploy-kubernetes.sh
    ```
    4. Access Management Console 
       Using the following command to list ingresses in the deployment.
        ```
        kubectl get ingress
        ```
        Add relevant hosts and IP addresses to /etc/hosts file.
        
        > Sample Access URLs (This will vary based on the pattern)   
        > https://wso2apim  
        > https://wso2apim-analytics  
        > https://wso2apim-gw  

    5. Undeploy any pattern by running `undeploy-kubernetes.sh` script inside pattern folder (KUBERNETES_HOME/pattern-X/).
    ```
    ./undeploy-kubernetes.sh
    ```

* Deploy on Openshift

    1. Create a user called admin and assign the cluster-admin role. (Cluster-admin user is used to deploy openshift artifacts)
    ```
    oc login -u system:admin
    oc create user admin --full-name=admin
    oc adm policy add-cluster-role-to-user cluster-admin admin
    ```
    2. Create a new project called wso2.
    ```
    oc new-project wso2 --description="WSO2 API Manager 2.1.0" --display-name="wso2"
    ```
        
    3. Create a service account called wso2svcacct in wso2 project and assign anyuid security context constraint.
    ```
    oc create serviceaccount wso2svcacct
    oc adm policy add-scc-to-user anyuid -z wso2svcacct -n wso2
    ```
    4. Deploy any pattern by running `deploy-openshift.sh` script inside pattern folder (KUBERNETES_HOME/pattern-X/).
    ```
    ./deploy-openshift.sh
    ```
    5. Access Management Console 
       Using the following command to list the routes in the deployment.
        ```
        oc get routes
        ```
        Add relevant hosts and IP addresses to /etc/hosts file.
        
        > Sample Access URLs (This will vary based on the pattern)  
        > https://wso2apim  
        > https://wso2apim-analytics  
        > https://wso2apim-gw  

    6. Undeploy any pattern by running `undeploy-openshift.sh` script inside pattern folder (KUBERNETES_HOME/pattern-X/).
    ```
    ./undeploy-openshift.sh
    ```
 <br>
 

> Tested in OpenShift v3.6.0 and Kubernetes v1.6.1
