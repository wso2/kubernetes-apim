# Manager Non-Configuration Files

## How to introduce additional artifacts

If you intend to pass on any additional artifacts such as, third-party libraries, OSGi bundles and security related artifacts to the Kubernetes cluster,
you may mount the desired content to `/home/wso2carbon/wso2-artifact-volume` directory path within a WSO2 product Docker container.

The following example depicts how this can be achieved when passing additional artifacts to WSO2 API Manager nodes
in a clustered deployment of WSO2 API Manager:

**[1] In order to apply the updated configurations, WSO2 product server instances need to be restarted. Hence, un-deploy all the Kubernetes resources
corresponding to the product deployment, if they are already deployed.**

**[2] Create and export a directory within the NFS server instance.**
   
**[3] Add the additional third-party libraries, OSGi bundles and security related artifacts, into appropriate
folders matching that of the relevant WSO2 product home folder structure, within the previously created directory.**

**[4] Grant ownership to `wso2carbon` user and `wso2` group, for the directory created in step [2].**
      
   ```
   sudo chown -R wso2carbon:wso2 <directory_name>
   ```
      
**[5] Grant read-write-execute permissions to the `wso2carbon` user, for the directory created in step [2].**
      
   ```
   chmod -R 700 <directory_name>
   ```

**[6] Map the directory created in step [2] to a Kubernetes [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
in the persistent volume resource file `<KUBERNETES_HOME>/pattern-1/volumes/persistent-volumes.yaml`**

For example, append the following entry to the file:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: apim-additional-artifact-pv
  labels:
    purpose: apim-additional-artifacts
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

**[7] Create a Kubernetes Persistent Volume Claim to bind with the Kubernetes Persistent Volume defined in step [6].**

For example, append the following entry to the file `<KUBERNETES_HOME>/pattern-1/apim/wso2apim-volume-claim.yaml`:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: apim-additional-artifact-volume-claim
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: ""
  selector:
    matchLabels:
      purpose: apim-additional-artifacts
```

**[8] Update the appropriate Kubernetes [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) resource(s).**

For example in the discussed scenario, update the volumes (`spec.template.spec.volumes`) and volume mounts (`spec.template.spec.containers[wso2apim-with-analytics-apim-worker].volumeMounts`) in
`<KUBERNETES_HOME>/pattern-1/apim/wso2apim-deployment.yaml` file as follows:

```
volumeMounts:
...
- name: apim-additional-artifact-storage-volume
  mountPath: "/home/wso2carbon/wso2-artifact-volume"

volumes:
...
- name: apim-additional-artifact-storage-volume
  persistentVolumeClaim:
    claimName: apim-additional-artifact-volume-claim
```

**[9] Deploy the Kubernetes resources as defined in section **Quick Start Guide** for pattern 1 of WSO2 API Manager.**
