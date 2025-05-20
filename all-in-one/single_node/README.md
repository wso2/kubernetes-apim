# Pattern 0: API-M Deployment with all-in-one setup

This deployment consists of a single API-M node with a single API-M runtime. You can use this pattern if you expect to receive low traffic to your deployment and do not need any high availability in your environment.

![WSO2 API Manager pattern 1 deployment](https://apim.docs.wso2.com/en/4.3.0/assets/img/setup-and-install/single-node-apim-deployment.png)

For advanced details on the deployment pattern, please refer to the official
[documentation](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/single-node/all-in-one-deployment-overview/#single-node-deployment).

## Contents
- [Pattern 0: API-M Deployment with all-in-one setup](#pattern-0-api-m-deployment-with-all-in-one-setup)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
    - [1. Configuring docker images](#1-configuring-docker-images)
      - [1.1. Additional Configurations](#11-additional-configurations)
    - [2. Add ingress controller](#2-add-ingress-controller)
  - [Configuration](#configuration)
    - [1. Configuring helm charts](#1-configuring-helm-charts)
      - [1.1 Mounting Keystore and Truststore using a Kubernetes Secret](#11-mounting-keystore-and-truststore-using-a-kubernetes-secret)
      - [1.2 Encrypting secrets](#12-encrypting-secrets)
      - [1.3 Updating the Helm Chart](#13-updating-the-helm-chart)
      - [1.4  Managing Java Keystores and Truststores](#14--managing-java-keystores-and-truststores)
      - [1.5 Configure SSL in Service Exposure](#15-configure-ssl-in-service-exposure)
    - [2. Install the Helm Chart](#2-install-the-helm-chart)
    - [3. Add a DNS record mapping the hostnames and the external IP](#3-add-a-dns-record-mapping-the-hostnames-and-the-external-ip)
    - [4. Access Management Consoles](#4-access-management-consoles)
  - [Minimal Configuration](#minimal-configuration)

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

## Minimal Configuration

If you want to try WSO2 API Manager with minimal configuration, you do not need to follow all the steps described above. You can simply use the default values provided in the default_values.yaml, which includes the H2 database and the default keystore and truststore. Once the service is up and running, deploy the NGINX Ingress Controller by following the steps outlined [here](#2-add-ingress-controller).
```bash
helm install apim ./all-in-one -f default_values.yaml
```

## Configuration

### 1. General Configuration of Helm Charts

The helm charts for the API Manager deployment are available in the [WSO2 Helm Chart Repository](https://github.com/wso2/helm-apim/tree/4.5.x). You can either use the charts from the repository or clone the repository and use the charts from the local copy.
- The helm naming convention for APIM follows a simple pattern. The following format is used for naming the resources.
```<RELEASE_NAME>-<CHART_NAME>-<RESOURCE_NAME>```

#### 1.1 Add ingress controller

The recommendation is to use [**NGINX Ingress Controller**](https://kubernetes.github.io/ingress-nginx/deploy/) suitable for your cloud environment or local deployment. Some sample annotations that could be used with the ingress resources are as follows.

  - The ingress class should be set to nginx in the ingress resource if you are using the NGINX Ingress Controller.
  - Following are some of the recommended annotations to include in the helm charts for ingresses. These may vary depending on the requirements. Please refer to the [documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) for more information about the annotations.
  
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
  - You need to create a kubernetes secret including the certificate and the private key and include the name of the secret in the helm charts. This will be used for TLS termination in load balancer level by the ingress controller. Please refer to the [documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) for more information.
    ```
    kubectl create secret tls my-tls-secret --key <private key filename> --cert <certificate filename>
    ```

#### 1.2 Mount Keystore and Truststore

- If you are not including the keystore and truststore into the docker image, you can mount them using a Kubernetes secret. Following steps shows how to mount the keystore and truststore using a Kubernetes secret.
- Create a Kubernetes secret with the keystore and truststore files. The secret should contain the primary keystore file, secondary keystore file, internal keystore file, and the truststore file. Note that the secret should be created in the same namespace in which you will be setting up the deployment.
- Make sure to use the same secret name when creating the secret and when configuring the helm chart.
- If you are using a different keystore file name and alias, make sure to update the helm chart configurations accordingly.
In addition to the primary, internal keystores and truststore files, you can also include the keystores for HTTPS transport as well.
- Refer the following sample command to create the secret and use it in the APIM.
  
  ```
  kubectl create secret generic jks-secret --from-file=wso2carbon.jks --from-file=client-truststore.jks --from-file=wso2internal.jks -n <namespace>
  ```
> By default, this deployment uses the default keystores and truststores provided by the relevant WSO2 product.
> For advanced details with regards to managing custom Java keystores and truststores in a container based WSO2 product deployment
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/deploy/Managing_Keystores_And_Truststores.md).

#### 1.3 Encrypting secrets

- If you need to use cipher tool to encrypt the passwords in the secret, first you need to encrypt the passwords using the cipher tool. The cipher tool can be found in the bin directory of the product pack. The following command can be used to encrypt the password.
  ```
  sh cipher-tool.sh -Dconfigure
  ```
- Also the apictl can be used to encrypt password as well. Reference can be found in [following](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/api-controller/encrypting-secrets-with-ctl/).
- Then the encrypted values should be filled in the the relevant fields of values.yaml.
- Since internal keystore password is required to resolve the encrypted value in runtime, we need to store the value in the cloud provider's secret manager. You can use the cloud provider's secret store to store the password of the internal keystore. The following section can be used to add the cloud provider's credentials to fetch the internal keystore password. Configuration for aws can be at as below. 
  ```yaml
  internalKeystorePassword:
    # -- AWS Secrets Manager secret name
    secretName: ""
    # -- AWS Secrets Manager secret key
    secretKey: ""
  ```
  > Please note that currently AWS, Azure and GCP Secrets Managers are only supported for this.



#### 1.4 Configure Docker image and Databases

  - Add the following configurations to reflect the docker image created previously in the helm chart.
    
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
      - [All-in-one](https://github.com/wso2/helm-apim/blob/main/all-in-one/README.md)
      - [Universal Gateway](https://github.com/wso2/helm-apim/blob/main/distributed/gateway/README.md)
    - Update the admin credentials in the configuration directory.
    ```yaml
      # -- Super admin username
      adminUsername: ""
      # -- Super admin password
      adminPassword: ""
    ```
  
#### 1.5 Configure SSL in Service Exposure

* For WSO2 recommended best practices in configuring SSL when exposing the internal product services to outside of the Kubernetes cluster,
  please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/route/Routing.md#configuring-ssl).


### 2. All-in-one Configurations

#### 2.1 Configure multiple gateways

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
        oauth2JWKSUrl: "https://localhost:9443/oauth2/jwks"
```
#### 2.5 Deploy All-in-One

Now deploy the Helm Chart using the following command after creating a namespace for the deployment. Replace <release-name> and <namespace> with appropriate values. Replace <helm-chart-path> with the path to the Helm Deployment.
  
  ```bash
  kubectl create namespace <namespace>
  helm install <release-name> <helm-chart-path> --version 4.5.0-1 --namespace <namespace> --dependency-update --create-namespace
  ```


### 3. Add a DNS record mapping the hostnames and the external IP

Obtain the external IP (EXTERNAL-IP) of the API Manager Ingress resources, by listing down the Kubernetes Ingresses.
```bash
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

- Universal Gateway: `https://<kubernetes.ingress.gateway.hostname>`

