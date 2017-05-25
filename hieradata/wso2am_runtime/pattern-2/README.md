#WSO2 API Manager Pattern-2

![pattern-design](../../../../../patterns/design/am-2.1.0-pattern-2.jpg)

This pattern consist of a stand-alone APIM setup with a single node deployment, with a single wso2am-analytics server
instance. The databases used in this pattern are external mysql databases.

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
 pattern=pattern-2
```