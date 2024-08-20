# Pattern 1: API-M Deployment with all-in-one setup

This deployment consists of a single API-M node with a single API-M runtime. You can use this pattern if you expect to receive low traffic to your deployment and do not need any high availability in your environement.

![WSO2 API Manager pattern 1 deployment](https://apim.docs.wso2.com/en/4.3.0/assets/img/setup-and-install/single-node-apim-deployment.png)

For advanced details on the deployment pattern, please refer to the official
[documentation](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/single-node/all-in-one-deployment-overview/#single-node-deployment).

## Contents
- [Pattern 1: API-M Deployment with all-in-one setup](#pattern-1-api-m-deployment-with-all-in-one-setup)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
    - [1. Configuring docker images](#1-configuring-docker-images)
      - [1.1. Additional Configurations](#11-additional-configurations)
    - [2. Adding ingress controller](#2-adding-ingress-controller)
  - [Configuration](#configuration)
    - [1. Configuring helm charts](#1-configuring-helm-charts)
      - [1.1 Mounting Keystore and Truststore using a Kubernetes Secret](#11-mounting-keystore-and-truststore-using-a-kubernetes-secret)
      - [1.2 Updating the Helm Chart](#12-updating-the-helm-chart)
      - [1.3  Managing Java Keystores and Truststores](#13--managing-java-keystores-and-truststores)
      - [1.4 Configuring SSL in Service Exposure](#14-configuring-ssl-in-service-exposure)
    - [2. Install the Helm Chart](#2-install-the-helm-chart)
    - [3. Add a DNS record mapping the hostnames and the external IP](#3-add-a-dns-record-mapping-the-hostnames-and-the-external-ip)
    - [4. Access Management Consoles](#4-access-management-consoles)

## Prerequisites

- WSO2 product Docker images used for the Kubernetes deployment.
  
  WSO2 product Docker images available at [DockerHub](https://hub.docker.com/u/wso2/) package General Availability (GA)
  versions of WSO2 products with no [WSO2 Updates](https://wso2.com/updates).

  For a production grade deployment of the desired WSO2 product-version, it is highly recommended to use the relevant
  Docker image which packages WSO2 Updates, available at [WSO2 Private Docker Registry](https://docker.wso2.com/). In order
  to use these images, you need an active [WSO2 Subscription](https://wso2.com/subscription).

- Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://helm.sh/docs/intro/install/)
  and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the
  following quick start guide.
- An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup).
- Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/). 
- Add the WSO2 Helm chart repository.

    ```
     helm repo add wso2 https://helm.wso2.com && helm repo update
    ```

## Setup
### 1. Configuring docker images
 - WSO2 Product Docker images are required for the deployment. You could either use the images available in the WSO2 private docker registry or you could build your own images.
 - It is recommended to push your own images to the cloud provider's container registry (ACR, ECR, etc.) as a best practice. In order to obtain a docker image for each product please refer to [U2 documentation](https://updates.docs.wso2.com/en/latest/updates/how-to-use-docker-images-to-receive-updates/).
 - You can also use your locally built docker images as well after adding relevant configurations in the values.yaml file under the following section.
  
    ```
    deployment:
      image:
        registry: ""
        repository: ""
        digest: ""
        imagePullPolicy: Always
    ```
 - You need [Docker](https://www.docker.com/get-docker) v20.10.x or above to build the custom docker images.
 - Base Dockerfiles can be obtained for APIM using https://github.com/wso2/docker-apim
>   You need a valid WSO2 subscription to obtain the **U2 updated** docker images from the WSO2 private registry.


#### 1.1. Additional Configurations
 - The default WSO2 docker images come with UID and GID set to 802. Some may consider this not up to standards since these values are usually expected to be over 10000. Therefore, it would be better to build the docker images from scratch using our product Dockerfiles with the relevant user and group IDs.
  
    ```
    # set Docker image build arguments
    # build arguments for user/group configurations
    ARG USER=wso2carbon
    ARG USER_ID=10001
    ARG USER_GROUP=wso2
    ARG USER_GROUP_ID=10001
    ```
- Since the products need to connect to databases at runtime, we need to include the relevant JDBC drivers in the distribution. This too can be included in the docker image building stage. For example, you can add the MySQL driver as follows.
    ```
    ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib
    ```
- Furthermore, if there are any customizations to the jars in the product, that too can be included in the docker image itself rather than mounting those from the deployment level (assuming that they are common to all environments).
- Following is a sample Dockerfile to build a custom WSO2 APIM image. Depending on the requirement you may refer to the following and do the necessary additions. The below script will do the following,
Use WSO2 APIM 4.3.0 as the base image
Change UID and GID to 10001. Default APIM image has 802 as UID and GID
Copy 3rd party libraries to the <APIM_HOME>/lib directory
    ```
    FROM docker.wso2.com/.wso2am:4.3.0.0

    # Change UID and GID
    USER root
    RUN usermod -u 10001 wso2carbon
    RUN groupmod -g 10001 wso2

    # Switch back to non-root WSO2 user
    USER wso2carbon

    ARG USER_HOME=/home/${USER}
    ARG WSO2_SERVER_NAME=wso2am
    ARG WSO2_SERVER_VERSION=4.3.0
    ARG WSO2_SERVER=${WSO2_SERVER_NAME}-${WSO2_SERVER_VERSION}
    ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}

    # Copy jdbc mysql driver
    ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib
    ```

- Once the required changes have been done to the Dockerfile you can use the following command to build the custom image. You will need to replace CONTAINER_REGISTRY, IMAGE_REPO and TAG accordingly.
    ```
    docker build -t CONTAINER_REGISTRY/IMAGE_REPO:TAG .
    ```

### 2. Adding ingress controller

The recommendation is to use [**NGINX Ingress Controller**](https://kubernetes.github.io/ingress-nginx/deploy/) suitable for your cloud environment or local deployment. Some sample annotations that could be used with the ingress resources are as follows.

  - The ingress class should be set to nginx in the ingress resource if you are using the NGINX Ingress Controller.
  - Following are some of the recommended annotations to include in the helm charts for ingresses. These may vary depending on the requirements. Please refer to the [documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) for more information about the annotations.
  
    ```
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      nginx.ingress.kubernetes.io/affinity: "cookie"
      nginx.ingress.kubernetes.io/session-cookie-name: "route"
      nginx.ingress.kubernetes.io/session-cookie-hash: "sha1"
      nginx.ingress.kubernetes.io/proxy-buffering: "on"
      nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"
    ```
  - You need to create a kubernetes secret including the certificate and the private key and include the name of the secret in the helm charts. This will be used for TLS termination in load balancer level by the ingress controller. Please refer to the [documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) for more information.
    ```
    kubectl create secret tls my-tls-secret --key <private key filename> --cert <certificate filename>
    ```
## Configuration
### 1. Configuring helm charts

The helm charts for the API Manager deployment are available in the [WSO2 Helm Chart Repository](https://github.com/wso2/helm-apim). You can either use the charts from the repository or clone the repository and use the charts from the local copy.
- The helm naming convention for APIM follows a simple pattern. The following format is used for naming the resources.
```<RELEASE_NAME>-<CHART_NAME>-<RESOURCE_NAME>```

#### 1.1 Mounting Keystore and Truststore using a Kubernetes Secret

- If you are not including the keystore and truststore into the docker image, you can mount them using a Kubernetes secret. Following steps shows how to mount the keystore and truststore using a Kubernetes secret.
- Create a Kubernetes secret with the keystore and truststore files. The secret should contain the primary keystore file, secondary keystore file, internal keystore file, and the truststore file. Note that the secret should be created in the same namespace in which you will be setting up the deployment.
- Make sure to use the same secret name when creating the secret and when configuring the helm chart.
- If you are using a different keystore file name and alias, make sure to update the helm chart configurations accordingly.
In addition to the primary, internal keystores and truststore files, you can also include the keystores for HTTPS transport as well.
- Refer the following sample command to create the secret and use it in the APIM.
  
  ```
  kubectl create secret generic jks-secret --from-file=wso2carbon.jks --from-file=client-truststore.jks --from-file=wso2internal.jks -n <namespace>
  ```

#### 1.2 Updating the Helm Chart

 - Once charts are cloned from [WSO2 Helm Chart Repository](https://github.com/wso2/helm-apim), navigate to the `all-in-one ` directory to access the all-in-one deployment pattern.
 - Replace the values.yaml file in this directory with the values.yaml file in the cloned repository.
 - Add the following configurations to reflect the docker image created previously in the helm chart.
  
    ```
    wso2:
      deployment:
        image:		
          registry: ""
          repository: ""
          digest: ""
    ```
 - Provide the database configurations under the following section.

    ```
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
  - If you need to change the hostnames, change it under the kubernetes ingress section. 
  - Update the passwords for the admin credentials under the configuration directory.
  - Update passwords of the keystores accordingly under the security section of the values.yaml file.
  - Read the descriptions of other configurations and change them accordingly if there are any other requirements. A simple deployment can be achieved from the basic configurations provided in the values.yaml file. All the configurations for this helm chart is documented in the [documentation](https://github.com/wso2/helm-apim/blob/main/all-in-one/README.md).
  - Change user id for container with following configuration if you have change under the configuring docker section above.
    ```
    securityContext:
      # -- User ID of the container
      runAsUser: 10001
    ```

  #### 1.3  Managing Java Keystores and Truststores

* By default, this deployment uses the default keystores and truststores provided by the relevant WSO2 product.

* For advanced details with regards to managing custom Java keystores and truststores in a container based WSO2 product deployment
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/deploy/Managing_Keystores_And_Truststores.md).
  
#### 1.4 Configuring SSL in Service Exposure

* For WSO2 recommended best practices in configuring SSL when exposing the internal product services to outside of the Kubernetes cluster,
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/route/Routing.md#configuring-ssl).

### 2. Install the Helm Chart

Now deploy the Helm Chart using the following command after creating a namespace for the deployment. Replace <release-name> and <namespace> with appropriate values. Replace <helm-chart-path> with the path to the Helm Deployment.
  
  ```
  kubectl create namespace <namespace>
  helm install <release-name> <helm-chart-path> --version 4.3.0-1 --namespace <namespace> --dependency-update --create-namespace
  ```


### 3. Add a DNS record mapping the hostnames and the external IP

Obtain the external IP (EXTERNAL-IP) of the API Manager Ingress resources, by listing down the Kubernetes Ingresses.
```
kubectl get ing -n <NAMESPACE>
```

If the defined hostnames (in the previous step) are backed by a DNS service, add a DNS record mapping the hostnames and
the external IP (`EXTERNAL-IP`) in the relevant DNS service.

If the defined hostnames are not backed by a DNS service, for the purpose of evaluation you may add an entry mapping the
hostnames and the external IP in the `/etc/hosts` file at the client-side.

```
<EXTERNAL-IP> <kubernetes.ingress.management.hostname> <kubernetes.ingress.gateway.hostname> <kubernetes.ingress.websub.hostname> <kubernetes.ingress.websocket.hostname> 
```

### 4. Access Management Consoles

- API Manager Publisher: `https://<kubernetes.ingress.management.hostname>/publisher`

- API Manager DevPortal: `https://<kubernetes.ingress.management.hostname>/devportal`

- API Manager Carbon Console: `https://<kubernetes.ingress.management.hostname>/carbon`

  
