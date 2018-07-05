# Kubernetes Resources for deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager

Core Kubernetes resources for WSO2 API Manager deployment pattern 2. This consists of a deployment of WSO2 API Manager with
a separate Gateway and a separate Key Manager along with WSO2 API Manager Analytics support.

![WSO2 API Manager pattern 2 deployment](pattern-2.png)

## Prerequisites

* In order to use WSO2 Kubernetes resources, you need an active WSO2 subscription. If you do not possess an active WSO2
subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
in order to run the steps provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/)<br><br>

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

##### 2. Create a namespace named `wso2` and a service account named `wso2svc-account`, within the namespace `wso2`.

```
kubectl create namespace wso2
kubectl create serviceaccount wso2svc-account -n wso2
```

Then, switch the context to new `wso2` namespace from `default` namespace.

```
kubectl config set-context $(kubectl config current-context) --namespace=wso2
```

##### 3. Create a Kubernetes Secret for pulling the required Docker images from [`WSO2 Docker Registry`](https://docker.wso2.com).

Create a Kubernetes Secret named `wso2creds` in the cluster to authenticate with the WSO2 Docker Registry, to pull the required images.

```
kubectl create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=<WSO2_USERNAME> --docker-password=<WSO2_PASSWORD> --docker-email=<WSO2_USERNAME>
```

`WSO2_USERNAME`: Your WSO2 username<br>
`WSO2_PASSWORD`: Your WSO2 password

Please see [Kubernetes official documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-in-the-cluster-that-holds-your-authorization-token)
for further details.

##### 4. Setup product database(s).

Setup the external product databases. Please refer to WSO2 API Manager's [official documentation](https://docs.wso2.com/display/AM250/Installing+and+Configuring+the+Databases)
on creating the required databases for the deployment.

Provide appropriate connection URLs, corresponding to the created external databases and the relevant driver class names for the data sources defined in
the following files:

* `<KUBERNETES_HOME>/pattern-2/confs/apim-analytics/datasources/analytics-datasources.xml`
* `<KUBERNETES_HOME>/pattern-2/confs/apim-analytics/datasources/master-datasources.xml`
* `<KUBERNETES_HOME>/pattern-2/confs/apim-analytics/datasources/stats-datasources.xml`
* `<KUBERNETES_HOME>/pattern-2/confs/apim-gateway/datasources/master-datasources.xml`
* `<KUBERNETES_HOME>/pattern-2/confs/apim-km/datasources/master-datasources.xml`
* `<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-1/datasources/master-datasources.xml`
* `<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-2/datasources/master-datasources.xml`

Please refer WSO2's [official documentation](https://docs.wso2.com/display/ADMIN44x/Configuring+master-datasources.xml) on configuring data sources.

**Note**:

* For **evaluation purposes**, you can use Kubernetes resources provided in the directory<br>
`<KUBERNETES_HOME>/pattern-2/extras/rdbms/mysql` for deploying the product databases, using MySQL in Kubernetes. However, this approach of product database deployment is
**not recommended** for a production setup.

* For using these Kubernetes resources,

    first create a Kubernetes ConfigMap for passing database script(s) to the deployment.
    
    ```
    kubectl create configmap mysql-dbscripts --from-file=<KUBERNETES_HOME>/pattern-2/extras/confs/mysql/dbscripts/
    ```
    
    Here, a Network File System (NFS) is needed to be used for persisting MySQL DB data.
    
    Create and export a directory within the NFS server instance.
    
    Provide read-write-execute permissions to other users for the created folder.
    
    Update the Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported,
    NFS server directory path (`NFS_LOCATION_PATH`) in `<KUBERNETES_HOME>/pattern-2/extras/rdbms/volumes/persistent-volumes.yaml`.
    
    Deploy the persistent volume resource and volume claim as follows:
    
    ```
    kubectl create -f <KUBERNETES_HOME>/pattern-2/extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
    kubectl create -f <KUBERNETES_HOME>/pattern-2/extras/rdbms/volumes/persistent-volumes.yaml
    ```

    Then, create a Kubernetes service (accessible only within the Kubernetes cluster), followed by the MySQL Kubernetes deployment, as follows:
    
    ```
    kubectl create -f <KUBERNETES_HOME>/pattern-2/extras/rdbms/mysql/mysql-service.yaml
    kubectl create -f <KUBERNETES_HOME>/pattern-2/extras/rdbms/mysql/mysql-deployment.yaml
    ```
    
##### 5. Create a Kubernetes role and a role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme.

```
kubectl create --username=admin --password=<K8S_CLUSTER_ADMIN_PASSWORD> -f <KUBERNETES_HOME>/rbac/rbac.yaml
```

`K8S_CLUSTER_ADMIN_PASSWORD`: Kubernetes cluster admin password

