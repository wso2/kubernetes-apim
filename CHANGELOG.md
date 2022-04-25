# Changelog

All notable changes to Kubernetes and Helm resources for WSO2 API Management version `3.2.x` in each resource release,
will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [v3.2.0.5] - 2021-05-03

### Changed

- Update Ingress API version to networking.k8s.io/v1 from extensions/v1beta1 which was depricated since Kubernetes v1.22

## [v3.2.0.4] - 2021-05-03

### Changed

- Use MySQL, nfs-server-provisioner from WSO2 repo (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/488))

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v3.2.0.4](https://github.com/wso2/kubernetes-apim/milestone/20).

## [v3.2.0.3] - 2020-12-17

### Changed

- Use Updates 2.0 images when subscription is enabled (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/478))
- Change MySQL dependency to bitnami repo (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/479))
- Use nfs-server-provisioner from kvaps (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/481))

## [v3.2.0.2] - 2020-09-16

### Changed

- [[Simplified Setup](https://github.com/wso2/kubernetes-apim/tree/master/simple)] Reduce resource requests of the simplified kubernetes resources.  (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/459))

### Fixed

- [[Simplified Setup](https://github.com/wso2/kubernetes-apim/tree/master/simple)] Update auth.config URLs in analytics dashboard to support access to analytics dashboard with Docker Desktop. (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/460))

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v3.2.0.2](https://github.com/wso2/kubernetes-apim/milestone/17)

## [v3.2.0.1] - 2020-08-28

### Environments

- Successful evaluation of API Manager Helm charts in AWS Elastic Kubernetes Service (EKS) (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/432))
- Successful evaluation of Ceph File System (CephFS) as a Persistent Storage Solution (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/410))

### Added

- Introduce Kubernetes resources for a simplified setup of WSO2 API Management version `3.2.0` (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/428))
- Introduce Helm charts for WSO2 API Management version `3.2.0` production grade deployment patterns (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/399))
- Add options to define volume capacities for persistent storage (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/406))
- Add JVM memory allocation user input option (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/375))
- Add mechanism to introduce MySQL JDBC driver to the product containers since [it is not packaged in product container images](https://github.com/wso2/docker-apim/issues/321)
  (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/427))
- Add user input option to set Ingress class and annotations (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/446))
- Test and document managing custom keystores and truststores (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/401))

### Changed

- Upgrade the base MySQL Helm chart version (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/445))
- Upgrade MySQL Docker image tag version (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/430))

### Fixed

- Use Kubernetes StatefulSet resources to define API Manager Key Manager deployments (refer to [issue](https://github.com/wso2/kubernetes-apim/issues/436))

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v3.2.0.1](https://github.com/wso2/kubernetes-apim/milestone/15)

[v3.2.0.3]: https://github.com/wso2/kubernetes-apim/compare/v3.2.0.3...v3.2.0.3
[v3.2.0.2]: https://github.com/wso2/kubernetes-apim/compare/v3.2.0.1...v3.2.0.2
[v3.2.0.1]: https://github.com/wso2/kubernetes-apim/compare/v3.1.0.3...v3.2.0.1
