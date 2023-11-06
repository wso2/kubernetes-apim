# WSO2 API Manager Deployment on OpenShift

This guide outlines the steps to deploy WSO2 API Manager on an OpenShift cluster using the provided Helm chart.

## Prerequisites

- OpenShift cluster with sufficient resources to host WSO2 API Manager and its components.
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
