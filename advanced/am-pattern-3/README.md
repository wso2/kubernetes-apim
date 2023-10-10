# Pattern 3: Helm Chart for deployment of a Simple Scalable Deployment of WSO2 API Manager

Resources for building a Helm chart for deployment of a [simple scalable deployment of WSO2 API Manager](https://apim.docs.wso2.com/en/4.2.0/install-and-setup/setup/deployment-overview/#simple-scalable-deployment).

![WSO2 API Manager pattern 3 deployment](https://apim.docs.wso2.com/en/4.2.0/assets/img/setup-and-install/basic-scalable-deployment.png)

For advanced details on the deployment pattern, please refer to the official
[documentation](https://apim.docs.wso2.com/en/4.2.0/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/).

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)
* [Configuration](#configuration)
* [Runtime Artifact Persistence and Sharing](#runtime-artifact-persistence-and-sharing)
* [Managing Java Keystores and Truststores](#managing-java-keystores-and-truststores)
* [Configuring SSL in Service Exposure](#configuring-ssl-in-service-exposure)

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
 helm install --name <RELEASE_NAME> wso2/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE>
 ```

 Helm version 3

 - Deploy the Kubernetes resources using the Helm Chart
 
    ```
    helm install <RELEASE_NAME> wso2/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --create-namespace
    ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available in WSO2 Private Docker Registry. Please provide your WSO2 Subscription credentials via input values (using `--set` argument).

Please see the following example.

```
 helm install --name <RELEASE_NAME> wso2/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

If you are using a custom WSO2 Docker images you will need to provide those information via the input values. Please refer [API Manager Server Configurations](#api-manager-server-configurations) and [Micro Integrator Server Configurations](#micro-integrator-server-configurations)


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
 helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE>
 ```

 Helm version 3

 - Deploy the Kubernetes resources using the Helm Chart
 
    ```
    helm install <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --dependency-update --create-namespace
    ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available in WSO2 Private Docker Registry. Please provide your WSO2 Subscription credentials via input values (using `--set` argument).

Please see the following example.

```
 helm install --name <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

If you are using a custom WSO2 Docker images you will need to provide those information via the input values. Please refer [API Manager Server Configurations](#api-manager-server-configurations) and [Micro Integrator Server Configurations](#micro-integrator-server-configurations)


Or else, you can configure the default configurations inside the am-pattern-3 helm chart [values.yaml](https://github.com/wso2/kubernetes-apim/blob/master/advanced/am-pattern-3/values.yaml) file. Refer [this](https://helm.sh/docs/chart_template_guide/values_files/) for to learn more details about the `values.yaml` file.


> **Note:** <br>
From the above Helm commands, base image of a Micro Integrator is deployed (without any integration solution). To deploy your integration solution with the Helm charts follow the below steps. <br><br>
>1. [Create an integration service using WSO2 Integration Studio and expose it as a Managed API](https://apim.docs.wso2.com/en/4.2.0/tutorials/integration-tutorials/service-catalog-tutorial/#exposing-an-integration-service-as-a-managed-api). Then [create a Docker image](https://apim.docs.wso2.com/en/4.2.0/integrate/develop/create-docker-project/#creating-docker-exporter) and push it to your private or public Docker registry. <br><br>
    - `INTEGRATION_IMAGE_REGISTRY` will refer to the Docker registry that created Docker image has been pushed <br>
    - `INTEGRATION_IMAGE_NAME` will refer to the name of the created Docker image <br>
    - `INTEGRATION_IMAGE_TAG` will refer to the tag of the created Docker image <br><br>
>2. If your Docker registry is a private registry, [create an imagePullSecret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).<br><br>
    - `IMAGE_PULL_SECRET` will refer to the created image pull secret <br><br>
>3. Deploy the helm resource using following command.<br><br>
>   ```
>   helm install <RELEASE_NAME> wso2/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.deployment.mi.dockerRegistry=<INTEGRATION_IMAGE_REGISTRY> --set wso2.deployment.mi.imageName=<INTEGRATION_IMAGE_NAME> --set wso2.deployment.mi.imageTag=<INTEGRATION_IMAGE_TAG> --set wso2.deployment.mi.imagePullSecrets=<IMAGE_PULL_SECRET>
>   ```     

> **Note:**
> If you are using Rancher Desktop for the Kubernetes cluster, add the following changes. 
> 1. Change `storageClass` to `local-path` in [`values.yaml`](https://github.com/wso2/kubernetes-apim/blob/master/advanced/am-pattern-3/values.yaml#L43).
> 2. Change `accessModes` in [`Persistent Volume Claims`](https://github.com/wso2/kubernetes-apim/blob/master/advanced/am-pattern-3/templates/am/control-plane/wso2am-pattern-3-am-control-plane-volume-claims.yaml) to `ReadWriteOnce`.

### Choreo Analytics

If you need to enable Choreo Analytics with WSO2 API Manager, please follow the documentation on [Register for Analytics](https://apim.docs.wso2.com/en/4.2.0/observe/api-manager-analytics/configure-analytics/register-for-analytics/) to obtain the on-prem key for Analytics.

The following example shows how to enable Analytics with the helm charts.

Helm v2

```
helm install --name <RELEASE_NAME> wso2/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.choreoAnalytics.enabled=true --set wso2.choreoAnalytics.endpoint=<CHOREO_ANALYTICS_ENDPOINT> --set wso2.choreoAnalytics.onpremKey=<ONPREM_KEY>
```

Helm v3

```
helm install <RELEASE_NAME> wso2/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.choreoAnalytics.enabled=true --set wso2.choreoAnalytics.endpoint=<CHOREO_ANALYTICS_ENDPOINT> --set wso2.choreoAnalytics.onpremKey=<ONPREM_KEY> --create-namespace
```

You will be able to see the Analytics data when you log into Choreo Analytics Portal.

### 2. Obtain the external IP

Obtain the external IP (`EXTERNAL-IP`) of the API Manager Ingress resources, by listing down the Kubernetes Ingresses.
  
```  
kubectl get ing -n <NAMESPACE>
```
  
The output under the relevant column stands for the following.

API Manager Control Plane

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-3-am-cp-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's Control Plane service (`<wso2.deployment.am.cp.ingress.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's Control Plane service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager's Control Plane service

API Manager Gateway

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-3-am-gateway-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's Gateway service (`<wso2.deployment.am.gateway.ingress.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's Gateway service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager's Gateway service

API Manager Websub

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to wso2am-pattern-3-am-websub-ingress)
- HOSTS: Hostname of the WSO2 API Manager's Websub service (`<wso2.deployment.am.websub.ingress.hostname>`)
- ADDRESS: External IP (EXTERNAL-IP) exposing the API Manager's Websub service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager's Websub service

Micro Integrator Management APIs

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to wso2am-pattern-3-mi-1-management-ingress)
- HOSTS: Hostname of the WSO2 Micro Integrator service (`<wso2.deployment.mi.ingress.management.hostname>`)
- ADDRESS: External IP (EXTERNAL-IP) exposing the Micro Integrator service to outside of the Kubernetes environment
PORTS: Externally exposed service ports of the Micro Integrator service

### 3. Add a DNS record mapping the hostnames and the external IP

If the defined hostnames (in the previous step) are backed by a DNS service, add a DNS record mapping the hostnames and
the external IP (`EXTERNAL-IP`) in the relevant DNS service.

If the defined hostnames are not backed by a DNS service, for the purpose of evaluation you may add an entry mapping the
hostnames and the external IP in the `/etc/hosts` file at the client-side.

### 4. Access Management Consoles

- API Manager Publisher: `https://<wso2.deployment.am.cp.ingress.hostname>/publisher`

- API Manager DevPortal: `https://<wso2.deployment.am.cp.ingress.hostname>/devportal`

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

###### WSO2 Subscription Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.subscription.username`                                                | Your WSO2 Subscription username                                                           | -                           |
| `wso2.subscription.password`                                                | Your WSO2 Subscription password                                                           | -                           |
| `wso2.choreoAnalytics.enabled`                                                | Chorero Analytics enabled or not                                                           | false                           |
| `wso2.choreoAnalytics.endpoint`                                                | Choreo Analytics endpoint                                                           | https://analytics-event-auth.choreo.dev/auth/v1                           |
| `wso2.choreoAnalytics.onpremKey`                                                | On-prem key for Choreo Analytics                                                          | -                           |

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
| `wso2.deployment.am.imageTag`                                               | Tag of the image used to create API Manager instances                                     | 4.2.0                       |
| `wso2.deployment.am.imagePullPolicy`                                        | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | `Always`                    |
| `wso2.deployment.am.resources.requests.memory`                              | The minimum amount of memory that should be allocated for running API Manager product profiles with profile optimization  | 1Gi                         |
| `wso2.deployment.am.resources.requests.cpu`                                 | The minimum amount of CPU that should be allocated for running API Manager product profiles with profile optimization     | 1000m                       |
| `wso2.deployment.am.resources.limits.memory`                                | The maximum amount of memory that should be allocated for running API Manager product profiles with profile optimization  | 2Gi                         |
| `wso2.deployment.am.resources.limits.cpu`                                   | The maximum amount of CPU that should be allocated for running API Manager product profiles with profile optimization     | 2000m                       |
| `wso2.deployment.am.livenessProbe.initialDelaySeconds`                      | Initial delay for the live-ness probe for API Manager optimized profile                   | 60                          |
| `wso2.deployment.am.livenessProbe.periodSeconds`                            | Period of the live-ness probe for API Manager optimized profile                           | 10                          |
| `wso2.deployment.am.readinessProbe.initialDelaySeconds`                     | Initial delay for the readiness probe for API Manager optimized profile                   | 60                          |
| `wso2.deployment.am.readinessProbe.periodSeconds`                           | Period of the readiness probe for API Manager optimized profile                           | 10                          |
| `wso2.deployment.am.websub.ingress.enabled`                            | If enabled, create ingress resource for WebSub service  | true          |
| `wso2.deployment.am.websub.ingress.hostname`                               | Hostname for API Manager WebSub service                                                          | `websub.am.wso2.com`       |
| `wso2.deployment.am.websub.ingress.annotations`                            | Ingress resource annotations for API Manager WebSub                                      | Community NGINX Ingress controller annotations       |
| `wso2.deployment.am.gateway.ingress.enabled`                            | If enabled, create ingress resource for API Manager Gateway  | true          |
| `wso2.deployment.am.gateway.ingress.hostname`                               | Hostname for API Manager Gateway                                                          | `gateway.am.wso2.com`       |
| `wso2.deployment.am.gateway.ingress.annotations`                            | Ingress resource annotations for API Manager Gateway                                      | Community NGINX Ingress controller annotations       |
| `wso2.deployment.am.gateway.replicas`                                       | Number of replicas of API Manager Gateway to be started                                   | 2                           |
| `wso2.deployment.am.gateway.strategy.rollingUpdate.maxSurge`                | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 2                         |
| `wso2.deployment.am.gateway.strategy.rollingUpdate.maxUnavailable`          | Refer to [doc](https://v1-14.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#deploymentstrategy-v1-apps)  | 0                         |
| `wso2.deployment.am.gateway.config`                                         | Custom deployment configuration file for Gateway profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |
| `wso2.deployment.am.cp.livenessProbe.initialDelaySeconds`                      | Initial delay for the live-ness probe for API Manager Control Plane profile                   | 60                          |
| `wso2.deployment.am.cp.livenessProbe.periodSeconds`                            | Period of the live-ness probe for API Manager Control Plane profile                           | 10                          |
| `wso2.deployment.am.cp.readinessProbe.initialDelaySeconds`                     | Initial delay for the readiness probe for API Manager Control Plane profile                   | 60                          |
| `wso2.deployment.am.cp.readinessProbe.periodSeconds`                           | Period of the readiness probe for API Manager Control Plane profile                           | 10                          |
| `wso2.deployment.am.cp.ingress.enabled`                            | If enabled, create ingress resource for API Manager management consoles  | true          |
| `wso2.deployment.am.cp.ingress.hostname`                             | Hostname for API Manager Control Plane                                                          | `am.wso2.com`       |
| `wso2.deployment.am.cp.ingress.annotations`                          | Ingress resource annotations for API Manager Control Plane                                      | Community NGINX Ingress controller annotations       |
| `wso2.deployment.am.cp.resources.requests.memory`                              | The minimum amount of memory that should be allocated for running API Manager API Manager Control Plane  | 1Gi                         |
| `wso2.deployment.am.cp.resources.requests.cpu`                                 | The minimum amount of CPU that should be allocated for running API ManagerAPI Manager Control Plane     | 1000m                       |
| `wso2.deployment.am.cp.resources.limits.memory`                                | The maximum amount of memory that should be allocated for running API Manager API Manager Control Plane  | 2Gi                         |
| `wso2.deployment.am.cp.resources.limits.cpu`                                   | The maximum amount of CPU that should be allocated for running API Manager API Manager Control Plane     | 2000m                       |
| `wso2.deployment.am.cp.config`                                       | Custom deployment configuration file for Control Plane profile (`<WSO2AM>/repository/conf/deployment.toml`)         | -                           |

###### Micro Integrator Server Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.mi.dockerRegistry`                                         | Registry location of the Docker image to be used to create Micro Integrator instances     | -                           |
| `wso2.deployment.mi.imageName`                                              | Name of the Docker image to be used to create API Manager instances                       | `wso2mi`                    |
| `wso2.deployment.mi.imageTag`                                               | Tag of the image used to create API Manager instances                                     | 4.2.0                       |
| `wso2.deployment.mi.imagePullPolicy`                                        | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | `Always`                    |
| `wso2.deployment.mi.livenessProbe.initialDelaySeconds`                      | Initial delay for the live-ness probe for Micro Integrator node                           | 35                          |
| `wso2.deployment.mi.livenessProbe.periodSeconds`                            | Period of the live-ness probe for Micro Integrator node                                   | 10                          |
| `wso2.deployment.mi.readinessProbe.initialDelaySeconds`                     | Initial delay for the readiness probe for Micro Integrator node                           | 35                          |
| `wso2.deployment.mi.readinessProbe.periodSeconds`                           | Period of the readiness probe for Micro Integrator node                                   | 10                          |
| `wso2.deployment.mi.resources.requests.memory`                              | The minimum amount of memory that should be allocated for a Pod                           | 512Mi                       |
| `wso2.deployment.mi.resources.requests.cpu`                                 | The minimum amount of CPU that should be allocated for a Pod                              | 500m                        |
| `wso2.deployment.mi.resources.limits.memory`                                | The maximum amount of memory that should be allocated for a Pod                           | 1Gi                         |
| `wso2.deployment.mi.resources.limits.cpu`                                   | The maximum amount of CPU that should be allocated for a Pod                              | 1000m                       |
| `wso2.deployment.mi.config`                                                 | Custom deployment configuration file (`<WSO2MI>/conf/deployment.toml`)         | -                           |
| `wso2.deployment.mi.ingress.management.hostname`                            | Hostname for Micro Integrator management apis                                             | `management.mi.wso2.com`    |
| `wso2.deployment.mi.ingress.management.annotations`                         | Ingress resource annotations for API Manager Gateway                                      | Community NGINX Ingress controller annotations         |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 API Manager server profiles are based on its [official documentation](https://apim.docs.wso2.com/en/4.2.0/install-and-setup/install/installation-prerequisites/).

## Kubernetes Specific Configurations

| Parameter                                                     | Description                                                                               | Default Value                   |
|---------------------------------------------------------------|-------------------------------------------------------------------------------------------|---------------------------------|
| `kubernetes.serviceAccount`                                   | Name of the Kubernetes Service Account to which the Pods are to be bound                  | `wso2am-pattern-3-svc-account`  |

## Runtime Artifact Persistence and Sharing

* It is **mandatory** to set an appropriate Kubernetes StorageClass in this deployment, for persistence and sharing.

* By default, this deployment uses the `nfs` Kubernetes StorageClass created using the official, stable [NFS Server Provisioner](https://hub.helm.sh/charts/stable/nfs-server-provisioner).

* Only persistent storage solutions supporting `ReadWriteMany` [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)
  are applicable for `wso2.deployment.persistentRuntimeArtifacts.storageClass`.
  
* Please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/store/Persisting_And_Sharing.md#recommended-storage-options-for-wso2-products)
  for advanced details with regards to WSO2 recommended, storage options.

## Managing Java Keystores and Truststores

* By default, this deployment uses the default keystores and truststores provided by the relevant WSO2 product.

* For advanced details with regards to managing custom Java keystores and truststores in a container based WSO2 product deployment
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/deploy/Managing_Keystores_And_Truststores.md).

## Configuring SSL in Service Exposure

* For WSO2 recommended best practices in configuring SSL when exposing the internal product services to outside of the Kubernetes cluster,
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/route/Routing.md#configuring-ssl).

## Setting up API Manager without Micro Integrator

If you want to setup API Manager only without Micro Integrator, you have to install the charts from source after removing MI templates.

* Clone the repository

    ```
    git clone https://github.com/wso2/kubernetes-apim.git
    ```

* Remove the MI templates by removing the `mi` folder in `<KUBERNETES_HOME>/advanced/am-pattern-3/templates/`.

* Deploy Helm charts

    ```helm
    helm install <RELEASE_NAME> <HELM_HOME>/am-pattern-3 --version 4.2.0-1 --namespace <NAMESPACE> --dependency-update --create-namespace
    ```
