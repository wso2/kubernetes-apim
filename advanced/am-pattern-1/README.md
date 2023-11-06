# Kubernetes to OpenShift Resource Mapping

The following table lists the Kubernetes resources and their equivalent or related concepts in OpenShift:

| Kubernetes Kind         | OpenShift Equivalent    | Description                                                                                                                        |
| ----------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| DeploymentConfig        | DeploymentConfig        | OpenShift-specific resource that extends Kubernetes deployments with additional features like triggers.                            |
| Secret                  | Secret                  | Used to store and manage sensitive information.                                                                                    |
| ServiceAccount          | ServiceAccount          | Represents an identity for processes that run in a Pod.                                                                            |
| ConfigMap               | ConfigMap               | Used to store non-confidential data in key-value pairs.                                                                            |
| Ingress                 | Route                   | OpenShift's Route resource extends Kubernetes Ingress capabilities for external access to services.                                |
| Service                 | Service                 | Defines a logical set of Pods and a policy by which to access them.                                                                |
| PersistentVolumeClaim   | PersistentVolumeClaim   | A request for storage by a user that applications can use.                                                                         |
| Deployment              | Deployment              | Manages the deployment and scaling of a set of Pods.                                                                               |
| StatefulSet             | StatefulSet             | Manages deployment and scaling of stateful applications.                                                                           |
| DaemonSet               | DaemonSet               | Ensures all (or some) Nodes run a copy of a Pod.                                                                                   |
| ReplicaSet              | ReplicaSet              | Maintains a stable set of replica Pods running at any given time.                                                                  |
| Job                     | Job                     | Creates one or more Pods and ensures that a specified number of them successfully terminate.                                       |
| CronJob                 | CronJob                 | Manages time-based Jobs, such as once at a specified point in time or repeatedly at a specified interval.                          |
| Pod                     | Pod                     | The smallest deployable units of computing that can be created and managed.                                                        |
| HorizontalPodAutoscaler | HorizontalPodAutoscaler | Automatically scales the number of Pods in a replication controller, deployment, or replica set based on observed CPU utilization. |
| NetworkPolicy           | NetworkPolicy           | Specifies how groups of Pods are allowed to communicate with each other and other network endpoints.                               |
| ResourceQuota           | ResourceQuota           | Provides constraints that limit aggregate resource consumption per namespace.                                                      |
| LimitRange              | LimitRange              | Imposes constraints on the size of Pods and Container resources in a namespace.                                                    |

Note: OpenShift is built on Kubernetes and supports all Kubernetes resources, along with additional OpenShift-specific resources.

# Pattern 1: Helm Chart for Standard HA Deployment of WSO2 API Manager with WSO2 Micro Integrator

This deployment consists of an API-M cluster with two nodes of the API-M runtime and two nodes each of the integration runtimes (Micro Integrator/Streaming Integrator). You can use this pattern if you expect to receive low traffic to your deployment.

