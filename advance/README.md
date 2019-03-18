# Kubernetes and Helm Resources for WSO2 API Manager
*Kubernetes and Helm Resources for container-based deployments of WSO2 API Manager deployment patterns*

This repository contains Kubernetes and Helm resources required for,

* WSO2 API Manager pattern 1

* WSO2 API Manager pattern 2

## Deploy Kubernetes resources

In order to deploy Kubernetes resources for each deployment pattern, follow the **Quick Start Guide**s for each deployment pattern
given below:

* [WSO2 API Manager pattern 1](pattern-1/README.md)

* [WSO2 API Manager pattern 2](pattern-2/README.md)

## Deploy Helm resources

In order to deploy Helm resources for each deployment pattern, follow the **Quick Start Guide**s for each deployment pattern
given below:

* [WSO2 API Manager pattern 1](helm/pattern-1/README.md)

* [WSO2 API Manager pattern 2](helm/pattern-2/README.md)

## How to update configurations

Kubernetes resources for WSO2 products use Kubernetes [ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
to pass on the minimum set of configurations required to setup a product deployment pattern.

For example, the minimum set of configurations required to setup pattern 1 of WSO2 API Manager can be found
in `<KUBERNETES_HOME>/pattern-1/confs` directory. The Kubernetes ConfigMaps are generated from these files.

If you intend to pass on any additional files with configuration changes, third-party libraries, OSGi bundles and security
related artifacts to the Kubernetes cluster, you may mount the desired content to `/home/wso2carbon/wso2-server-volume` directory path within
a WSO2 product Docker container.

The following example depicts how this can be achieved when passing additional configurations to WSO2 API Manager in pattern 1 of WSO2 API Manager:

a. In order to apply the updated configurations, WSO2 product server instances need to be restarted. Hence, un-deploy all the Kubernetes resources
corresponding to the product deployment, if they are already deployed.

b. Create and export a directory within the NFS server instance.
   
c. Add the additional configuration files, third-party libraries, OSGi bundles and security related artifacts, into appropriate
folders matching that of the relevant WSO2 product home folder structure, within the previously created directory.

d. Grant ownership to `wso2carbon` user and `wso2` group, for the directory created in step (b).
      
   ```
   sudo chown -R wso2carbon:wso2 <directory_name>
   ```
      
e. Grant read-write-execute permissions to the `wso2carbon` user, for the directory created in step (b).
      
   ```
   chmod -R 700 <directory_name>
   ```

f. Map the directory created in step (b) to a Kubernetes [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
in the `<KUBERNETES_HOME>/pattern-1/volumes/persistent-volumes.yaml` file. For example, append the following entry to the file:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wso2apim-with-analytics-additional-config-pv
  labels:
    purpose: apim-additional-configs
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS_SERVER_IP>
    path: "<NFS_LOCATION_PATH>"
```

Provide the appropriate `NFS_SERVER_IP` and `NFS_LOCATION_PATH`.

g. Create a Kubernetes Persistent Volume Claim to bind with the Kubernetes Persistent Volume created in step e. For example, append the following entry
to the file `<KUBERNETES_HOME>/pattern-1/apim/wso2apim-volume-claim.yaml`:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wso2apim-with-analytics-additional-config-volume-claim
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: ""
  selector:
    matchLabels:
      purpose: apim-additional-configs
```

h. Update the appropriate Kubernetes [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) resource(s).
For example in the discussed scenario, update the volumes (`spec.template.spec.volumes`) and volume mounts (`spec.template.spec.containers[wso2apim-with-analytics-apim-worker].volumeMounts`) in
`<KUBERNETES_HOME>/pattern-1/apim/wso2apim-deployment.yaml` file as follows:

```
volumeMounts:
...
- name: wso2apim-with-analytics-additional-config-storage-volume
  mountPath: "/home/wso2carbon/wso2-server-volume"

volumes:
...
- name: wso2apim-with-analytics-additional-config-storage-volume
  persistentVolumeClaim:
    claimName: wso2apim-with-analytics-additional-config-volume-claim
```

i. Deploy the Kubernetes resources as defined in section **Quick Start Guide** for the pattern 1 of WSO2 API Manager.
