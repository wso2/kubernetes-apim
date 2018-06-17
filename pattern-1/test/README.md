# Kubernetes Test Resources for deployment of WSO2 API Manager with WSO2 API Manager Analytics

Kubernetes Test Resources for WSO2 API Manager pattern 1 contain artifacts, which can be used to test the core
Kubernetes resources provided for a scalable deployment of WSO2 API Manager with WSO2 API Manager Analytics support.

## Prerequisites

* In order to use these Kubernetes resources, you will need an active [Free Trial Subscription](https://wso2.com/free-trial-subscription)
from WSO2 since the referring Docker images hosted at docker.wso2.com contains the latest updates and fixes for WSO2 API Manager and WSO2 API Manager Analytics.
You can sign up for a Free Trial Subscription [here](https://wso2.com/free-trial-subscription).<br><br>

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

##### 3. Update the deploy.sh file with the [`WSO2 Docker Registry`](https://docker.wso2.com) credentials and Kubernetes cluster admin password.

Replace the relevant placeholders in `KUBERNETES_HOME/is-with-analytics//test/deploy.sh` file with appropriate details, as described below.

* A Kubernetes Secret named `wso2creds` in the cluster to authenticate with the WSO2 Docker Registry, to pull the required images.
The following details need to be replaced in the relevant command.

```
kubectl create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=<username> --docker-password=<password> --docker-email=<email>
```

`username`: Username of your Free Trial Subscription<br>
`password`: Password of your Free Trial Subscription<br>
`email`: Docker email

* A Kubernetes role and a role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme.

`cluster-admin-password`: Kubernetes cluster admin password

##### 4. Setup a Network File System (NFS) to be used as the persistent volume for artifact sharing across Identity Server and Analytics instances.

pdate the NFS server IP (`NFS_SERVER_IP`) and export path (`NFS_LOCATION_PATH`) of persistent volume resources,

* `wso2apim-with-analytics-shared-deployment-pv`
* `wso2apim-with-analytics-apim-analytics-data-pv`

in `<KUBERNETES_HOME>/pattern-1/volumes/persistent-volumes.yaml` file.

Create a user named `wso2carbon` with user id `802` and a group named `wso2` with group id `802` in the NFS node.
Add `wso2carbon` user to the group `wso2`.

Then, provide ownership of the exported folder `NFS_LOCATION_PATH` (used for artifact sharing) to `wso2carbon` user and `wso2` group.
And provide read-write-executable permissions to owning `wso2carbon` user, for the folder `NFS_LOCATION_PATH`.
  
##### 5. Deploy Kubernetes test resources:

Change directory to `KUBERNETES_HOME/pattern-1/test` and execute the `deploy.sh` shell script on the terminal.

```
./deploy.sh
```
>To un-deploy, be on the same directory and execute the `undeploy.sh` shell script on the terminal.

##### 6. Access Management Consoles:

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

3. Try navigating to `https://wso2wso2apim/carbon` and `https://wso2apim-analytics/carbon` from your favorite browser.

##### 7. Scale up using `kubectl scale`:

Default deployment runs a single replica (or pod) of WSO2 API Manager. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/pattern-1/apim/wso2apim-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