![WSO2 API Manager pattern 1 deployment](https://apim.docs.wso2.com/en/4.2.0/assets/img/setup-and-install/basic-ha-deployment.png)

For advanced details on the deployment pattern, please refer to the official
[documentation](https://apim.docs.wso2.com/en/4.2.0/install-and-setup/setup/deployment-overview/#standard-ha-deployment).

## Contents

- [Prerequisites](#prerequisites)
- [Quick Start Guide](#quick-start-guide)
- [Configuration](#configuration)
- [Runtime Artifact Persistence and Sharing](#runtime-artifact-persistence-and-sharing)
- [Managing Java Keystores and Truststores](#managing-java-keystores-and-truststores)
- [Configuring SSL in Service Exposure](#configuring-ssl-in-service-exposure)

## Prerequisites

- WSO2 product Docker images used for the Kubernetes deployment.

  WSO2 product Docker images available at [DockerHub](https://hub.docker.com/u/wso2/) package General Availability (GA)
  versions of WSO2 products with no [WSO2 Updates](https://wso2.com/updates).

  For a production grade deployment of the desired WSO2 product-version, it is highly recommended to use the relevant
  Docker image which packages WSO2 Updates, available at [WSO2 Private Docker Registry](https://docker.wso2.com/). In order
  to use these images, you need an active [WSO2 Subscription](https://wso2.com/subscription).
  <br><br>

- Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://helm.sh/docs/intro/install/)
  and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the
  following quick start guide.<br><br>

- An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup).<br><br>

- Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/).<br><br>
- Add the WSO2 Helm chart repository.

  ```
   helm repo add wso2 https://helm.wso2.com && helm repo update
  ```

## Quick Start Guide

### 1. Install the Helm Chart

You can install the relevant Helm chart either from [WSO2 Helm Chart Repository](https://hub.helm.sh/charts/wso2) or by source.

**Note:**

- `NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed.

#### Install Chart From [WSO2 Helm Chart Repository](https://hub.helm.sh/charts/wso2)

Deploy the Kubernetes resources using the Helm Chart

- Helm version 2

  ```
  helm install --name <RELEASE_NAME> wso2/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE>
  ```

- Helm version 3

  ```
  helm install <RELEASE_NAME> wso2/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --create-namespace
  ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available in WSO2 Private Docker Registry. Please provide your WSO2 Subscription credentials via input values (using `--set` argument).

Please see the following example.

```
 helm install --name <RELEASE_NAME> wso2/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

If you are using a custom WSO2 Docker images you will need to provide those information via the input values. Please refer [API Manager Server Configurations](#api-manager-server-configurations) and [Micro Integrator Server Configurations](#micro-integrator-server-configurations)

#### Install Chart From Source

> In the context of this document, <br>
>
> - `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
>   Git repository. <br>
> - `HELM_HOME` will refer to `<KUBERNETES_HOME>/advanced`. <br>

##### Clone the Helm Resources for WSO2 API Manager Git repository.

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### Deploy Helm chart for WSO2 API Manager Pattern 1 deployment.

Deploy the Kubernetes resources using the Helm Chart

- Helm version 2

  ```
  helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE>
  ```

- Helm version 3

  ```
  helm install <RELEASE_NAME> <HELM_HOME>/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --dependency-update --create-namespace
  ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available in WSO2 Private Docker Registry. Please provide your WSO2 Subscription credentials via input values (using `--set` argument).

Please see the following example.

```
 helm install --name <RELEASE_NAME> <HELM_HOME>/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

If you are using a custom WSO2 Docker images you will need to provide those information via the input values. Please refer [API Manager Server Configurations](#api-manager-server-configurations) and [Micro Integrator Server Configurations](#micro-integrator-server-configurations)

Or else, you can configure the default configurations inside the am-pattern-1 helm chart [values.yaml](https://github.com/wso2/kubernetes-apim/blob/master/advanced/am-pattern-1/values.yaml) file. Refer [this](https://helm.sh/docs/chart_template_guide/values_files/) for to learn more details about the `values.yaml` file.

> **Note:** <br>
> From the above Helm commands, base image of a Micro Integrator is deployed (without any integration solution). To deploy your integration solution with the Helm charts follow the below steps. <br><br>
>
> 1.  [Create an integration service using WSO2 Integration Studio and expose it as a Managed API](https://apim.docs.wso2.com/en/latest/tutorials/integration-tutorials/service-catalog-tutorial/#exposing-an-integration-service-as-a-managed-api). Then [create a Docker image](https://apim.docs.wso2.com/en/latest/integrate/develop/create-docker-project/#creating-docker-exporter) and push it to your private or public Docker registry. <br><br>

    - `INTEGRATION_IMAGE_REGISTRY` will refer to the Docker registry that created Docker image has been pushed <br>
    - `INTEGRATION_IMAGE_NAME` will refer to the name of the created Docker image <br>
    - `INTEGRATION_IMAGE_TAG` will refer to the tag of the created Docker image <br><br>

> 2.  If your Docker registry is a private registry, [create an imagePullSecret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).<br><br>

    - `IMAGE_PULL_SECRET` will refer to the created image pull secret <br><br>

> 3.  Deploy the helm resource using following command.<br><br>
>
> ```
> helm install <RELEASE_NAME> wso2/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.deployment.mi.dockerRegistry=<INTEGRATION_IMAGE_REGISTRY> --set wso2.deployment.mi.imageName=<INTEGRATION_IMAGE_NAME> --set wso2.deployment.mi.imageTag=<INTEGRATION_IMAGE_TAG> --set wso2.deployment.mi.imagePullSecrets=<IMAGE_PULL_SECRET>
> ```

> **Note:**
> If you are using Rancher Desktop for the Kubernetes cluster, add the following changes.
>
> 1. Change `storageClass` to `local-path` in [`values.yaml`](https://github.com/wso2/kubernetes-apim/blob/master/advanced/am-pattern-1/values.yaml#L43).
> 2. Change `accessModes` in [`Persistent Volume Claims`](https://github.com/wso2/kubernetes-apim/blob/master/advanced/am-pattern-1/templates/am/wso2am-pattern-1-am-volume-claims.yaml) to `ReadWriteOnce`.

### Choreo Analytics

If you need to enable Choreo Analytics with WSO2 API Manager, please follow the documentation on [Register for Analytics](https://apim.docs.wso2.com/en/latest/observe/api-manager-analytics/configure-analytics/register-for-analytics/) to obtain the on-prem key for Analytics.

The following example shows how to enable Analytics with the helm charts.

Helm v2

```
helm install --name <RELEASE_NAME> wso2/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.choreoAnalytics.enabled=true --set wso2.choreoAnalytics.endpoint=<CHOREO_ANALYTICS_ENDPOINT> --set wso2.choreoAnalytics.onpremKey=<ONPREM_KEY>
```

Helm v3

```
helm install <RELEASE_NAME> wso2/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --set wso2.choreoAnalytics.enabled=true --set wso2.choreoAnalytics.endpoint=<CHOREO_ANALYTICS_ENDPOINT> --set wso2.choreoAnalytics.onpremKey=<ONPREM_KEY> --create-namespace
```

You will be able to see the Analytics data when you log into Choreo Analytics Portal.

### 2. Obtain the external IP

Obtain the external IP (`EXTERNAL-IP`) of the API Manager Ingress resources, by listing down the Kubernetes Ingresses.

```
kubectl get ing -n <NAMESPACE>
```

The output under the relevant column stands for the following.

API Manager Publisher-DevPortal

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-1-am-ingress`)
- HOSTS: Hostname of the WSO2 API Manager service (`<wso2.deployment.am.ingress.management.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager service

API Manager Gateway

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-1-am-gateway-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's Gateway service (`<wso2.deployment.am.ingress.gateway.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's Gateway service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager' Gateway service

API Manager Websub

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-1-am-websub-ingress`)
- HOSTS: Hostname of the WSO2 API Manager's Websub service (`<wso2.deployment.am.ingress.websub.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the API Manager's Websub service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the API Manager' Websub service

Micro Integrator Management APIs

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2am-pattern-1-mi-1-management-ingress`)
- HOSTS: Hostname of the WSO2 Micro Integrator service (`<wso2.deployment.mi.ingress.management.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the Micro Integrator service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the Micro Integrator service

### 3. Add a DNS record mapping the hostnames and the external IP

If the defined hostnames (in the previous step) are backed by a DNS service, add a DNS record mapping the hostnames and
the external IP (`EXTERNAL-IP`) in the relevant DNS service.

If the defined hostnames are not backed by a DNS service, for the purpose of evaluation you may add an entry mapping the
hostnames and the external IP in the `/etc/hosts` file at the client-side.

```
<EXTERNAL-IP> <wso2.deployment.am.ingress.management.hostname> <wso2.deployment.am.ingress.gateway.hostname> <wso2.deployment.am.ingress.websub.hostname> <wso2.deployment.mi.ingress.management.hostname>
```

### 4. Access Management Consoles

- API Manager Publisher: `https://<wso2.deployment.am.ingress.management.hostname>/publisher`

- API Manager DevPortal: `https://<wso2.deployment.am.ingress.management.hostname>/devportal`

- API Manager Carbon Console: `https://<wso2.deployment.am.ingress.management.hostname>/carbon`

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

###### WSO2 Subscription Configurations

| Parameter                        | Description                      | Default Value                                   |
| -------------------------------- | -------------------------------- | ----------------------------------------------- |
| `wso2.subscription.username`     | Your WSO2 Subscription username  | -                                               |
| `wso2.subscription.password`     | Your WSO2 Subscription password  | -                                               |
| `wso2.choreoAnalytics.enabled`   | Chorero Analytics enabled or not | false                                           |
| `wso2.choreoAnalytics.endpoint`  | Choreo Analytics endpoint        | https://analytics-event-auth.choreo.dev/auth/v1 |
| `wso2.choreoAnalytics.onpremKey` | On-prem key for Choreo Analytics | -                                               |

If you do not have an active WSO2 subscription, **do not change** the parameters `wso2.subscription.username` and `wso2.subscription.password`.

###### Chart Dependencies

| Parameter                                     | Description                                                                                                                          | Default Value |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `wso2.deployment.dependencies.mysql`          | Enable the deployment and usage of WSO2 API Management MySQL based Helm Chart                                                        | true          |
| `wso2.deployment.dependencies.nfsProvisioner` | Enable the deployment and usage of NFS Server Provisioner (https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner) | true          |

###### Persistent Runtime Artifact Configurations

| Parameter                                                                                | Description                                                                                 | Default Value |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------- |
| `wso2.deployment.persistentRuntimeArtifacts.storageClass`                                | Appropriate Kubernetes Storage Class                                                        | `nfs`         |
| `wso2.deployment.persistentRuntimeArtifacts.apacheSolrIndexing.enabled`                  | Indicates if persistence of the runtime artifacts for Apache Solr-based indexing is enabled | false         |
| `wso2.deployment.persistentRuntimeArtifacts.apacheSolrIndexing.capacity.carbonDatabase`  | Capacity for persisting the H2 based local Carbon database file                             | 50M           |
| `wso2.deployment.persistentRuntimeArtifacts.apacheSolrIndexing.capacity.solrIndexedData` | Capacity for persisting the Apache Solr indexed data                                        | 50M           |

###### API Manager Server Configurations

| Parameter                                               | Description                                                                               | Default Value                                  |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `wso2.deployment.am.dockerRegistry`                     | Registry location of the Docker image to be used to create API Manager instances          | -                                              |
| `wso2.deployment.am.imageName`                          | Name of the Docker image to be used to create API Manager instances                       | `wso2am`                                       |
| `wso2.deployment.am.imageTag`                           | Tag of the image used to create API Manager instances                                     | 4.2.0                                          |
| `wso2.deployment.am.imagePullPolicy`                    | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | `Always`                                       |
| `wso2.deployment.am.livenessProbe.initialDelaySeconds`  | Initial delay for the live-ness probe for API Manager node                                | 180                                            |
| `wso2.deployment.am.livenessProbe.periodSeconds`        | Period of the live-ness probe for API Manager node                                        | 10                                             |
| `wso2.deployment.am.readinessProbe.initialDelaySeconds` | Initial delay for the readiness probe for API Manager node                                | 180                                            |
| `wso2.deployment.am.readinessProbe.periodSeconds`       | Period of the readiness probe for API Manager node                                        | 10                                             |
| `wso2.deployment.am.resources.requests.memory`          | The minimum amount of memory that should be allocated for a Pod                           | 2Gi                                            |
| `wso2.deployment.am.resources.requests.cpu`             | The minimum amount of CPU that should be allocated for a Pod                              | 2000m                                          |
| `wso2.deployment.am.resources.limits.memory`            | The maximum amount of memory that should be allocated for a Pod                           | 3Gi                                            |
| `wso2.deployment.am.resources.limits.cpu`               | The maximum amount of CPU that should be allocated for a Pod                              | 3000m                                          |
| `wso2.deployment.am.config`                             | Custom deployment configuration file (`<WSO2AM>/repository/conf/deployment.toml`)         | -                                              |
| `wso2.deployment.am.ingress.management.enabled`         | If enabled, create ingress resource for API Manager management consoles                   | true                                           |
| `wso2.deployment.am.ingress.management.hostname`        | Hostname for API Manager Admin Portal, Publisher, DevPortal and Carbon Management Console | `am.wso2.com`                                  |
| `wso2.deployment.am.ingress.management.annotations`     | Ingress resource annotations for API Manager management consoles                          | Community NGINX Ingress controller annotations |
| `wso2.deployment.am.ingress.gateway.enabled`            | If enabled, create ingress resource for API Manager Gateway                               | true                                           |
| `wso2.deployment.am.ingress.gateway.hostname`           | Hostname for API Manager Gateway                                                          | `gateway.am.wso2.com`                          |
| `wso2.deployment.am.ingress.gateway.annotations`        | Ingress resource annotations for API Manager Gateway                                      | Community NGINX Ingress controller annotations |
| `wso2.deployment.am.ingress.websub.enabled`             | If enabled, create ingress resource for WebSub service                                    | true                                           |
| `wso2.deployment.am.ingress.websub.hostname`            | Hostname for API Manager Websub services                                                  | `websub.am.wso2.com`                           |
| `wso2.deployment.am.ingress.websub.annotations`         | Ingress resource annotations for API Manager Websub                                       | Community NGINX Ingress controller annotations |

###### Micro Integrator Server Configurations

| Parameter                                               | Description                                                                           | Default Value                                  |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `wso2.deployment.mi.dockerRegistry`                     | Registry location of the Docker image to be used to create Micro Integrator instances | -                                              |
| `wso2.deployment.mi.imageName`                          | Name of the Docker image to be used to create API Manager instances                   | `wso2mi`                                       |
| `wso2.deployment.mi.imageTag`                           | Tag of the image used to create API Manager instances                                 | 4.2.0                                          |
| `wso2.deployment.mi.imagePullPolicy`                    | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images) | `Always`                                       |
| `wso2.deployment.mi.livenessProbe.initialDelaySeconds`  | Initial delay for the live-ness probe for Micro Integrator node                       | 35                                             |
| `wso2.deployment.mi.livenessProbe.periodSeconds`        | Period of the live-ness probe for Micro Integrator node                               | 10                                             |
| `wso2.deployment.mi.readinessProbe.initialDelaySeconds` | Initial delay for the readiness probe for Micro Integrator node                       | 35                                             |
| `wso2.deployment.mi.readinessProbe.periodSeconds`       | Period of the readiness probe for Micro Integrator node                               | 10                                             |
| `wso2.deployment.mi.resources.requests.memory`          | The minimum amount of memory that should be allocated for a Pod                       | 512Mi                                          |
| `wso2.deployment.mi.resources.requests.cpu`             | The minimum amount of CPU that should be allocated for a Pod                          | 500m                                           |
| `wso2.deployment.mi.resources.limits.memory`            | The maximum amount of memory that should be allocated for a Pod                       | 1Gi                                            |
| `wso2.deployment.mi.resources.limits.cpu`               | The maximum amount of CPU that should be allocated for a Pod                          | 1000m                                          |
| `wso2.deployment.mi.config`                             | Custom deployment configuration file (`<WSO2MI>/conf/deployment.toml`)                | -                                              |
| `wso2.deployment.mi.ingress.management.hostname`        | Hostname for Micro Integrator management apis                                         | `management.mi.wso2.com`                       |
| `wso2.deployment.mi.ingress.management.annotations`     | Ingress resource annotations for API Manager Gateway                                  | Community NGINX Ingress controller annotations |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 API Manager server profiles are based on its [official documentation](https://apim.docs.wso2.com/en/latest/install-and-setup/install/installation-prerequisites/).

###### Kubernetes Specific Configurations

| Parameter                   | Description                                                              | Default Value                  |
| --------------------------- | ------------------------------------------------------------------------ | ------------------------------ |
| `kubernetes.serviceAccount` | Name of the Kubernetes Service Account to which the Pods are to be bound | `wso2am-pattern-1-svc-account` |

###### Using RDBMS instead of the default MySQL pod

Follow the below instructions to use a custom RDBMS instead of the default am-mysql deployment.

1. First deploy the DB with the correct set of users and tables as required for an APIM deployment. You can find the relevant SQL scripts with the APIM product distribution. Please follow https://apim.docs.wso2.com/en/latest/install-and-setup/setup/setting-up-databases/overview for more information on how to set-up the databases.

2. Modify the values.yaml file with the DB configuration parameters used above. Refer the following table

| Parameter                                    | Description                                     | Default Value                                                                                                                                              |
| -------------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `wso2.deployment.am.db.hostname`             | Database hostname                               | `wso2am-mysql-db-service`                                                                                                                                  |
| `wso2.deployment.am.db.port`                 | Database port                                   | `3306`                                                                                                                                                     |
| `wso2.deployment.am.db.type`                 | Database vendor                                 | `mysql`                                                                                                                                                    |
| `wso2.deployment.am.db.driver`               | Database driver                                 | `com.mysql.cj.jdbc.Driver`                                                                                                                                 |
| `wso2.deployment.am.db.driver_url`           | URL path to the jar file of the database driver | `https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.29/mysql-connector-java-8.0.29.jar`                                                         |
| `wso2.deployment.am.db.apim.username`        | Username to connect to the AM database          | `wso2carbon`                                                                                                                                               |
| `wso2.deployment.am.db.apim.password`        | Password to connect to the AM database.         | `wso2carbon`                                                                                                                                               |
| `wso2.deployment.am.db.apim.url`             | JDBC connection URL for the AM database         | `jdbc:mysql://wso2am-mysql-db-service:3306/WSO2AM_DB?          useSSL=false&amp;autoReconnect=true&amp;requireSSL=false&amp;verifyServerCertificate=false` |
| `wso2.deployment.am.db.apim_shared.username` | Username to connect to the AM Shared database   | `wso2carbon`                                                                                                                                               |
| `wso2.deployment.am.db.apim_shared.password` | Password to connect to the AM Shared database   | `wso2carbon`                                                                                                                                               |
| `wso2.deployment.am.db.apim_shared.url`      | JDBC connection URL for the AM Shared database  | `jdbc:mysql://wso2am-mysql-db-service:3306/WSO2AM_SHARED_DB?useSSL=false&amp;autoReconnect=true&amp;requireSSL=false&amp;verifyServerCertificate=false`    |

## Runtime Artifact Persistence and Sharing

- It is **mandatory** to set an appropriate Kubernetes StorageClass in this deployment, for persistence and sharing.

- By default, this deployment uses the `nfs` Kubernetes StorageClass created using the official, stable [NFS Server Provisioner](https://hub.helm.sh/charts/stable/nfs-server-provisioner).

- Only persistent storage solutions supporting `ReadWriteMany` [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)
  are applicable for `wso2.deployment.persistentRuntimeArtifacts.storageClass`.
- Please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/store/Persisting_And_Sharing.md#recommended-storage-options-for-wso2-products)
  for advanced details with regards to WSO2 recommended, storage options.

## Managing Java Keystores and Truststores

- By default, this deployment uses the default keystores and truststores provided by the relevant WSO2 product.

- For advanced details with regards to managing custom Java keystores and truststores in a container based WSO2 product deployment
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/deploy/Managing_Keystores_And_Truststores.md).

## Configuring SSL in Service Exposure

- For WSO2 recommended best practices in configuring SSL when exposing the internal product services to outside of the Kubernetes cluster,
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/route/Routing.md#configuring-ssl).

## Setting up API Manager without Micro Integrator

If you want to setup API Manager only without Micro Integrator, you have to install the charts from source after removing MI templates.

- Clone the repository

  ```
  git clone https://github.com/wso2/kubernetes-apim.git
  ```

- Remove the MI templates by removing the `mi` folder in `<KUBERNETES_HOME>/advanced/am-pattern-1/templates/`.

- Deploy Helm charts

  ```helm
  helm install <RELEASE_NAME> <HELM_HOME>/am-pattern-1 --version 4.2.0-1 --namespace <NAMESPACE> --dependency-update --create-namespace
  ```
