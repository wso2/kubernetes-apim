#WSO2 API Manager Pattern-7

![pattern-design](../../../../../patterns/design/am-2.1.0-pattern-7.jpg)

This pattern consist of a stand-alone APIM setup with a single node deployment. The databases used in this pattern are external mysql databases. The only difference of this pattern from
pattern-1 is that this uses WSO2 Identity Sever as Key Manager. Use this pattern to configure APIM and use
**wso2is_prepacked** puppet module in this repository to configure IS.

Use the pattern-1 in **wso2is_prepacked** puppet module in this repository to configure a pre-packaged Identity Server 5
.3.0 instance which would act as Key Manager.

Please follow the basic instructions in this [README](../../../../../README.md) before following this guide.

Content of /opt/deployment.conf file should be similar to below to run the agent and setup APIM node for this pattern
 in Puppet Agent.

```yaml
 product_name=wso2am_runtime
 product_version=2.1.0
 product_profile=default
 vm_type=openstack
 environment=dev
 platform=default
 use_hieradata=true
 pattern=pattern-7
```