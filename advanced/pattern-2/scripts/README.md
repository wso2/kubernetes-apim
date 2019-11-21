# Kubernetes Test Resources for deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager

Kubernetes Test Resources for [WSO2 API Manager deployment pattern 2](https://docs.wso2.com/display/AM260/Deployment+Patterns#DeploymentPatterns-Pattern2) contain artifacts,
which can be used to test the core Kubernetes resources provided for a deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager along with WSO2 API Manager Analytics support.

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (compatible with v1.10)
in order to run the steps provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).<br><br>

* A pre-configured Network File System (NFS) to be used as the persistent volume for artifact sharing and persistence.
In the NFS server instance, create a Linux system user account named `wso2carbon` with user id `802` and a system group named `wso2` with group id `802`.
Add the `wso2carbon` user to the group `wso2`.

  ```
  groupadd --system -g 802 wso2
  useradd --system -g 802 -u 802 wso2carbon
  ```

  > If you are using AKS(Azure Kubernetes Service) as the kubernetes provider, it is possible to use Azurefiles for persistent storage instead of an NFS. If doing so, skip this step.


## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository.<br>

##### 1. Clone the Kubernetes Resources for WSO2 API Manager Git repository.

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### 2. Deploy Kubernetes Ingress resources.

The WSO2 API Manager Kubernetes Ingress resource uses the NGINX Ingress Controller maintained by Kubernetes.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

##### 3. Setup a Network File System (NFS) to be used for persistent storage.

> If you are using AKS(Azure Kubernetes Service) as the kubernetes provider, it is possible to use Azurefiles for persistent storage instead of an NFS. If doing so, skip this step.

Create and export unique directories within the NFS server instance for each Kubernetes Persistent Volume resource defined in the
`<KUBERNETES_HOME>/advanced/pattern-2/volumes/persistent-volumes.yaml` file.

Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

```
sudo chown -R wso2carbon:wso2 <directory_name>
```

Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

```
chmod -R 700 <directory_name>
```

Update each Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported, NFS server directory path (`NFS_LOCATION_PATH`).

**Note**: By default, the deployment management script (i.e. `<KUBERNETES_HOME>/advanced/pattern-2/scripts/deploy.sh`) is configured to deploy WSO2 Identity Server as the Key Manager. 

##### 4. Setup product database(s).

For **evaluation purposes**,

* You can use Kubernetes resources provided in the directory `<KUBERNETES_HOME>/advanced/pattern-2/extras/rdbms/mysql`
for deploying the product databases, using MySQL in Kubernetes. However, this approach of product database deployment is
**not recommended** for a production setup.

* For using these Kubernetes resources,

  > If you are using AKS(Azure Kubernetes Service) as the kubernetes provider, it is possible to use Azurefiles for persistent storage instead of an NFS. If doing so, skip this step.

  Here, a Network File System (NFS) is needed to be used for persisting MySQL DB data.    
  
  Create and export a directory within the NFS server instance.
        
  Provide read-write-execute permissions to other users for the created folder.
        
  Update the Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported,
  NFS server directory path (`NFS_LOCATION_PATH`) in `<KUBERNETES_HOME>/advanced/pattern-2/extras/rdbms/volumes/persistent-volumes.yaml`.
    
In a **production grade setup**,

* Setup the external product databases. Please refer to WSO2 API Manager's [official documentation](https://docs.wso2.com/display/AM250/Installing+and+Configuring+the+Databases)
  on creating the required databases for the deployment.
  
  Provide appropriate connection URLs, corresponding to the created external databases and the relevant driver class names for the data sources defined in
  the following files:
  
    * `<KUBERNETES_HOME>/advanced/pattern-2/confs/apim-analytics/conf/worker/deployment.yaml`
    * `<KUBERNETES_HOME>/advanced/pattern-2/confs/apim-pub-store-tm-1/datasources/master-datasources.xml`
    * `<KUBERNETES_HOME>/advanced/pattern-2/confs/apim-pub-store-tm-2/datasources/master-datasources.xml`

    If you are using WSO2 API Manager's Key Manager profile, edit the following file.

    * `<KUBERNETES_HOME>/advanced/pattern-2/confs/apim-km/datasources/master-datasources.xml`

    Else, if you are using WSO2 Identity Server as Key Manager, edit the following file.

    * `<KUBERNETES_HOME>/advanced/pattern-2/confs/apim-is-as-km/datasources/master-datasources.xml`
  
  Please refer WSO2's [official documentation](https://docs.wso2.com/display/ADMIN44x/Configuring+master-datasources.xml) on configuring data sources.

