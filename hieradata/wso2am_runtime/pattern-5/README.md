# WSO2 API Manager Pattern-5

![pattern-design](../../../../../patterns/design/am-2.1.0-pattern-5.jpg)

This pattern consist of a distributed APIM setup including a Gateway cluster of one manager and one worker and the
Gateway worker is merged with the Key Manager.  This also consists of a single wso2am-analytics server instance too.
The 5 hiera data .yaml files (in spite of common.yaml) here are for these 5 APIM nodes.
 The databases used in this pattern are external mysql databases.

Please follow the basic instructions in this [README](../../../../../README.md) before following this guide.

## Deployment.conf file

Content of /opt/deployment.conf file should be similar to below format to run the agent and setup the respective APIM
 node for this pattern. Please note to put the respective Hieradata .yaml file name, without extension to the
 **product_profile** parameter in this.

```yaml
 product_name=wso2am_runtime
 product_version=2.1.0
 product_profile=<hiera_file_name_without_extension>
 vm_type=openstack
 environment=dev
 platform=default
 use_hieradata=true
 pattern=pattern-5
```
e.g. To setup Gateway Manager node:

```yaml
 product_name=wso2am_runtime
 product_version=2.1.0
 product_profile=gateway-manager
 vm_type=openstack
 environment=dev
 platform=default
 use_hieradata=true
 pattern=pattern-5
```

## Node Details

Following table contains the APIM node instances with their respective hiera data .yaml file names and the host names
used in each instance.

   APIM Node                   | Hieradata file            | Hostname
   -------------               |-----------------------    | ------------------
   Publisher                   | api-publisher.yaml        | pub.dev.wso2.org
   Store                       | api-publisher.yaml        | store.dev.wso2.org
   Gateway Manager             | gateway-manager.yaml      | mgt-gw.dev.wso2.org
   Gateway Worker + Key Manager| gw-plus-km.yaml           | am.dev.wso2.org
   Traffic Manager             | traffic-manager.yaml      | tm.dev.wso2.org

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

This is a cluster of Gateway Manager node and Gateway Worker+Key Manager node.
Update the wka list in both gateway-manager.yaml and gw-plus-km.yaml files with the IP addresses of Gateway Manager node and Gateway Worker+Key Manager node.
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