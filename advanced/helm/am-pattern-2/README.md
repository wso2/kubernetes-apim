# Helm Chart for deployment of WSO2 API Manager with WSO2 API Manager Analytics

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* In order to use WSO2 Helm resources, you need an active WSO2 subscription. If you do not possess an active WSO2
  subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription)
  . Otherwise you can proceed with docker images which are created using GA releases.<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)
(and Tiller) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (compatible with v1.10) in order to run the 
steps provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).<br><br>

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/). Please note that Helm resources for WSO2 product
  deployment patterns are compatible with NGINX Ingress Controller Git release [`nginx-0.22.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.22.0).
  
* This chart comes with an internal Network File System(NFS) server which can be used for evaluation purposes. The following conditions should be matched if an external Network File System (NFS) used for artifact sharing and persistence.

A pre-configured Network File System (NFS) to be used as the persistent volume for artifact sharing and persistence.
In the NFS server instance, create a Linux system user account named `wso2carbon` with user id `802` and a system group named `wso2` with group id `802`.
Add the `wso2carbon` user to the group `wso2`.

  ```
   groupadd --system -g 802 wso2
   useradd --system -g 802 -u 802 wso2carbon
  ```
> If you are using AKS(Azure Kubernetes Service) as the kubernetes provider, it is possible to use Azurefiles for persistent storage instead of an NFS. If doing so, skip this step.

* Add WSO2 Helm chart repository

  ```
   helm repo add wso2 https://helm.wso2.com && helm repo update
  ```
  
## Quick Start Guide    

>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/advanced/helm`. <br>

##### 1. Clone Kubernetes Resources for WSO2 API Manager Git repository.

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### 2. Setup persistent storage.

* Using an internal Network File System(NFS) server

    By default the internal NFS server is enabled. For production use, we recommend to use external NFS server. The internal NFS server is enabled with the following configuration,
    ```
    wso2:
       deployment:
         persistentRuntimeArtifacts:
           cloudProvider: internal-nfs
    tags:
       internal-nfs: true
    ```

* Using Azure Files,
  
  Add the following parameter and value to the `<HELM_HOME>/am-pattern-1/values.yaml`.
  ```
  wso2:
    deployment:
      persistentRuntimeArtifacts:
        cloudProvider: Azure
  tags:
    internal-nfs: false
  ```
  
* Using a External Network File System (NFS),

  Create and export an unique directory within the NFS server instance and set the following configuration:

  ```
  wso2:
    deployment:
      persistentRuntimeArtifacts:
        cloudProvider: external-nfs
        nfsServerIP: <NFS_SERVER_IP>
        sharedAPIMLocationPath: <PATH_TO_DIRECTORY_IN_NFS_SERVER>
  tags:
    internal-nfs: false
  ```
  Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

  ```
  sudo chown -R wso2carbon:wso2 <directory_name>
  ```

  Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

  ```
  chmod -R 700 <directory_name>
  ```

##### 3. Provide configurations.

a. The default product configurations are available at `<HELM_HOME>/am-pattern-2/confs` folder. Change the
configurations as necessary.

b. Open the `<HELM_HOME>/am-pattern-2/values.yaml` and provide the following values.

###### MySQL Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.mysql.enabled`                                                        | Enable MySQL chart as a dependency                                                        | true                        |
| `wso2.mysql.host`                                                           | Set MySQL server host                                                                     | wso2am-mysql-db-service     |
| `wso2.mysql.port`                                                           | Set MySQL server port                                                                     | 3306                        |
| `wso2.mysql.username`                                                       | Set MySQL server username                                                                 | wso2carbon                  |
| `wso2.mysql.password`                                                       | Set MySQL server password                                                                 | wso2carbon                  |
| `wso2.mysql.driverClass`                                                    | Set JDBC driver class for MySQL                                                           | com.mysql.jdbc.Driver       |
| `wso2.mysql.validationQuery`                                                | Validation query for the MySQL server                                                     | SELECT 1                    |

###### WSO2 Subscription Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.subscription.username`                                                | Your WSO2 Subscription username                                                           | ""                          |
| `wso2.subscription.password`                                                | Your WSO2 Subscription password                                                           | ""                          |

If you do not have active WSO2 subscription do not change the parameters `wso2.deployment.username`, `wso2.deployment.password`. 

###### Centralized Logging Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.centralizedLogging.enabled`                                           | Enable Centralized logging for WSO2 components                                            | true                        |                                                                                         |                             |    
| `wso2.centralizedLogging.logstash.imageTag`                                 | Logstash Sidecar container image tag                                                      | 7.2.0                       |  
| `wso2.centralizedLogging.logstash.elasticsearch.username`                   | Elasticsearch username                                                                    | elastic                     |  
| `wso2.centralizedLogging.logstash.elasticsearch.password`                   | Elasticsearch password                                                                    | changeme                    |  
| `wso2.centralizedLogging.logstash.indexNodeID.wso2ApimNode1`                | Elasticsearch AM Node 1 log index ID(index name: ${NODE_ID}-${NODE_IP})                   | wso2-am-node-1              |  
| `wso2.centralizedLogging.logstash.indexNodeID.wso2ApimNode2`                | Elasticsearch AM Node 2 log index ID(index name: ${NODE_ID}-${NODE_IP})                   | wso2-am-node-2              |
| `wso2.centralizedLogging.logstash.indexNodeID.wso2AMAnalyticsWorkerNode`    | Elasticsearch AM-Analytics Node log index ID(index name: ${NODE_ID}-${NODE_IP})           | wso2am-analytics-worker-node|
 
###### WSO2 AM configurations

| Parameter                                                                   | Description                                                                                                     | Default Value               |
|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.persistentRuntimeArtifacts.nfsServerIP`                    | NFS Server IP                                                                                                   | **Required**                | 
| `wso2.deployment.persistentRuntimeArtifacts.sharedAPIMLocationPath`         | NFS shared deployment directory (`<APIM_HOME>/repository/deployment`) location for API Manager deployment       | **Required**                |
| `wso2.deployment.wso2am.imageName`                                          | Image name for AM node                                                                                          | wso2am                      |
| `wso2.deployment.wso2am.imageTag`                                           | Image tag for AM node                                                                                           | 2.6.0                       |
| `wso2.deployment.wso2am.replicas`                                           | Number of replicas for AM node                                                                                  | 1                           |
| `wso2.deployment.wso2am.minReadySeconds`                                    | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentspec-v1-apps)     | 75                          |
| `wso2.deployment.wso2am.strategy.rollingUpdate.maxSurge`                    | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 1                           |
| `wso2.deployment.wso2am.strategy.rollingUpdate.maxUnavailable`              | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 0                           |
| `wso2.deployment.wso2am.livenessProbe.initialDelaySeconds`                  | Initial delay for the live-ness probe for AM node                                                               | 250                         |
| `wso2.deployment.wso2am.livenessProbe.periodSeconds`                        | Period of the live-ness probe for AM node                                                                       | 10                          |
| `wso2.deployment.wso2am.readinessProbe.initialDelaySeconds`                 | Initial delay for the readiness probe for AM node                                                               | 250                         |
| `wso2.deployment.wso2am.readinessProbe.periodSeconds`                       | Period of the readiness probe for AM node                                                                       | 10                          |
| `wso2.deployment.wso2am.imagePullPolicy`                                    | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)                           | Always                      |
| `wso2.deployment.wso2am.resources.requests.memory`                          | The minimum amount of memory that should be allocated for a Pod                                                 | 2Gi                         |
| `wso2.deployment.wso2am.resources.requests.cpu`                             | The minimum amount of CPU that should be allocated for a Pod                                                    | 2000m                       |
| `wso2.deployment.wso2am.resources.limits.memory`                            | The maximum amount of memory that should be allocated for a Pod                                                 | 3Gi                         |
| `wso2.deployment.wso2am.resources.limits.cpu`                               | The maximum amount of CPU that should be allocated for a Pod                                                    | 3000m                       |

###### Analytics Worker Runtime Configurations
| Parameter                                                                   | Description                                                                                                     | Default Value               |
|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2amAnalyticsWorker.imageName`                           | Image name for AM-analytics-worker node                                                                         | wso2am-analytics-worker     |
| `wso2.deployment.wso2amAnalyticsWorker.imageTag`                            | Image tag for AM-analytics-worker node                                                                          | 2.6.0                       |
| `wso2.deployment.wso2amAnalyticsWorker.replicas`                            | Number of replicas for AM-analytics-worker node                                                                 | 1                           |
| `wso2.deployment.wso2amAnalyticsWorker.minReadySeconds`                     | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentspec-v1-apps)     | 1  75                       |
| `wso2.deployment.wso2amAnalyticsWorker.strategy.rollingUpdate.maxSurge`     | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps) | 2                           |  
| `wso2.deployment.wso2amAnalyticsWorker.strategy.rollingUpdate.maxUnavailable`| Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deploymentstrategy-v1-apps)| 0                           |
| `wso2.deployment.wso2amAnalyticsWorker.livenessProbe.initialDelaySeconds`   | Initial delay for the live-ness probe for AM-analytics-worker node                                              | 20                          |
| `wso2.deployment.wso2amAnalyticsWorker.livenessProbe.periodSeconds`         | Period of the live-ness probe for AM-analytics-worker node                                                      | 10                          |
| `wso2.deployment.wso2amAnalyticsWorker.readinessProbe.initialDelaySeconds`  | Initial delay for the readiness probe for AM-analytics-worker node                                              | 20                          |
| `wso2.deployment.wso2amAnalyticsWorker.readinessProbe.periodSeconds`        | Period of the readiness probe for AM-analytics-worker node                                                      | 10                          |
| `wso2.deployment.wso2amAnalyticsWorker.imagePullPolicy`                     | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)                           | Always                      |
| `wso2.deployment.wso2amAnalyticsWorker.resources.requests.memory`           | The minimum amount of memory that should be allocated for a Pod                                                 | 4Gi                         |
| `wso2.deployment.wso2amAnalyticsWorker.resources.requests.cpu`              | The minimum amount of CPU that should be allocated for a Pod                                                    | 2000m                       |
| `wso2.deployment.wso2amAnalyticsWorker.resources.limits.memory`             | The maximum amount of memory that should be allocated for a Pod                                                 | 4Gi                         |
| `wso2.deployment.wso2amAnalyticsWorker.resources.limits.cpu`                | The maximum amount of CPU that should be allocated for a Pod                                                    | 2000m                       |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 Stream Processor server worker profile
is based on its [official documentation](https://docs.wso2.com/display/SP440/Installation+Prerequisites).
Also, see the [official documentation](https://docs.wso2.com/display/SP440/Performance+Analysis+Results) on WSO2 Stream Processor
based Performance Analysis and Resource recommendations and tune the limits according to your needs, where necessary.

###### Kubernetes Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `kubernetes.svcaccount`                                                     | Kubernetes Service Account in the `namespace` to which product instance pods are attached | wso2am-pattern-1-svc-account|

##### 4. Deploy WSO2 API Manager pattern-1.

```
helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/am-pattern-2 --namespace <NAMESPACE>
```

##### 5. Access Management Console:

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