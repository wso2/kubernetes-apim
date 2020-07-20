# Changelog
All notable changes to this project `3.1.0` per each release will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [v3.1.0.3] - 2020-07-20

### Added

- StatefulSet support for WSO2 API Manager Traffic Manager Profile deployment
- StatefulSet support for WSO2 API Management Analytics Worker deployment
- Integrate new Throttling configurations for Active-Active deployment of API Manager
- Integrate support for automatic rolling update upon ConfigMap changes
- Option to enable/disable data persistence support for Apache based Solr-Indexing
- Option to specify host names as user input
- Option to define persistent/shared volume capacities as user input
- Add Helm NOTES.txt For API Management Helm charts
- Set MySQL data source and product Helm Charts to use the same Storage Class

### Changed

- Include the WSO2 configuration file content within the Kubernetes ConfigMap

### Fixed

- Include missing configurations in WSO2 API Management Analytics Worker deployment

For detailed information on the tasks carried out during this release, please see the GitHub milestone [v3.1.0.3](https://github.com/wso2/kubernetes-apim/milestone/14)

## [v3.1.0.2] - 2020-04-24

- Introduce Helm chart for WSO2 APIM version 3.1.0 deployment pattern 3
- Add support for Custom Kubernetes Storage Class
- Upgrade NFS Server Provisioner and MySQL Helm Chart Versions

For detailed information on the tasks carried out during this release, please see the GitHub milestone [v3.1.0.2](https://github.com/wso2/kubernetes-apim/milestone/13)

## [v3.1.0.1] - 2020-04-13

- Introduce Helm chart for WSO2 APIM version 3.1.0 deployment pattern 1
- Introduce Helm chart for WSO2 APIM version 3.1.0 deployment pattern 2
- Introduce Simplified setup for WSO2 APIM version 3.1.0

For detailed information on the tasks carried out during this release, please see the GitHub milestone [v3.1.0.1](https://github.com/wso2/kubernetes-apim/milestone/12)

[v3.1.0.3]: https://github.com/wso2/kubernetes-apim/compare/v3.1.0.2...v3.1.0.3
[v3.1.0.2]: https://github.com/wso2/kubernetes-apim/compare/v3.1.0.1...v3.1.0.2
[v3.1.0.1]: https://github.com/wso2/kubernetes-apim/compare/v3.0.0.3...v3.1.0.1
