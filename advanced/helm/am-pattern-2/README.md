# Helm Resources for deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager

![WSO2 API Manager pattern 2 deployment](pattern-2.png)

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* In order to use WSO2 Helm resources, you need an active [WSO2 Subscription](https://wso2.com/subscription).
  If you do not possess an active WSO2 Subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).
  Otherwise you can proceed with Docker images, which are created using GA releases.<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)
  (and Tiller) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps
  provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).<br><br>

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/). Please note that Helm resources for WSO2 product
  deployment patterns are compatible with NGINX Ingress Controller Git release [`nginx-0.22.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.22.0).

* Add the WSO2 Helm chart repository.

  ```
   helm repo add wso2 https://helm.wso2.com && helm repo update
  ```

## Quick Start Guide

>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/advanced/helm`. <br>

##### 1. Clone the Helm Resources for WSO2 API Manager Git repository.

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### 2. Provide configurations.

a. The default product configurations are available at `<HELM_HOME>/am-pattern-2/confs` folder. Change the configurations, as necessary.

b. Open the `<HELM_HOME>/am-pattern-2/values.yaml` and provide the following values.

###### WSO2 Subscription Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.subscription.username`                                                | Your WSO2 Subscription username                                                           | ""                          |
| `wso2.subscription.password`                                                | Your WSO2 Subscription password                                                           | ""                          |

If you do not have an active WSO2 subscription, do not change the parameters `wso2.subscription.username` and `wso2.subscription.password`. 

###### Chart Dependencies

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.dependencies.mysql`                                        | Enable the deployment and usage of WSO2 API Management MySQL based Helm Chart             | true                        |
| `wso2.deployment.dependencies.nfsProvisioner`                               | Enable the deployment and usage of NFS Server Provisioner (https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner) | true |

###### Data Source Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.db.type`                                                   | RDBMS server type                                                                         | mysql                       |
| `wso2.deployment.db.hostname`                                               | Set RDBMS server host                                                                     | wso2am-mysql-db-service     |
| `wso2.deployment.db.port`                                                   | Set RDBMS server port                                                                     | 3306                        |
| `wso2.deployment.db.username`                                               | Set RDBMS server username                                                                 | wso2carbon                  |
| `wso2.deployment.db.password`                                               | Set RDBMS server password                                                                 | wso2carbon                  |
| `wso2.deployment.db.driverClass`                                            | Set JDBC driver class for the relevant RDBMS                                              | com.mysql.jdbc.Driver       |
| `wso2.deployment.db.validationQuery`                                        | Validation query for the RDBMS server                                                     | SELECT 1                    |

| Parameter                                                                   | Description                                                                               | Default Value                   |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|---------------------------------|
| `wso2.deployment.db.analyticsDB`                                            | Name of the database used for persisting API Manager statistics aggregated data           | WSO2AM_ANALYTICS_DB             |
| `wso2.deployment.db.permissionsDB`                                          | Name of the database used for persisting permissions and role - permission mappings       | WSO2AM_ANALYTICS_PERMISSIONS_DB |

Please see the official [documentation](https://docs.wso2.com/display/AM260/Configuring+APIM+Analytics#ConfiguringAPIMAnalytics-Step4-Configurethedatabases) on `Configuring WSO2 API Manager Analytics` for configuring databases.

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.db.apimgtDB`                                               | Name of the database used for persisting API Management data                              | WSO2AM_APIMGT_DB            |
| `wso2.deployment.db.regDB`                                                  | Name of the database used for persisting registry data                                    | WSO2AM_REG_DB               |
| `wso2.deployment.db.userDB`                                                 | Name of the database used for persisting user management data                             | WSO2AM_USER_DB              |

Please see the official [documentation](https://docs.wso2.com/display/AM260/Installing+and+Configuring+the+Databases) on `Configuring WSO2 API Manager databases` for configuring databases.

###### Persistent Runtime Artifact Configurations (applicable only when `wso2.deployment.dependencies.nfsProvisioner` is disabled)

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.persistentRuntimeArtifacts.nfsServerIP`                    | External NFS Server IP                                                                    | -                           |
| `wso2.deployment.persistentRuntimeArtifacts.sharedAPIMSynapseConfigsPath`   | Exported location on external NFS Server to be mounted at `<APIM_HOME>/repository/deployment/server/synapse-configs` | -            |
| `wso2.deployment.persistentRuntimeArtifacts.sharedAPIMExecutionPlansPath`   | Exported location on external NFS Server to be mounted at `<APIM_HOME>/repository/deployment/server/executionplans` | -            |

###### API Manager Server Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2am.dockerRegistry`                                     | Registry location of the Docker image to be used to create API Manager instances          | -                           |
| `wso2.deployment.wso2am.imageName`                                          | Name of the Docker image to be used to create API Manager instances                       | wso2am                      |
| `wso2.deployment.wso2am.imageTag`                                           | Tag of the image used to create API Manager instances                                     | 2.6.0                       |
| `wso2.deployment.wso2am.gateway.replicas`                                   | Number of replicas of the Gateway profile to be started                                   | 2                           |
| `wso2.deployment.wso2am.gateway.strategy.rollingUpdate.maxSurge`            | Maximum number of Gateway replicas that can be scheduled above the desired number of replicas, during an update | 2                           |
| `wso2.deployment.wso2am.gateway.strategy.rollingUpdate.maxUnavailable`      | Maximum number of Gateway replicas that can be unavailable during the update                                    | 2                           |
| `wso2.deployment.wso2am.km.replicas`                                        | Number of replicas of the Key Manager profile to be started                                | 1                           |
| `wso2.deployment.wso2am.km.strategy.rollingUpdate.maxSurge`                 | Maximum number of Key Manager replicas that can be scheduled above the desired number of replicas, during an update | 1                           |
| `wso2.deployment.wso2am.km.strategy.rollingUpdate.maxUnavailable`           | Maximum number of Key Manager replicas that can be unavailable during the update                                    | 0                           |
| `wso2.deployment.wso2am.minReadySeconds`                                    | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentspec-v1-apps)| 240        |
| `wso2.deployment.wso2am.livenessProbe.initialDelaySeconds`                  | Initial delay for the live-ness probe for API Manager node                                | 240                         |
| `wso2.deployment.wso2am.livenessProbe.periodSeconds`                        | Period of the live-ness probe for API Manager node                                        | 10                          |
| `wso2.deployment.wso2am.readinessProbe.initialDelaySeconds`                 | Initial delay for the readiness probe for API Manager node                                | 240                         |
| `wso2.deployment.wso2am.readinessProbe.periodSeconds`                       | Period of the readiness probe for API Manager node                                        | 10                          |
| `wso2.deployment.wso2am.resources.requests.memory`                          | The minimum amount of memory that should be allocated for a Pod                           | 2Gi                         |
| `wso2.deployment.wso2am.resources.requests.cpu`                             | The minimum amount of CPU that should be allocated for a Pod                              | 2000m                       |
| `wso2.deployment.wso2am.resources.limits.memory`                            | The maximum amount of memory that should be allocated for a Pod                           | 3Gi                         |
| `wso2.deployment.wso2am.resources.limits.cpu`                               | The maximum amount of CPU that should be allocated for a Pod                              | 3000m                       |
| `wso2.deployment.wso2am.imagePullPolicy`                                    | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | Always                      |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 API Manager server profiles are based on its [official documentation](https://docs.wso2.com/display/AM260/Installation+Prerequisites).

###### Analytics Worker Runtime Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2amAnalyticsWorker.dockerRegistry`                      | Registry location of the Docker image to be used to create an API Manager Analytics instance         | -                           |
| `wso2.deployment.wso2amAnalyticsWorker.imageName`                           | Name of the Docker image to be used to create an API Manager Analytics instance                      | wso2am-analytics-worker     |
| `wso2.deployment.wso2amAnalyticsWorker.imageTag`                            | Tag of the image used to create an API Manager Analytics instance                                    | 2.6.0                       |
| `wso2.deployment.wso2amAnalyticsWorker.replicas`                            | Number of replicas of API Manager Analytics to be started                                            | 1                           |
| `wso2.deployment.wso2amAnalyticsWorker.minReadySeconds`                     | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentspec-v1-apps)|  30                   |
| `wso2.deployment.wso2amAnalyticsWorker.strategy.rollingUpdate.maxSurge`     | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 1                |
| `wso2.deployment.wso2amAnalyticsWorker.strategy.rollingUpdate.maxUnavailable`              | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 0 |
| `wso2.deployment.wso2amAnalyticsWorker.livenessProbe.initialDelaySeconds`   | Initial delay for the live-ness probe for API Manager Analytics node                                | 20                           |
| `wso2.deployment.wso2amAnalyticsWorker.livenessProbe.periodSeconds`         | Period of the live-ness probe for API Manager Analytics node                                        | 10                           |
| `wso2.deployment.wso2amAnalyticsWorker.readinessProbe.initialDelaySeconds`  | Initial delay for the readiness probe for API Manager Analytics node                                | 20                           |
| `wso2.deployment.wso2amAnalyticsWorker.readinessProbe.periodSeconds`        | Period of the readiness probe for API Manager Analytics node                                        | 10                           |
| `wso2.deployment.wso2amAnalyticsWorker.resources.requests.memory`           | The minimum amount of memory that should be allocated for a Pod                                     | 4Gi                          |
| `wso2.deployment.wso2amAnalyticsWorker.resources.requests.cpu`              | The minimum amount of CPU that should be allocated for a Pod                                        | 2000m                        |
| `wso2.deployment.wso2amAnalyticsWorker.resources.limits.memory`             | The maximum amount of memory that should be allocated for a Pod                                     | 4Gi                          |
| `wso2.deployment.wso2amAnalyticsWorker.resources.limits.cpu`                | The maximum amount of CPU that should be allocated for a Pod                                        | 2000m                        |
| `wso2.deployment.wso2amAnalyticsWorker.imagePullPolicy`                     | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)               | Always                       |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 API Manager Analytics Worker profile are based on its [official documentation](https://docs.wso2.com/display/SP440/Installation+Prerequisites).

###### Identity Server as Key Manager Configurations

| Parameter                                                    | Description                                                                                          | Default Value               |
|--------------------------------------------------------------|------------------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2is.enabled`                             | Set to true if the WSO2 Identity Server is to be used as the Key Manager                             | false                       |
| `wso2.deployment.wso2is.dockerRegistry`                      | Registry location of the Docker image to be used to create an IS as KM instance                      | -                           |
| `wso2.deployment.wso2is.imageName`                           | Name of the Docker image to be used to create an IS as KM instance                                   | wso2is-km                   |
| `wso2.deployment.wso2is.imageTag`                            | Tag of the image used to create an IS as KM instance                                                 | 5.7.0                       |
| `wso2.deployment.wso2is.replicas`                            | Number of replicas of IS as KM to be started                                                         | 1                           |
| `wso2.deployment.wso2is.minReadySeconds`                     | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentspec-v1-apps)|  240                  |
| `wso2.deployment.wso2is.strategy.rollingUpdate.maxSurge`     | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 1                |
| `wso2.deployment.wso2is.strategy.rollingUpdate.maxUnavailable`              | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 0 |
| `wso2.deployment.wso2is.livenessProbe.initialDelaySeconds`   | Initial delay for the live-ness probe for IS as KM node                                              | 240                         |
| `wso2.deployment.wso2is.livenessProbe.periodSeconds`         | Period of the live-ness probe for IS as KM node                                                      | 10                          |
| `wso2.deployment.wso2is.readinessProbe.initialDelaySeconds`  | Initial delay for the readiness probe for IS as KM node                                              | 240                         |
| `wso2.deployment.wso2is.readinessProbe.periodSeconds`        | Period of the readiness probe for IS as KM node                                                      | 10                          |
| `wso2.deployment.wso2is.resources.requests.memory`           | The minimum amount of memory that should be allocated for a Pod                                      | 2Gi                         |
| `wso2.deployment.wso2is.resources.requests.cpu`              | The minimum amount of CPU that should be allocated for a Pod                                         | 2000m                       |
| `wso2.deployment.wso2is.resources.limits.memory`             | The maximum amount of memory that should be allocated for a Pod                                      | 3Gi                         |
| `wso2.deployment.wso2is.resources.limits.cpu`                | The maximum amount of CPU that should be allocated for a Pod                                         | 3000m                       |
| `wso2.deployment.wso2is.imagePullPolicy`                     | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)                | Always                      |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 Identity Server as Key Manager profile are based on its [official documentation](https://docs.wso2.com/display/IS570/Installation+Prerequisites).

###### Kubernetes Specific Configurations

| Parameter                                                     | Description                                                                               | Default Value                   |
|---------------------------------------------------------------|-------------------------------------------------------------------------------------------|---------------------------------|
| `kubernetes.serviceAccount`                                   | Name of the Kubernetes Service Account to which the Pods are to be bound                  | wso2am-pattern-2-svc-account    |

##### 3. Deploy WSO2 API Manager pattern 2.

```
helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/am-pattern-2 --namespace <NAMESPACE>
```

`NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed

##### 4. Access Management Console.

Default deployment will expose `<RELEASE_NAME>` host (to expose the Management Console, Publisher, Store and Gateway).

a. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses.

  ```
  kubectl get ing -n <NAMESPACE>
  ```

e.g.

```
NAME                                             HOSTS                       ADDRESS         PORTS     AGE
wso2am-pattern-2-am-gateway-ingress             <RELEASE_NAME>-gateway      <EXTERNAL-IP>   80, 443   7m
wso2am-pattern-2-am-ingress                     <RELEASE_NAME>-am           <EXTERNAL-IP>   80, 443   7m
```

b. Add the above host as an entry in /etc/hosts file as follows:

  ```
  <EXTERNAL-IP>	<RELEASE_NAME>-am
  <EXTERNAL-IP>	<RELEASE_NAME>-gateway
  ```

c. Try navigating to `https://<RELEASE_NAME>-am/carbon`, `https://<RELEASE_NAME>-am/publisher` and `https://<RELEASE_NAME>-am/store` from your favorite browser.
