# Simplified setup for WSO2 kubernetes API Manager

![WSO2 API Manager Deployment](../extra/apim_simple.png)

## Contents
* Prerequisites

* Quick Start Guide

## Prerequisites
* Install [Kubernetes  Client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the following quick start guide.
* An already setup Kubernetes cluster. If you are unfamiliar with this context, you can use [this guide](https://kubernetes.io/docs/setup/pick-right-solution/) to set up the cluster.
* WSO2 subscribed users can run **wso2am-latest.sh** with latest updates by providing their subscription username and password. If you do not possess an active WSO2 subscription already, run **wso2am-ga.sh** which does not require subscription credentials.

## Quick Start Guide
1. Download simplified kubernetes setup for WSO2 API Manager (either **wso2am-latest.sh** or **wso2am-ga.sh**).From this point forward the steps are being described for wso2am-latest.sh. If you have downloaded wso2am-ga.sh please substitute wso2am-latest.sh with wso2am-ga.sh for every command.  

2. In the command line, move into the directory where you have downloaded the simplified kubernetes-apim setup. (Usually, the file would be in the “Downloads” directory unless you have changed the default directory to somewhere else.)
3. Provide permissions for the setup file to execute by running **chmod +x wso2am-latest.sh**
4. Run **./wso2am-latest.sh --deploy** on your terminal. This will deploy WSO2 API Manager in your cluster.

5. Try navigating to https://< NODE-IP >:30443/carbon/ your favourite browser using username: admin and password: admin. Your < NODE-IP > will be provided at the end of the deployment.
6. Try out WSO2 API Manager by following **[WSO2 API Manager - Quick Start Guide](https://docs.wso2.com/display/AM260/Quick+Start+Guide)**.
