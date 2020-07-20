# Helm Chart for deployment of a Fully Distributed Setup of WSO2 API Manager with WSO2 API Manager Analytics 

Resources for building a Helm chart for deployment of a [fully distributed setup of WSO2 API Manager with WSO2 API Manager Analytics
support](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/deployment-patterns/#pattern-3-fully-distributed-setup).

![WSO2 API Manager pattern 3 deployment](https://github.com/wso2/kubernetes-apim/blob/v3.1.0.3/advanced/am-pattern-3/pattern-3.png)

For advanced details on the deployment pattern, please refer to the official
[documentation](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/).

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)
* [Configuration](#configuration)

## Prerequisites

* WSO2 product Docker images used for the Kubernetes deployment.
  
  WSO2 product Docker images available at [DockerHub](https://hub.docker.com/u/wso2/) package General Availability (GA)
  versions of WSO2 products with no [WSO2 Updates](https://wso2.com/updates).

  For a production grade deployment of the desired WSO2 product-version, it is highly recommended to use the relevant
  Docker image which packages WSO2 Updates, available at [WSO2 Private Docker Registry](https://docker.wso2.com/). In order
  to use these images, you need an active [WSO2 Subscription](https://wso2.com/subscription).
  <br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://helm.sh/docs/intro/install/)
  and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the
  following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup).<br><br>

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/).<br><br>

* Add the WSO2 Helm chart repository.

    ```
     helm repo add wso2 https://helm.wso2.com && helm repo update
    ```

## Quick Start Guide

### 1. Install the Helm Chart

You can install the relevant Helm chart either from [WSO2 Helm Chart Repository](https://hub.helm.sh/charts/wso2) or by source.

**Note:**

* `NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed.

#### Install Chart From [WSO2 Helm Chart Repository](https://hub.helm.sh/charts/wso2)

 Helm version 2

 ```
 helm install --name <RELEASE_NAME> wso2/am-pattern-3 --version 3.1.0-3 --namespace <NAMESPACE>
 ```

 Helm version 3

 - Create the Kubernetes Namespace.
 
    ```
    kubectl create ns <NAMESPACE>
    ```

 - Deploy the Kubernetes resources using the Helm Chart
 
    ```
    helm install <RELEASE_NAME> wso2/am-pattern-3 --version 3.1.0-3 --namespace <NAMESPACE>
    ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available at DockerHub.

If you are using WSO2 product Docker images available from WSO2 Private Docker Registry,
please provide your WSO2 Subscription credentials via input values (using `--set` argument). 

Please see the following example.

```
 helm install --name <RELEASE_NAME> wso2/am-pattern-3 --version 3.1.0-3 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

#### Install Chart From Source

>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/advanced`. <br>

##### Clone the Helm Resources for WSO2 API Manager Git repository.

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### Deploy Helm chart for WSO2 API Manager Pattern 3 deployment.

 Helm version 2

 ```
 helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 3.1.0-3 --namespace <NAMESPACE>
 ```

 Helm version 3

 - Create the Kubernetes Namespace to which you desire to deploy the Kubernetes resources.
 
    ```
    kubectl create ns <NAMESPACE>
    ```

 - Deploy the Kubernetes resources using the Helm Chart
 
    ```
    helm install <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 3.1.0-3 --namespace <NAMESPACE> --dependency-update
    ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available at DockerHub.

If you are using WSO2 product Docker images available from WSO2 Private Docker Registry,
please provide your WSO2 Subscription credentials via input values (using `--set` argument). 

Please see the following example.

```
 helm install --name <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 3.1.0-3 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

### 2. Obtain the external IP

Obtain the external IP (`EXTERNAL-IP`) of the API Manager Ingress resources, by listing down the Kubernetes Ingresses.
  
```  
kubectl get ing -n <NAMESPACE>
```
  
The output under the relevant column stands for the following.

API Manager Publisher

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-3-am-publisher-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's Publisher service (`<wso2.deployment.am.publisher.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's Publisher service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager's Publisher service

API Manager DevPortal

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-3-am-devportal-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's DevPortal service (`<wso2.deployment.am.devportal.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's DevPortal service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager service

API Manager Gateway

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-3-am-gateway-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's Gateway service (`<wso2.deployment.am.gateway.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's Gateway service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager's DevPortal service

API Manager Analytics Dashboard

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-3-am-analytics-dashboard-ingress`)
- HOSTS: Hostname of the WSO2 API Manager Analytics Dashboard service (`<wso2.deployment.analytics.dashboard.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager Analytics Dashboard service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager Analytics Dashboard service

### 3. Add a DNS record mapping the hostnames and the external IP

If the defined hostnames (in the previous step) are backed by a DNS service, add a DNS record mapping the hostnames and
the external IP (`EXTERNAL-IP`) in the relevant DNS service.

If the defined hostnames are not backed by a DNS service, for the purpose of evaluation you may add an entry mapping the
hostnames and the external IP in the `/etc/hosts` file at the client-side.

```
<EXTERNAL-IP> <wso2.deployment.am.publisher.hostname> <wso2.deployment.am.gateway.hostname> <wso2.deployment.am.devportal.hostname> <wso2.deployment.analytics.dashboard.hostname>
```

### 4. Access Management Consoles

- API Manager Publisher: `https://<wso2.deployment.am.publisher.hostname>/publisher`

- API Manager DevPortal: `https://<wso2.deployment.am.devportal.hostname>/devportal`

- API Manager Analytics Dashboard: `https://<wso2.deployment.analytics.dashboard.hostname>/analytics-dashboard`


## Configuration

The following tables lists the configurable parameters of the chart and their default values.

###### WSO2 Subscription Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.subscription.username`                                                | Your WSO2 Subscription username                                                           | -                           |
| `wso2.subscription.password`                                                | Your WSO2 Subscription password                                                           | -                           |

If you do not have an active WSO2 subscription, **do not change** the parameters `wso2.subscription.username` and `wso2.subscription.password`. 

###### Chart Dependencies

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.dependencies.mysql`                                        | Enable the deployment and usage of WSO2 API Management MySQL based Helm Chart             | true                        |
| `wso2.deployment.dependencies.nfsProvisioner`                               | Enable the deployment and usage of NFS Server Provisioner (https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner) | true |

###### Persistent Runtime Artifact Configurations

| Parameter                                                                                   | Description                                                                               | Default Value               |
|---------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.persistentRuntimeArtifacts.storageClass`                                   | Appropriate Kubernetes Storage Class                                                      | `nfs`                       |
| `wso2.deployment.persistentRuntimeArtifacts.sharedArtifacts.capacity.executionPlans`        | Capacity for execution plans shared between the Traffic Manager profile instances         | 20M                         |
| `wso2.deployment.persistentRuntimeArtifacts.sharedArtifacts.capacity.synapseConfigs`        | Capacity for synapse artifacts of APIs shared between the Gateway profile instances       | 50M                         |
| `wso2.deployment.persistentRuntimeArtifacts.apacheSolrIndexing.enabled`                     | Indicates if persistence of the runtime artifacts for Apache Solr-based indexing is enabled  | false                    |
| `wso2.deployment.persistentRuntimeArtifacts.apacheSolrIndexing.capacity.carbonDatabase`     | Capacity for persisting the H2 based local Carbon database file                           | 50M                         |
| `wso2.deployment.persistentRuntimeArtifacts.apacheSolrIndexing.capacity.solrIndexedData`    | Capacity for persisting the Apache Solr indexed data                                      | 50M                         |

###### API Manager Server Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.am.dockerRegistry`                                         | Registry location of the Docker image to be used to create API Manager instances          | -                           |
| `wso2.deployment.am.imageName`                                              | Name of the Docker image to be used to create API Manager instances                       | `wso2am`                    |
| `wso2.deployment.am.imageTag`                                               | Tag of the image used to create API Manager instances                                     | 3.1.0                       |
| `wso2.deployment.am.imagePullPolicy`                                        | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | `Always`                    |
| `wso2.deployment.am.resources.requests.memory`                              | The minimum amount of memory that should be allocated for running API Manager product profiles with profile optimization  | 1Gi                         |
| `wso2.deployment.am.resources.requests.cpu`                                 | The minimum amount of CPU that should be allocated for running API Manager product profiles with profile optimization     | 1000m                       |
| `wso2.deployment.am.resources.limits.memory`                                | The maximum amount of memory that should be allocated for running API Manager product profiles with profile optimization  | 2Gi                         |
| `wso2.deployment.am.resources.limits.cpu`                                   | The maximum amount of CPU that should be allocated for running API Manager product profiles with profile optimization     | 2000m                       |
| `wso2.deployment.am.livenessProbe.initialDelaySeconds`                      | Initial delay for the live-ness probe for API Manager optimized profile                   | 60                          |
| `wso2.deployment.am.livenessProbe.periodSeconds`                            | Period of the live-ness probe for API Manager optimized profile                           | 10                          |
| `wso2.deployment.am.readinessProbe.initialDelaySeconds`                     | Initial delay for the readiness probe for API Manager optimized profile                   | 60                          |
| `wso2.deployment.am.readinessProbe.periodSeconds`                           | Period of the readiness probe for API Manager optimized profile                           | 10                          |
| `wso2.deployment.am.gateway.hostname`                                       | Hostname for API Manager Gateway                                                          | `gateway.am.wso2.com`       |
| `wso2.deployment.am.gateway.replicas`                                       | Number of replicas of API Manager Gateway to be started                                   | 2                           |
| `wso2.deployment.am.gateway.strategy.rollingUpdate.maxSurge`                | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 2                         |
| `wso2.deployment.am.gateway.strategy.rollingUpdate.maxUnavailable`          | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 0                         |
| `wso2.deployment.am.gateway.config`                                         | Custom deployment configuration file for Gateway profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |
| `wso2.deployment.am.km.replicas`                                            | Number of replicas of API Manager Key Manager to be started                                   | 2                           |
| `wso2.deployment.am.km.strategy.rollingUpdate.maxSurge`                     | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 2                         |
| `wso2.deployment.am.km.strategy.rollingUpdate.maxUnavailable`               | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 0                         |
| `wso2.deployment.am.km.config`                                              | Custom deployment configuration file for Key Manager profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |
| `wso2.deployment.am.publisher.hostname`                                     | Hostname for API Manager Publisher                                                        | `publisher.am.wso2.com`     |
| `wso2.deployment.am.publisher.config`                                       | Custom deployment configuration file for Publisher profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |
| `wso2.deployment.am.devportal.hostname`                                     | Hostname for API Manager DevPortal                                                        | `devportal.am.wso2.com`     |
| `wso2.deployment.am.devportal.config`                                       | Custom deployment configuration file for DevPortal profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |
| `wso2.deployment.am.tm.config`                                              | Custom deployment configuration file for Traffic Manager profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |

###### Analytics Dashboard Runtime Configurations

| Parameter                                                                     | Description                                                                                                      | Default Value               |
|-------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.analytics.dashboard.hostname`                                | Hostname for API Manager Analytics Dashboard                                                                     | `analytics.am.wso2.com`     |
| `wso2.deployment.analytics.dashboard.dockerRegistry`                          | Registry location of the Docker image to be used to create an API Manager Analytics instance                     | -                           |
| `wso2.deployment.analytics.dashboard.imageName`                               | Name of the Docker image to be used to create an API Manager Analytics instance                                  | `wso2am-analytics-dashboard`    |
| `wso2.deployment.analytics.dashboard.imageTag`                                | Tag of the image used to create an API Manager Analytics instance                                                | 3.1.0                       |
| `wso2.deployment.analytics.dashboard.imagePullPolicy`                         | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)                            | `Always`                    |
| `wso2.deployment.analytics.dashboard.replicas`                                | Number of replicas of API Manager Analytics to be started                                                        | 1                           |
| `wso2.deployment.analytics.dashboard.strategy.rollingUpdate.maxSurge`         | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 1                           |
| `wso2.deployment.analytics.dashboard.strategy.rollingUpdate.maxUnavailable`   | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 0                           |
| `wso2.deployment.analytics.dashboard.livenessProbe.initialDelaySeconds`       | Initial delay for the live-ness probe for API Manager Analytics node                                             | 20                          |
| `wso2.deployment.analytics.dashboard.livenessProbe.periodSeconds`             | Period of the live-ness probe for API Manager Analytics node                                                     | 10                          |
| `wso2.deployment.analytics.dashboard.readinessProbe.initialDelaySeconds`      | Initial delay for the readiness probe for API Manager Analytics node                                             | 20                          |
| `wso2.deployment.analytics.dashboard.readinessProbe.periodSeconds`            | Period of the readiness probe for API Manager Analytics node                                                     | 10                          |
| `wso2.deployment.analytics.dashboard.resources.requests.memory`               | The minimum amount of memory that should be allocated for a Pod                                                  | 4Gi                         |
| `wso2.deployment.analytics.dashboard.resources.requests.cpu`                  | The minimum amount of CPU that should be allocated for a Pod                                                     | 2000m                       |
| `wso2.deployment.analytics.dashboard.resources.limits.memory`                 | The maximum amount of memory that should be allocated for a Pod                                                  | 4Gi                         |
| `wso2.deployment.analytics.dashboard.resources.limits.cpu`                    | The maximum amount of CPU that should be allocated for a Pod                                                     | 2000m                       |
| `wso2.deployment.analytics.dashboard.config`                                  | Custom deployment configuration file (`<WSO2AM_ANALYTICS>/conf/dashboard/deployment.yaml`)                       | -                           |

###### Analytics Worker Runtime Configurations

| Parameter                                                                  | Description                                                                                                         | Default Value               |
|----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.analytics.worker.dockerRegistry`                          | Registry location of the Docker image to be used to create an API Manager Analytics instance                        | -                           |
| `wso2.deployment.analytics.worker.imageName`                               | Name of the Docker image to be used to create an API Manager Analytics instance                                     | `wso2am-analytics-worker`   |
| `wso2.deployment.analytics.worker.imageTag`                                | Tag of the image used to create an API Manager Analytics instance                                                   | 3.1.0                       |
| `wso2.deployment.analytics.worker.imagePullPolicy`                         | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)                               | `Always`                    |
| `wso2.deployment.analytics.worker.livenessProbe.initialDelaySeconds`       | Initial delay for the live-ness probe for API Manager Analytics node                                                | 20                          |
| `wso2.deployment.analytics.worker.livenessProbe.periodSeconds`             | Period of the live-ness probe for API Manager Analytics node                                                        | 10                          |
| `wso2.deployment.analytics.worker.readinessProbe.initialDelaySeconds`      | Initial delay for the readiness probe for API Manager Analytics node                                                | 20                          |
| `wso2.deployment.analytics.worker.readinessProbe.periodSeconds`            | Period of the readiness probe for API Manager Analytics node                                                        | 10                          |
| `wso2.deployment.analytics.worker.resources.requests.memory`               | The minimum amount of memory that should be allocated for a Pod                                                     | 4Gi                         |
| `wso2.deployment.analytics.worker.resources.requests.cpu`                  | The minimum amount of CPU that should be allocated for a Pod                                                        | 2000m                       |
| `wso2.deployment.analytics.worker.resources.limits.memory`                 | The maximum amount of memory that should be allocated for a Pod                                                     | 4Gi                         |
| `wso2.deployment.analytics.worker.resources.limits.cpu`                    | The maximum amount of CPU that should be allocated for a Pod                                                        | 2000m                       |

###### Kubernetes Specific Configurations

| Parameter                                                     | Description                                                                               | Default Value                   |
|---------------------------------------------------------------|-------------------------------------------------------------------------------------------|---------------------------------|
| `kubernetes.serviceAccount`                                   | Name of the Kubernetes Service Account to which the Pods are to be bound                  | `wso2am-pattern-3-svc-account`  |
