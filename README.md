# WSO2 API Manager Deployment on OpenShift

This guide outlines the steps to deploy WSO2 API Manager on an OpenShift cluster using the provided Helm chart.

## Prerequisites

- OpenShift cluster with sufficient resources to host WSO2 API Manager and its components.
  per AM node:
  requests:
  memory: "4Gi"
  cpu: "2000m"
  limits:
  memory: "4Gi"
  cpu: "2000m"

- Helm 3.x installed and configured.
- OpenShift CLI (oc) installed and configured.
- Proper permissions to deploy resources to the target namespace.

## Checklist for Deployment

Before deploying WSO2 API Manager on OpenShift, ensure the following:

- [ ] Review and update the Helm chart values to match the OpenShift environment.
- [ ] Check if the target namespace exists in your OpenShift cluster.
- [ ] Validate if the Docker images are accessible from your OpenShift nodes.
- [ ] Confirm that the persistent storage options are correctly configured.
- [ ] Ensure network policies and security groups allow traffic on the required ports.
- [ ] Update the liveness and readiness probes if necessary.
- [ ] Modify the service account and role-based access controls (RBAC) if needed.
- [ ] If using Routes to expose services, ensure the Route manifests are correctly pointing to the services.

## Deployment Steps

1. **Namespace**: Confirm the namespace specified in the Helm chart exists in OpenShift.

   ```sh
   oc get ns <namespace>
   ```

2. **Docker Images**: Make sure that the Docker images for WSO2 API Manager are available in a registry that is accessible by OpenShift.

3. **Persistent Storage**: Review the persistent volume claims and storage classes. OpenShift may require specific storage classes.

4. **Service Account**: Check if the service account specified in the chart has the necessary permissions.

5. **Deploy the Helm Chart**:

   ```sh
   helm install <release-name> <chart-path> -n <namespace>
   ```

6. **Routes**: If you're exposing services outside the cluster, create OpenShift Routes.

   ```sh
   oc apply -f <route.yaml>
   ```

## Post-Deployment Considerations

- **Monitoring**: Set up monitoring tools like Prometheus and Grafana to monitor the WSO2 API Manager.
- **Logging**: Configure centralized logging using solutions like ELK stack or OpenShift's built-in logging mechanisms.
- **Security**: Review security configurations, including network policies, RBAC, and secrets management.
- **Scaling**: Test the scalability of the deployment and configure Horizontal Pod Autoscaling if necessary.

## Troubleshooting

- Check pod status and logs if any service fails to start:

  ```sh
  oc get pods -n <namespace>
  oc logs <pod-name> -n <namespace>
  ```

- Review OpenShift events for errors:

  ```sh
  oc get events -n <namespace>
  ```

- If a service is not accessible, verify the Route and service configurations.

## Additional Resources

- [WSO2 API Manager Documentation](https://wso2.com/api-management/)
- [OpenShift Documentation](https://docs.openshift.com/)
- [Helm Documentation](https://helm.sh/docs/)

For further assistance, contact the WSO2 support team or refer to the community forums.

## Logging

If you want to use a persistent volume for logs, you can mount a persistent volume claim to the logs directory of the API Manager container. To do this, create a persistent volume claim and mount it to the logs directory of the API Manager container.

```yaml
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  name: wso2am
spec:
  template:
    spec:
      containers:
      - name: wso2am-container
        ...
        volumeMounts:
        - name: wso2am-logs
          mountPath: /path/to/logs
      volumes:
      - name: wso2am-logs
        persistentVolumeClaim:
          claimName: wso2am-logs-pvc
```

#### Helm resources for API Management deployment patterns

- [Deployment Pattern 1](advanced/am-pattern-1/README.md)
- [Deployment Pattern 2](advanced/am-pattern-2/README.md)
- [Deployment Pattern 3](advanced/am-pattern-3/README.md)
- [Deployment Pattern 4](advanced/am-pattern-4/README.md)

### Update the JWKS Endpoint

The JWKS endpoint of the API Manager has the external facing hostname by default. This is not routable. To resolve this, you can alter the JWKS endpoint in the API Manager to use the API Manager's internal service name in Kubernetes.

1. Log into Admin portal - https://am.wso2.com/admin/
2. Navigate to Key Managers section and select the Resident Key Manager.
3. Change the JWKS URL in the Certificates section to `https://<cp-lb-service-name>:9443/oauth2/jwks`

### Update certificate domain names

To verify connecting peers API Manager use wso2carbon certificate. By default this only allows peers from localhost domain to connect. To allow connections from different domains you need to create a certificate with the allowed domain name list and add it to API Manager keystores. This can be done by mounting a volume with the modified keystores. You can find the APIM Manager keystores inside the _~/wso2am-4.2.0/repository/resources/security/_ directory.
