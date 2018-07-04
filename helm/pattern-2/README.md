# Helm Charts for deployment of WSO2 API Manager with a separate Gateway and a separate Key Manager

## Prerequisites

* In order to use WSO2 Helm resources, you need an active WSO2 subscription. If you do not possess an active WSO2
  subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)
(and Tiller) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the 
steps provided in the following quick start guide.<br><br>

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/). This can
 be easily done via 
  ```
  helm install stable/nginx-ingress --name nginx-wso2apim-gw-km-with-analytics --set rbac.create=true
  ```
## Quick Start Guide
>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-apim`](https://github.com/wso2/kubernetes-apim/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/helm/pattern-2`. <br>

##### 1. Checkout Kubernetes Resources for WSO2 API Manager Git repository:

```
git clone https://github.com/wso2/kubernetes-apim.git
```

##### 2. Provide configurations:

1. The default product configurations are available at `<HELM_HOME>/apim-gw-km-with-analytics-conf/confs` folder. Change the 
configurations as necessary.

2. Open the `<HELM_HOME>/apim-gw-km-with-analytics-conf/values.yaml` and provide the following values.

    `username`: Username of your WSO2 subscription credentials<br>
    `password`: Password of your WSO2 subscription credentials<br>
    `email`: Docker email<br>
    `namespace`: Namespace<br>
    `svcaccount`: Service Account<br>
    `serverIp`: NFS Server IP<br>
    `locationPath`: NFS location path<br>
    `sharedDeploymentLocationPath`: NFS shared deployment directory(<APIM_HOME>/repository/deployment) location for APIM<br> 
    `analyticsDataLocationPath`: NFS volume for Indexed data for Analytics(<DAS_HOME>/repository/data)<br>
    `analyticsLocationPath`: NFS volume for Analytics data for Analytics(<DAS_HOME>/repository/analytics)<br>
    
3. Open the `<HELM_HOME>/apim-gw-km-with-analytics-deployment/values.yaml` and provide the following values.

    `namespace`: Namespace<br>
    `svcaccount`: Service Account
    
##### 3. Deploy the configurations:

```
helm install --name <RELEASE_NAME> <HELM_HOME>/apim-gw-km-with-analytics-conf
```

##### 4. Deploy MySQL:
If there is an external product database(s), add those configurations as stated at `step 2.1`. Otherwise, run the below
 command to create the product database. 
```
helm install --name wso2apim-pattern-2-rdbms-service -f <HELM_HOME>/mysql/values.yaml 
stable/mysql --namespace <NAMESPACE>
```
`NAMESPACE` should be same as `step 2.2`.

##### 5. Deploy WSO2 API Manager with Analytics:

```
helm install --name <RELEASE_NAME> <HELM_HOME>/apim-gw-km-with-analytics-deployment
```

##### 6. Access Management Console:

Default deployment will expose three publicly accessible hosts, namely:<br>
1. `wso2apim` - To expose Administrative services and Management Console<br>
2. `wso2apim-analytics` - To expose Analytics server<br>
3. `wso2apim-gateway` - To expose Gateway<br>

To access the console in a test environment,

1. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses (using `kubectl get ing -n <NAMESPACE>`).

e.g.

```
NAME                            HOSTS                ADDRESS          PORTS     AGE
wso2apim-analytics-ingress      wso2apim-analytics   <EXTERNAL-IP>   80, 443   12h
wso2apim-gateway-ingress        wso2apim-gateway     <EXTERNAL-IP>   80, 443   12h
wso2apim-ingress                wso2apim             <EXTERNAL-IP>   80, 443   12h
```

2. Add the above three hosts as entries in /etc/hosts file as follows:

```
<EXTERNAL-IP>	wso2apim
<EXTERNAL-IP>	wso2apim-analytics
<EXTERNAL-IP>	wso2apim-gateway
```

3. Try navigating to `https://wso2apim/carbon` from your favorite browser.

