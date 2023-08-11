## ⚠️ DISCLAIMER

Use these artifacts as a reference to build your deployment artifacts. Existing artifacts are only developed to demonstrate a reference deployment and **should not be used as is in production**.

---

# Kubernetes and Helm Resources for WSO2 API Management

*This repository contains Kubernetes and Helm Resources for container-based deployments of WSO2 API Management.*

## Kubernetes resources for API Management deployment patterns

### Simple

* [Single Node](simple/am-single/README.md)

### Advanced

#### Helm resources for API Management deployment patterns

* [Deployment Pattern 1](advanced/am-pattern-1/README.md)
* [Deployment Pattern 2](advanced/am-pattern-2/README.md)
* [Deployment Pattern 3](advanced/am-pattern-3/README.md)
* [Deployment Pattern 4](advanced/am-pattern-4/README.md)

### Update the JWKS Endpoint

The JWKS endpoint of the API Manager has an external facing hostname by default. This is not routable. To resolve this, you can alter the JWKS endpoint in the API Manager to use the API Manager's internal service name in Kubernetes.

1. Log into Admin portal - https://am.wso2.com/admin/
2. Navigate to Key Managers section and select the Resident Key Manager.
3. Change the JWKS URL in the Certificates section to `https://<cp-lb-service-name>:9443/oauth2/jwks`.


### Update certificate domain names

To verify connecting peers, API Manager uses the wso2carbon certificate. By default, this only allows peers from the localhost domain to connect. To allow connections from different domains you need to create a certificate with the allowed domain name list and add it to the API Manager keystores. This can be done by mounting a volume with the modified keystores. You can find the APIM Manager keystores inside the *~/wso2am-4.1.0/repository/resources/security/* directory.

## Reporting issues

We encourage you to report any issues and documentation faults regarding Kubernetes and Helm resources
for WSO2 API Management. Please report your issues [here](https://github.com/wso2/kubernetes-apim/issues).

## Contact us

WSO2 developers can be contacted via the following mailing lists:

* WSO2 Developers Mailing List : [dev@wso2.org](mailto:dev@wso2.org)
* WSO2 Architecture Mailing List : [architecture@wso2.org](mailto:architecture@wso2.org)
