# Kubernetes Test Resources for deployment of WSO2 API Manager with WSO2 API Manager Analytics

Kubernetes Test Resources for [WSO2 API Manager deployment pattern 1](https://docs.wso2.com/display/AM260/Deployment+Patterns#DeploymentPatterns-Pattern1) contain artifacts,
which can be used to test the core Kubernetes resources provided for a scalable deployment of WSO2 API Manager with WSO2 API Manager Analytics support.

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* In order to use WSO2 Kubernetes resources, you need an active WSO2 subscription. If you do not possess an active
WSO2 subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).<br><br>

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

## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository.<br>

##### 1. Clone the Kubernetes Resources for WSO2 API Manager Git repository.

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### 2. Deploy Kubernetes Ingress resource.

The WSO2 API Manager Kubernetes Ingress resource uses the NGINX Ingress Controller.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

##### 3. Setup a Network File System (NFS) to be used for persistent storage.

Create and export unique directories within the NFS server instance for each Kubernetes Persistent Volume resource defined in the
`<KUBERNETES_HOME>/pattern-1/volumes/persistent-volumes.yaml` file.

Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

```
sudo chown -R wso2carbon:wso2 <directory_name>
```

Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

```
chmod -R 700 <directory_name>
```

Update each Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported, NFS server directory path (`NFS_LOCATION_PATH`).

##### 4. Setup product database(s).

For **evaluation purposes**,

* You can use Kubernetes resources provided in the directory `<KUBERNETES_HOME>/pattern-1/extras/rdbms/mysql`
for deploying the product databases, using MySQL in Kubernetes. However, this approach of product database deployment is
**not recommended** for a production setup.

* For using these Kubernetes resources,

  Here, a Network File System (NFS) is needed to be used for persisting MySQL DB data.    
  
  Create and export a directory within the NFS server instance.
        
  Provide read-write-execute permissions to other users for the created folder.
        
  Update the Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported,
  NFS server directory path (`NFS_LOCATION_PATH`) in `<KUBERNETES_HOME>/pattern-1/extras/rdbms/volumes/persistent-volumes.yaml`.
    
In a **production grade setup**,

* Setup the external product databases. Please refer to WSO2 API Manager's [official documentation](https://docs.wso2.com/display/AM260/Installing+and+Configuring+the+Databases)
  on creating the required databases for the deployment.
  
  Provide appropriate connection URLs, corresponding to the created external databases and the relevant driver class names for the data sources defined in
  the following files:
  
  * `<KUBERNETES_HOME>/pattern-1/confs/apim/datasources/master-datasources.xml`
  * `<KUBERNETES_HOME>/pattern-1/confs/apim-analytics/conf/worker/deployment.yml`
  
  Please refer WSO2's [official documentation](https://docs.wso2.com/display/ADMIN44x/Configuring+master-datasources.xml) on configuring data sources.

##### 5. Deploy Kubernetes resources.

Change directory to `<KUBERNETES_HOME>/pattern-1/scripts` and execute the `deploy.sh` shell script on the terminal, with the appropriate configurations as follows:

```
./deploy.sh --wso2-username=<WSO2_USERNAME> --wso2-password=<WSO2_PASSWORD> --cluster-admin-password=<K8S_CLUSTER_ADMIN_PASSWORD>
```

* A Kubernetes Secret named `wso2creds` in the cluster to authenticate with the [`WSO2 Docker Registry`](https://docker.wso2.com), to pull the required images.
The following details need to be replaced in the relevant command.

`WSO2_USERNAME`: Your WSO2 username<br>
`WSO2_PASSWORD`: Your WSO2 password

* A Kubernetes role and a role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme.

`K8S_CLUSTER_ADMIN_PASSWORD`: Kubernetes cluster admin password

>To un-deploy, be on the same directory and execute the `undeploy.sh` shell script on the terminal.

##### 6. Access Management Consoles.

Default deployment will expose `wso2apim`, `wso2apim-gateway` and `wso2apim-analytics` hosts.

To access the console in the environment,

1. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses (using `kubectl get ing`).

e.g.

```
NAME                                             HOSTS                       ADDRESS         PORTS     AGE
wso2apim-with-analytics-apim-analytics-ingress   wso2apim-analytics          <EXTERNAL-IP>   80, 443   6m
wso2apim-with-analytics-apim-ingress             wso2apim,wso2apim-gateway   <EXTERNAL-IP>   80, 443   7m
```

2. Add the above host as an entry in /etc/hosts file as follows:

```
<EXTERNAL-IP>	wso2apim-analytics
<EXTERNAL-IP>	wso2apim
<EXTERNAL-IP>	wso2apim-gateway
```

3. Try navigating to `https://wso2apim/carbon` and `https://wso2apim-analytics/carbon` from your favorite browser.

##### 7. Scale up using `kubectl scale`.

Default deployment runs a single replica (or pod) of WSO2 API Manager. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/pattern-1/apim/wso2apim-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
    