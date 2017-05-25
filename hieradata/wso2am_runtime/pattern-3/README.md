# WSO2 API Manager Pattern-3


![pattern-design](../../../../../patterns/design/am-2.1.0-pattern-3.jpg)

This pattern consist of a fully distributed APIM setup (including a Gateway cluster of one manager and one worker), with
 a single wso2am-analytics server instance. The databases used in this pattern are external mysql databases.
The six hiera data .yaml files (in spite of common.yaml) are for the six APIM nodes.

Please follow the basic instructions in this [README](../../../../../README.md) before following this guide.

## Deployment.conf file

Content of /opt/deployment.conf file should be similar to below format to run the agent and setup the respective APIM
 node for this pattern. Put the respective Hieradata .yaml file name, without extension to the
 **product_profile** parameter.

```yaml
 product_name=wso2am_runtime
 product_version=2.1.0
 product_profile=<hiera_file_name_without_extension>
 vm_type=openstack
 environment=dev
 platform=default
 use_hieradata=true
 pattern=pattern-3
```
e.g. To setup Key Manager node:

```yaml
 product_name=wso2am_runtime
 product_version=2.1.0
 product_profile=api-key-manager
 vm_type=openstack
 environment=dev
 platform=default
 use_hieradata=true
 pattern=pattern-3
```

## Node Details

Following table contains the APIM node instances and their respective hiera data .yaml file names and the host names used in each instance.

   APIM Node        | Hieradata file        | Hostname
  ------------------|---------------------- |----------------------
   Publisher        | api-publisher.yaml    | pub.dev.wso2.org
   Store            | api-publisher.yaml    | store.dev.wso2.org
   Gateway Manager  | gateway-manager.yaml  | mgt-gw.dev.wso2.org
   Gateway Worker   | gateway-worker.yaml   | gw.dev.wso2.org
   Key Manager      | api-key-manager.yaml  | km.dev.wso2.org
   Traffic Manager  | traffic-manager.yaml  | tm.dev.wso2.org

Hostname used for the Analytics Server : **analytics.dev.wso2.org**


## Update wka list for clusters in the deployment

There are 2 clusters in this deployment pattern. Required configurations are already added, but WKA IP addresses
should be updated in the respective hiera data files

1.Publisher-Store cluster

This is a cluster of Publisher node and Store node.
Update the wka list in both api-publisher.yaml and store.yaml files with the IP addresses of Publisher and Store nodes.
```yaml
  wka:
    members:
      -
        hostname: 192.168.57.219
        port: 4000
      -
        hostname: 192.168.57.21
        port: 4000
```
2.Gateway Cluster

This is a cluster of Gateway Manager node and Gateway Worker node.
Update the wka list in both gateway-manager.yaml and gateway-worker.yaml files with the IP addresses of Gateway Manager node and Gateway Worker node.
```yaml
  wka:
    members:
      -
        hostname: 192.168.57.216
        port: 4000
      -
        hostname: 192.168.57.247
        port: 4000
```