##### 5. Deploy Kubernetes resources.

Change directory to `<KUBERNETES_HOME>/advanced/pattern-2/scripts` and execute the `deploy.sh` or kubernetes provider specific shell script on the terminal.

```
./deploy.sh
```
or
```
./azure-deploy.sh
```

**Note**:

* By default, the deployment management script (i.e. `<KUBERNETES_HOME>/advanced/pattern-2/scripts/deploy.sh`) is configured to deploy
WSO2 Identity Server as the Key Manager.

* If you desire to use WSO2 API Manager's Key Manager profile

    * Uncomment the following Kubernetes client commands in the deployment management script.
    
    ```
    # Kubernetes ConfigMaps for WSO2 API Manager's Key Manager profile
    ${KUBERNETES_CLIENT} create configmap apim-km-conf --from-file=../confs/apim-km/
    ${KUBERNETES_CLIENT} create configmap apim-km-conf-datasources --from-file=../confs/apim-km/datasources/
    
    ...
    
    # Kubernetes Service for WSO2 API Manager's Key Manager profile
    ${KUBERNETES_CLIENT} create -f ../apim-km/wso2apim-km-service.yaml
    
    ...
    
    # Kubernetes Deployment for WSO2 API Manager's Key Manager profile
    ${KUBERNETES_CLIENT} create -f ../apim-km/wso2apim-km-deployment.yaml
    ```
    
    * Comment out the following Kubernetes client commands in the deployment management script,
    to avoid the deployment of WSO2 Identity Server as Key Manager.
    
    ```
    # Kubernetes ConfigMaps for WSO2 Identity Server as Key Manager
    ${KUBERNETES_CLIENT} create configmap apim-is-as-km-conf --from-file=../confs/apim-is-as-km/
    ${KUBERNETES_CLIENT} create -f ../confs/apim-is-as-km/init/init.yaml
    ${KUBERNETES_CLIENT} create configmap apim-is-as-km-conf-axis2 --from-file=../confs/apim-is-as-km/axis2/
    ${KUBERNETES_CLIENT} create configmap apim-is-as-km-conf-datasources --from-file=../confs/apim-is-as-km/datasources/
    
    ...
    
    # Kubernetes Service for WSO2 Identity Server as Key Manager
    ${KUBERNETES_CLIENT} create -f ../apim-is-as-km/wso2apim-is-as-km-service.yaml
    
    ...
    
    # Kubernetes Deployment for WSO2 Identity Server as Key Manager
    ${KUBERNETES_CLIENT} create -f ../apim-is-as-km/wso2apim-is-as-km-deployment.yaml
    ```

>To un-deploy, be on the same directory and execute the `undeploy.sh` or kubernetes provider specific undeploy shell script on the terminal.

##### 6. Access Management Consoles.

Default deployment will expose `wso2apim` and `wso2apim-gateway` hosts.

To access the console in the environment,

a. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses.

  ```
  kubectl get ing
  ```

e.g.

```
NAME                                  HOSTS                    ADDRESS          PORTS      AGE
wso2apim-ingress                      wso2apim                 <EXTERNAL-IP>    80, 443    7m 
wso2apim-gateway-ingress              wso2apim-gateway         <EXTERNAL-IP>    80, 443    6m
```

b. Add the above host as an entry in `/etc/hosts` file as follows:

```
<EXTERNAL-IP>	wso2apim
<EXTERNAL-IP>	wso2apim-gateway
```

c. Try navigating to `https://wso2apim/carbon` from your favorite browser.

##### 7. Scale up the Key Manager and Gateway profiles.

Default deployment runs a single replica (or pod) of Key Manager profile and WSO2 API Manager Gateway.
To scale any of these profile deployments into any `<n>` number of container replicas, upon your requirement,
simply run `kubectl scale` Kubernetes client command on the terminal.

For example, the following command scales the WSO2 API Manager Gateway profile to the desired number of replicas.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/advanced/pattern-2/apim-gw/wso2apim-gateway-deployment.yaml
```

If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.