##### 6. Setup a Network File System (NFS) to be used for persistent storage.

Create and export unique directories within the NFS server instance for each Kubernetes Persistent Volume resource defined in the
`<KUBERNETES_HOME>/pattern-2/volumes/persistent-volumes.yaml` file.

Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

```
sudo chown -R wso2carbon:wso2 <directory_name>
```

Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

```
chmod -R 700 <directory_name>
```

Update each Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported, NFS server directory path (`NFS_LOCATION_PATH`).

Then, deploy the persistent volume resource and volume claim as follows:

```
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-analytics/wso2apim-analytics-volume-claims.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-gw/wso2apim-gateway-volume-claim.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/volumes/persistent-volumes.yaml
```
    
##### 7. Create Kubernetes ConfigMaps for passing WSO2 product configurations into the Kubernetes cluster.

```
kubectl create configmap apim-gateway-conf --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-gateway/
kubectl create configmap apim-gateway-conf-axis2 --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-gateway/axis2/
kubectl create configmap apim-gateway-conf-datasources --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-gateway/datasources/
kubectl create configmap apim-gateway-conf-identity --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-gateway/identity/

kubectl create configmap apim-analytics-conf --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-analytics/
kubectl create configmap apim-analytics-conf-datasources --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-analytics/datasources/

kubectl create configmap apim-pubstore-tm-1-conf --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-1/
kubectl create configmap apim-pubstore-tm-1-conf-axis2 --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-1/axis2/
kubectl create configmap apim-pubstore-tm-1-conf-datasources --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-1/datasources/
kubectl create configmap apim-pubstore-tm-1-conf-identity --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-1/identity/
kubectl create configmap apim-pubstore-tm-2-conf --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-2/
kubectl create configmap apim-pubstore-tm-2-conf-axis2 --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-2/axis2/
kubectl create configmap apim-pubstore-tm-2-conf-datasources --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-2/datasources/
kubectl create configmap apim-pubstore-tm-2-conf-identity --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-pubstore-tm-2/identity/

kubectl create configmap apim-km-conf --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-km/
kubectl create configmap apim-km-conf-axis2 --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-km/axis2/
kubectl create configmap apim-km-conf-datasources --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-km/datasources/
kubectl create configmap apim-km-conf-identity --from-file=<KUBERNETES_HOME>/pattern-2/confs/apim-km/identity/
```

##### 8. Create Kubernetes Services and Deployments for WSO2 API Manager and Analytics.

```
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-pubstore-tm/wso2apim-pubstore-tm-1-service.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-pubstore-tm/wso2apim-pubstore-tm-2-service.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-pubstore-tm/wso2apim-service.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-km/wso2apim-km-service.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-gw/wso2apim-gateway-service.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-analytics/wso2apim-analytics-service.yaml

kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-analytics/wso2apim-analytics-deployment.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-pubstore-tm/wso2apim-pubstore-tm-1-deployment.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-pubstore-tm/wso2apim-pubstore-tm-2-deployment.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-km/wso2apim-km-deployment.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/apim-gw/wso2apim-gateway-deployment.yaml
```

##### 9. Deploy Kubernetes Ingress resource.

The WSO2 API Manager Kubernetes Ingress resource uses the NGINX Ingress Controller.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

Finally, deploy the WSO2 API Manager Kubernetes Ingress resources as follows:

```
kubectl create -f <KUBERNETES_HOME>/pattern-2/ingresses/wso2apim-gateway-ingress.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/ingresses/wso2apim-ingress.yaml
kubectl create -f <KUBERNETES_HOME>/pattern-2/ingresses/wso2apim-analytics-ingress.yaml
```

##### 10. Access Management Consoles.

Default deployment will expose `wso2apim`, `wso2apim-gateway` and `wso2apim-analytics` hosts.

To access the console in the environment,

1. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses (using `kubectl get ing`).

e.g.

```
NAME                                  HOSTS                    ADDRESS          PORTS      AGE
wso2apim-ingress                      wso2apim                 <EXTERNAL-IP>    80, 443    7m 
wso2apim-analytics-ingress            wso2apim-analytics       <EXTERNAL-IP>    80, 443    7m
wso2apim-gateway-ingress              wso2apim-gateway         <EXTERNAL-IP>    80, 443    6m
```

2. Add the above host as an entry in /etc/hosts file as follows:

```
<EXTERNAL-IP>	wso2apim-analytics
<EXTERNAL-IP>	wso2apim
<EXTERNAL-IP>	wso2apim-gateway
```

3. Try navigating to `https://wso2apim/carbon` and `https://wso2apim-analytics/carbon` from your favorite browser.

##### 11. Scale up using `kubectl scale`.

Default deployment runs a single replica (or pod) of WSO2 API Manager Gateway. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/pattern-2/apim-gw/wso2apim-gateway-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
