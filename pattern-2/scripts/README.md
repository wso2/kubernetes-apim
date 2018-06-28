# Kubernetes Test Resources for deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager

Kubernetes Test Resources for WSO2 API Manager pattern 2 contain artifacts, which can be used to test the core
Kubernetes resources provided for a deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager
along with WSO2 API Manager Analytics support.

## Prerequisites

* In order to use WSO2 Kubernetes resources, you need an active WSO2 subscription. If you do not possess an active WSO2
subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Docker](https://www.docker.com/get-docker)
(version 17.09.0 or above) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
in order to run the steps provided<br>in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/)<br><br>
 
## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository.<br>

##### 1. Checkout Kubernetes Resources for WSO2 API Manager Git repository:

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### 2. Deploy Kubernetes Ingress resource:

The WSO2 API Manager Kubernetes Ingress resource uses the NGINX Ingress Controller.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

##### 3. Setup a Network File System (NFS) to be used as the persistent volume for artifact sharing across API Manager and Analytics instances.

Update the NFS server IP (`NFS_SERVER_IP`) and export path (`NFS_LOCATION_PATH`) of persistent volume resources,

* `wso2apim-gateway-server-pv`
* `wso2apim-analytics-data-pv`
* `wso2apim-analytics-pv`

in `<KUBERNETES_HOME>/pattern-2/volumes/persistent-volumes.yaml` file.

Create a user named `wso2carbon` with user id `802` and a group named `wso2` with group id `802` in the NFS node.
Add `wso2carbon` user to the group `wso2`.

Then, provide ownership of the exported folder `NFS_LOCATION_PATH` (used for artifact sharing) to `wso2carbon` user and `wso2` group.
And provide read-write-executable permissions to owning `wso2carbon` user, for the folder `NFS_LOCATION_PATH`.

Finally, setup a Network File System (NFS) to be used as the persistent volume for persisting MySQL DB data.
Provide read-write-executable permissions to `other` users, for the folder `NFS_LOCATION_PATH`.
Update the NFS server IP (`NFS_SERVER_IP`) and export path (`NFS_LOCATION_PATH`) of persistent volume resource
named `wso2apim-pattern-2-rdbms-pv` in the file `<KUBERNETES_HOME>/pattern-2/extras/rdbms/volumes/persistent-volumes.yaml`.
  
##### 4. Deploy Kubernetes resources:

Change directory to `KUBERNETES_HOME/pattern-2/scripts` and execute the `deploy.sh` shell script on the terminal, with the appropriate configurations as follows:

```
./deploy.sh --wso2-subscription-username=<WSO2_USERNAME> --wso2-subscription-password=<WSO2_PASSWORD> --cluster-admin-password=<K8S_CLUSTER_ADMIN_PASSWORD>
```

* A Kubernetes Secret named `wso2creds` in the cluster to authenticate with the [`WSO2 Docker Registry`](https://docker.wso2.com), to pull the required images.
The following details need to be replaced in the relevant command.

`WSO2_USERNAME`: Your WSO2 username<br>
`WSO2_PASSWORD`: Your WSO2 password

* A Kubernetes role and a role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme.

`K8S_CLUSTER_ADMIN_PASSWORD`: Kubernetes cluster admin password

>To un-deploy, be on the same directory and execute the `undeploy.sh` shell script on the terminal.

##### 5. Access Management Consoles:

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

3. Try navigating to `https://wso2wso2apim/carbon` and `https://wso2apim-analytics/carbon` from your favorite browser.

##### 6. Scale up using `kubectl scale`:

Default deployment runs a single replica (or pod) of WSO2 API Manager Gateway. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/pattern-2/apim-gw/wso2apim-gateway-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
