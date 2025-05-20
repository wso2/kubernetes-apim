# Pattern 4: Helm Chart for Distributed API-M Deployment with Gateway and Traffic Manager Separated from the Control Plane

This is the standard distributed deployment for API Manager. The default configuration consists of two API control planes, two Traffic Managers, and two Universal Gateways. This is a production-ready deployment pattern.

![WSO2 API Manager pattern 4 deployment](https://apim.docs.wso2.com/en/4.5.0/assets/img/setup-and-install/deployment-tm.png)

For advanced details on the deployment pattern, please refer to the official
[documentation](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/single-node/all-in-one-deployment-overview/#single-node-deployment).

## Contents
- [Pattern 4: API-M Deployment Overview](#pattern-4-helm-chart-for-distributed-api-m-deployment-with-gateway-and-traffic-manager-separated-from-the-control-plane)
  - [Contents](#contents)
  - [About this Document](#about-this-document)
  - [Prerequisites](#prerequisites)
    - [1. Basic Configurations](#1-basic-configurations)
    - [2. Build Docker Images](#2-build-docker-images)
    - [3. Configure Database](#3-configure-database)
  - [Minimal Configuration](#minimal-configuration)
  - [Configuration](#configuration)
    - [1. General Configuration of Helm Charts](#1-general-configuration-of-helm-charts)
      - [1.1 Add Ingress Controller](#11-add-ingress-controller)
      - [1.2 Mount Keystore and Truststore](#12-mount-keystore-and-truststore)
      - [1.3 Encrypting Secrets](#13-encrypting-secrets)
      - [1.4 Configure Docker Image and Databases](#14-configure-docker-image-and-databases)
      - [1.5 Configure SSL in Service Exposure](#15-configure-ssl-in-service-exposure)
    - [2. API Control Plane Configurations](#2-api-control-plane-configurations)
      - [2.1 Configure Multiple Gateways](#21-configure-multiple-gateways)
      - [2.2 Configure User Store Properties](#22-configure-user-store-properties)
      - [2.4 Configure JWKS URL](#24-configure-jwks-url)
      - [2.5 Deploy ACP](#25-deploy-acp)
    - [3. Traffic Manager Configurations](#3-traffic-manager-configurations)
      - [3.1 Configure Key Manager and Eventhub](#31-configure-key-manager-and-eventhub)
      - [3.2 Deploy TM](#32-deploy-tm)
    - [4. Universal Gateway Configuration](#4-universal-gateway-configuration)
      - [4.1 Configure Key Manager, Eventhub and Throttling](#41-configure-key-manager-eventhub-and-throttling)
      - [4.2 Deploy Universal Gateway](#42-deploy-universal-gateway)
    - [5. Add a DNS Record Mapping the Hostnames and the External IP](#5-add-a-dns-record-mapping-the-hostnames-and-the-external-ip)
    - [6. Access Management Consoles](#6-access-management-consoles)

## About this Document

This document provides comprehensive instructions for deploying WSO2 API Manager in a distributed Kubernetes environment using Helm charts, with a focus on separating the Traffic Manager and Gateway from the Control Plane. 
- **[Minimal Configuration](#minimal-configuration)**: Offers a quick start guide with pre-configured YAML files, allowing you to rapidly deploy the recommended pattern with minimal setup. This section is ideal for users who want to get started quickly.
- The rest of the document details advanced setup options, including custom Docker image building, database configuration, keystore and truststore management, ingress controller setup, and fine-tuning of Helm chart values for production-grade deployments.

## Prerequisites

### 1. Basic Configurations

- Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://helm.sh/docs/intro/install/), and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to run the steps provided in the following quick start guide.
- An already set up [Kubernetes cluster](https://kubernetes.io/docs/setup).
- Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/). 
- Add the WSO2 Helm chart repository.
  ```bash
  helm repo add wso2 https://helm.wso2.com && helm repo update
  ```

### 2. Build Docker Images

- WSO2 product Docker images are used for the Kubernetes deployment.
  
  WSO2 product Docker images available at [DockerHub](https://hub.docker.com/u/wso2/) package General Availability (GA) versions of WSO2 products with no [WSO2 Updates](https://wso2.com/updates).

  For a production-grade deployment of the desired WSO2 product version, it is highly recommended to use the relevant Docker image which packages WSO2 Updates, available at the [WSO2 Private Docker Registry](https://docker.wso2.com/). To use these images, you need an active [WSO2 Subscription](https://wso2.com/subscription).

- WSO2 API Manager 4.5.0 provides three Docker images:
  - API Control Plane (ACP) - [wso2am-acp](https://hub.docker.com/r/wso2/wso2am-acp)
  - Traffic Manager (TM) - [wso2am-tm](https://hub.docker.com/r/wso2/wso2am-tm)
  - Universal Gateway (GW) - [wso2am-universal-gw](https://hub.docker.com/r/wso2/wso2am-universal-gw)

- Since the products need to connect to databases at runtime, you need to include the relevant JDBC drivers in the distribution. This can be included in the Docker image building stage. For example, you can add the MySQL driver as follows:
  ```dockerfile
  ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib
  ```
- Furthermore, if there are any customizations to the JARs in the product, those can be included in the Docker image itself rather than mounting them from the deployment level (assuming that they are common to all environments).
- The following is a sample Dockerfile to build a custom WSO2 APIM image. Depending on your requirements, you may refer to the following and make the necessary additions. The script below will do the following:
  - Use WSO2 APIM 4.5.0 as the base image
  - Change UID and GID to 10001. The default APIM image has 802 as UID and GID
  - Copy third-party libraries to the `<APIM_HOME>/lib` directory

  - Dockerfile for API Control Plane
    ```dockerfile
    FROM docker.wso2.com/wso2am-acp:4.5.0.0

    ARG USER_HOME=/home/${USER}
    ARG WSO2_SERVER_NAME=wso2am-acp
    ARG WSO2_SERVER_VERSION=4.5.0
    ARG WSO2_SERVER=${WSO2_SERVER_NAME}-${WSO2_SERVER_VERSION}
    ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}

    # Copy JDBC MySQL driver
    ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib
    ```
  
  - Dockerfile for Traffic Manager
    ```dockerfile
    FROM docker.wso2.com/wso2am-tm:4.5.0.0

    ARG USER_HOME=/home/${USER}
    ARG WSO2_SERVER_NAME=wso2am-tm
    ARG WSO2_SERVER_VERSION=4.5.0
    ARG WSO2_SERVER=${WSO2_SERVER_NAME}-${WSO2_SERVER_VERSION}
    ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}

    # Copy JDBC MySQL driver
    ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib
    ```
  
  - Dockerfile for Universal Gateway
    ```dockerfile
    FROM docker.wso2.com/wso2am-universal-gw:4.5.0.0

    ARG USER_HOME=/home/${USER}
    ARG WSO2_SERVER_NAME=wso2am-universal-gw
    ARG WSO2_SERVER_VERSION=4.5.0
    ARG WSO2_SERVER=${WSO2_SERVER_NAME}-${WSO2_SERVER_VERSION}
    ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}

    # Copy JDBC MySQL driver
    ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib
    ```

- Once the required changes have been made to the Dockerfile, you can use the following command to build the custom image. Replace CONTAINER_REGISTRY, IMAGE_REPO, and TAG accordingly.
  ```bash
  docker build -t CONTAINER_REGISTRY/IMAGE_REPO:TAG .
  ```
- After building your custom Docker image, you need to push it to your container registry so it can be accessed by your Kubernetes cluster. Use the following command, replacing `CONTAINER_REGISTRY`, `IMAGE_REPO`, and `TAG` with your values:
  ```bash
  docker push CONTAINER_REGISTRY/IMAGE_REPO:TAG
  ```

### 3. Configure Database

- Before running the API Manager, you must configure the databases and populate them with the initial data. All required database scripts are available in the `dbscripts` directory of the product pack. Locate the appropriate scripts for your chosen database engine and execute them accordingly. It is recommended to use two separate database users with limited permissions for enhanced security.

- An example for MySQL is provided below.
  ```sql
  CREATE DATABASE apim_db CHARACTER SET latin1;
  CREATE DATABASE shared_db CHARACTER SET latin1;

  GRANT ALL ON apim_db.* TO 'apimadmin'@'%';

  CREATE USER 'sharedadmin'@'%' IDENTIFIED BY 'sharedadmin';
  GRANT ALL ON shared_db.* TO 'sharedadmin'@'%';
  ```
  ```bash
  mysql -h <DB_HOST> -P 3306 -u sharedadmin -p -Dshared_db < './dbscripts/mysql.sql';
  mysql -h <DB_HOST> -P 3306 -u apimadmin -p -Dapim_db < './dbscripts/apimgt/mysql.sql';
  ```

## Minimal Configuration

- We have provided pre-configured YAML files to help you quickly start the deployment. You can use these files as a starting point to deploy this pattern. This deployment requires separate databases. Therefore, follow the steps in [2. Build Docker Images](#2-build-docker-images) to build the Docker images with JDBC drivers, and refer to [3. Configure Database](#3-configure-database) to set up the database.
- Follow the steps in [1.2 Mount Keystore and Truststore](#12-mount-keystore-and-truststore) to create the truststore and keystore. If you want to use the WSO2 default keystore and truststore, you can find them in the `repository/resources/security` directory of the product pack. Navigate to this location and run the following command to create the secret:
```bash
kubectl create secret generic jks-secret --from-file=wso2carbon.jks --from-file=client-truststore.jks
```
- Run the following command to deploy the Helm charts:
> **Important:** Naming conventions are important. If you want to change them, ensure consistency. 

1. Deploy ACP
```bash
helm install apim-acp wso2/wso2am-acp -f default_acp_values.yaml
```

2. Deploy TM
```bash
helm install apim-tm wso2/wso2am-tm -f default_tm_values.yaml
```

3. Deploy GW
```bash
helm install apim-gw wso2/wso2am-gw -f default_gw_values.yaml
```

- Once the service is up and running, deploy the NGINX Ingress Controller by following the steps outlined in [1.1 Add Ingress Controller](#11-add-ingress-controller).

## Configuration

### 1. General Configuration of Helm Charts

The Helm charts for the API Manager deployment are available in the [WSO2 Helm Chart Repository](https://github.com/wso2/helm-apim/tree/4.5.x). You can either use the charts from the repository or clone the repository and use the charts from the local copy.
- The Helm naming convention for APIM follows a simple pattern. The following format is used for naming the resources:
```<RELEASE_NAME>-<CHART_NAME>-<RESOURCE_NAME>```

#### 1.1 Add Ingress Controller

The recommendation is to use the [**NGINX Ingress Controller**](https://kubernetes.github.io/ingress-nginx/deploy/) suitable for your cloud environment or local deployment. Some sample annotations that could be used with the ingress resources are as follows:

  - The ingress class should be set to nginx in the ingress resource if you are using the NGINX Ingress Controller.
  - The following are some of the recommended annotations to include in the Helm charts for ingresses. These may vary depending on the requirements. Please refer to the [documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) for more information about the annotations.
  
    ```yaml
    ingressClass: "nginx"
    ingress:
      tlsSecret: ""
      ratelimit:
        enabled: false
        zoneName: ""
        burstLimit: ""
      controlPlane:
        hostname: "am.wso2.com"
        annotations:
          nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
          nginx.ingress.kubernetes.io/affinity: "cookie"
          nginx.ingress.kubernetes.io/session-cookie-name: "route"
          nginx.ingress.kubernetes.io/session-cookie-hash: "sha1"
    ```
  - You need to create a Kubernetes secret including the certificate and the private key and include the name of the secret in the Helm charts. This will be used for TLS termination at the load balancer level by the ingress controller. Please refer to the [documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) for more information.
    ```
    kubectl create secret tls my-tls-secret --key <private key filename> --cert <certificate filename>
    ```

#### 1.2 Mount Keystore and Truststore

- If you are not including the keystore and truststore in the Docker image, you can mount them using a Kubernetes secret. The following steps show how to mount the keystore and truststore using a Kubernetes secret.
- Create a Kubernetes secret with the keystore and truststore files. The secret should contain the primary keystore file, secondary keystore file, internal keystore file, and the truststore file. Note that the secret should be created in the same namespace in which you will be setting up the deployment.
- Make sure to use the same secret name when creating the secret and when configuring the Helm chart.
- If you are using a different keystore file name and alias, make sure to update the Helm chart configurations accordingly.
- In addition to the primary, internal keystores and truststore files, you can also include the keystores for HTTPS transport as well.
- Refer to the following sample command to create the secret and use it in the APIM.
  
  ```
  kubectl create secret generic jks-secret --from-file=wso2carbon.jks --from-file=client-truststore.jks --from-file=wso2internal.jks -n <namespace>
  ```
> By default, this deployment uses the default keystores and truststores provided by the relevant WSO2 product.
> For advanced details regarding managing custom Java keystores and truststores in a container-based WSO2 product deployment,
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/deploy/Managing_Keystores_And_Truststores.md).

#### 1.3 Encrypting Secrets

- If you need to use the cipher tool to encrypt the passwords in the secret, first you need to encrypt the passwords using the cipher tool. The cipher tool can be found in the bin directory of the product pack. The following command can be used to encrypt the password:
  ```
  sh cipher-tool.sh -Dconfigure
  ```
- Also, the apictl can be used to encrypt passwords as well. Reference can be found in the [following](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/api-controller/encrypting-secrets-with-ctl/).
- Then the encrypted values should be filled in the relevant fields of values.yaml.
- Since the internal keystore password is required to resolve the encrypted value at runtime, you need to store the value in the cloud provider's secret manager. You can use the cloud provider's secret store to store the password of the internal keystore. The following section can be used to add the cloud provider's credentials to fetch the internal keystore password. Configuration for AWS can be as below: 
  ```yaml
  internalKeystorePassword:
    # -- AWS Secrets Manager secret name
    secretName: ""
    # -- AWS Secrets Manager secret key
    secretKey: ""
  ```
  > Please note that currently AWS, Azure, and GCP Secrets Managers are only supported for this.

#### 1.4 Configure Docker Image and Databases

  - Add the following configurations to reflect the Docker image created previously in the Helm chart.
    
    ```yaml
    wso2:
      deployment:
        image:
          imagePullSecrets:
            enabled: false
            username: ""
            password: ""		
          registry: ""
          repository: ""
          digest: ""
    ```
    > If you are using a **private Docker registry**, you must enable `imagePullSecrets.enabled` and provide the username and password.
  - Provide the database configurations under the following section.

    ```yaml
    wso2:
      apim:
        configurations:
          databases:
            apim_db:
              url: ""
              username: ""
              password: ""
            shared_db:
              url: ""
              username: ""
              password: ""
    ```
    - If you need to change the hostnames, update them under the Kubernetes ingress section.
    - Update the keystore passwords in the security section of the `values.yaml` file.
    - Review the descriptions of other configurations and modify them as needed to meet your requirements. A simple deployment can be achieved using the basic configurations provided in the `values.yaml` file. All configuration options for each Helm chart are documented in their respective component guides:
      - [API Control Plane](https://github.com/wso2/helm-apim/blob/main/distributed/control-plane/README.md)
      - [Traffic Manager](https://github.com/wso2/helm-apim/blob/main/distributed/traffic-manager/README.md)
      - [Universal Gateway](https://github.com/wso2/helm-apim/blob/main/distributed/gateway/README.md)
    - Update the admin credentials in the configuration directory.
    ```yaml
      # -- Super admin username
      adminUsername: ""
      # -- Super admin password
      adminPassword: ""
    ```
  
#### 1.5 Configure SSL in Service Exposure

* For WSO2 recommended best practices in configuring SSL when exposing the internal product services outside of the Kubernetes cluster,
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/route/Routing.md#configuring-ssl).

### 2. API Control Plane Configurations

#### 2.1 Configure Multiple Gateways

If you need to distribute the Gateway load that comes in, you can configure multiple API Gateway environments in WSO2 API Manager to publish to a single Developer Portal. [See more...](https://apim.docs.wso2.com/en/latest/manage-apis/deploy-and-publish/deploy-on-gateway/deploy-api/deploy-through-multiple-api-gateways/)
```yaml
    gateway:
        # -- APIM Gateway environments
        environments:
        - name: "Default"
          type: "hybrid"
          gatewayType: "Regular"
          provider: "wso2"
          visibility:
          displayInApiConsole: true
          description: "This is a hybrid gateway that handles both production and sandbox token traffic."
          showAsTokenEndpointUrl: true
          serviceName: "apim-gw-wso2am-gateway-service"
          servicePort: 9443
          wsHostname: "websocket.wso2.com"
          httpHostname: "gw.wso2.com"
          websubHostname: "websub.wso2.com"
        - name: "Default_apk"
          type: "hybrid"
          provider: "wso2"
          gatewayType: "APK"
          displayInApiConsole: true
          description: "This is a hybrid gateway that handles both production and sandbox token traffic."
          showAsTokenEndpointUrl: true
          serviceName: "apim-gw-wso2am-gateway-service"
          servicePort: 9443
          wsHostname: "websocket.wso2.com"
          httpHostname: "default.gw.wso2.com:9095"
          websubHostname: "websub.wso2.com"
```

#### 2.2 Configure User Store Properties

You can configure user store properties as described in this [documentation](https://apim.docs.wso2.com/en/latest/administer/managing-users-and-roles/managing-user-stores/working-with-properties-of-user-stores/):

```yaml
    userStore:
    # -- User store type.
    type: "database_unique_id"
    # -- User store properties
    properties:
        ReadGroups: true
```

> **Important:** If you do not want to configure any of the above properties, you must remove the `properties` block from the YAML file.

#### 2.4 Configure JWKS URL
By default, for the super tenant, the Resident Key Manager's JWKS URL is set to `https://<HOSTNAME>:9443/oauth2/jwks`. If you are using a virtual host like `am.wso2.com` that is not globally routable, this URL will be incorrect. You can configure the correct JWKS URL for the super tenant using the Helm chart as shown below:

```yaml
wso2:
  apim:
    configurations:
      oauth_config:
        oauth2JWKSUrl: "https://<ACP_SERVICE_NAME>:9443/oauth2/jwks"
```
#### 2.5 Deploy ACP

Now deploy the Helm Chart using the following command after creating a namespace for the deployment. Replace <release-name> and <namespace> with appropriate values. Replace <helm-chart-path> with the path to the Helm Deployment.
  
  ```bash
  kubectl create namespace <namespace>
  helm install <release-name> <helm-chart-path> --version 4.5.0-1 --namespace <namespace> --dependency-update --create-namespace
  ```

### 3. Traffic Manager Configurations

#### 3.1 Configure Key Manager and Eventhub

- In this pattern, the ACP is used as the Key Manager. Therefore, you need to specify the ACP service URL as the Key Manager service URL.
  ```yaml
    km:
      # -- Key manager service name if default Resident KM is used
      serviceUrl: "<ACP_SERVICE_NAME>"
  ```
- Configure eventhub
  ```yaml
  eventhub:
    # -- Event hub (control plane) load balancer service URL
    serviceUrl: "<ACP_SERVICE_NAME>"
    # -- Event hub service URLs
    urls:
      - "<ACP-1_SERVICE_NAME>"
      - "<ACP-2_SERVICE_NAME>"
  ```

#### 3.2 Deploy TM

Replace <release-name> and <namespace> with appropriate values. Replace <helm-chart-path> with the path to the Helm Deployment.
  
  ```bash
  helm install <release-name> <helm-chart-path> --version 4.5.0-1 --namespace <namespace> --dependency-update --create-namespace
  ```

### 4. Universal Gateway Configuration

#### 4.1 Configure Key Manager, Eventhub and Throttling
- Configure ACP as the Key Manager
  ```yaml
    km:
      # -- Key manager service name if default Resident KM is used
      serviceUrl: "<ACP_SERVICE_NAME>"
  ```
- Configure eventhub
  ```yaml
  eventhub:
    # -- Event hub (control plane) load balancer service URL
    serviceUrl: "<ACP_SERVICE_NAME>"
    # -- Event hub service URLs
    urls:
      - "<ACP-1_SERVICE_NAME>"
      - "<ACP-2_SERVICE_NAME>"
  ```
- Configure throttling
  ```yaml
  throttling:
    serviceUrl: "<TM_SERVICE_NAME>"
    portOffset: 0
    # -- Port of the service URL
    servicePort: 9443
    # -- Traffic manager service URLs. You only need to define one if the TM is not in HA.
    urls:
      - "<TM-1_SERVICE_NAME>"
      - "<TM-2_SERVICE_NAME>"
    # -- Enable unlimited throttling tier
    unlimitedTier: true
    # -- Enable header-based throttling
    headerBasedThrottling: false
    # -- Enable JWT claim-based throttling
    jwtClaimBasedThrottling: false
    # -- Enable query param-based throttling
    queryParamBasedThrottling: false
  ```

#### 4.2 Deploy Universal Gateway

Replace <release-name> and <namespace> with appropriate values. Replace <helm-chart-path> with the path to the Helm Deployment.
  
  ```bash
  helm install <release-name> <helm-chart-path> --version 4.5.0-1 --namespace <namespace> --dependency-update --create-namespace
  ```

### 5. Add a DNS Record Mapping the Hostnames and the External IP

Obtain the external IP (EXTERNAL-IP) of the API Manager Ingress resources by listing the Kubernetes Ingresses.
```
kubectl get ing -n <NAMESPACE>
```

If the defined hostnames (in the previous step) are backed by a DNS service, add a DNS record mapping the hostnames and the external IP (`EXTERNAL-IP`) in the relevant DNS service.

If the defined hostnames are not backed by a DNS service, for the purpose of evaluation you may add an entry mapping the hostnames and the external IP in the `/etc/hosts` file at the client side.

```
<EXTERNAL-IP> <kubernetes.ingress.management.hostname> <kubernetes.ingress.gateway.hostname> <kubernetes.ingress.websub.hostname> <kubernetes.ingress.websocket.hostname> 
```

### 6. Access Management Consoles

- API Manager Publisher: `https://<kubernetes.ingress.management.hostname>/publisher`

- API Manager DevPortal: `https://<kubernetes.ingress.management.hostname>/devportal`

- API Manager Carbon Console: `https://<kubernetes.ingress.management.hostname>/carbon`

- Universal Gateway: `https://<kubernetes.ingress.gateway.hostname>`

