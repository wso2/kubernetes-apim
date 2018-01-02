# Pattern-2 Deployment 

### Deploy Pattern-2 with WSO2 API Manager Key Manager

* Use deploy-kubernetes.sh/deploy-openshift.sh to deploy on Kubernetes or Openshift.
* Use undeploy-kubernetes.sh/undeploy-openshift.sh to deploy on Kubernetes or Openshift.

### Deploy Pattern-2 with WSO2 Identity Server as Key Manager

* Comment Key Manager related config maps, services and deployment in deploy-kubernetes.sh/deploy-openshift.sh.
* Uncomment Identity Server related config maps, services and deployment in deploy-kubernetes.sh/deploy-openshift.sh.
* Use deploy-kubernetes.sh/deploy-openshift.sh to deploy on Kubernetes or Openshift.

* Comment Key Manager related config maps, services and deployment in undeploy-kubernetes.sh/undeploy-openshift.sh.
* Uncomment Identity Server related config maps in undeploy-kubernetes.sh/undeploy-openshift.sh.
* Use undeploy-kubernetes.sh/undeploy-openshift.sh to undeploy on Kubernetes or Openshift.

![alt tag](https://github.com/wso2/kubernetes-apim/blob/2.1.0/pattern-2/pattern-2.png)
