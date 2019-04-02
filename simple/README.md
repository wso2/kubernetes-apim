# Simplified setup for WSO2 kubernetes API Manager

## Contents
* Prerequisites

* Quick Start Guide

## Prerequisites
* In order to use WSO2 Kubernetes resources, you need an active WSO2 subscription. If you do not possess an active WSO2 subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/subscription/free-trial).

* Install [Kubernetes  Client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the following quick start guide.
* An already setup Kubernetes cluster. If you are unfamiliar with this context, you can use [this guide](https://kubernetes.io/docs/setup/pick-right-solution/) to set up the cluster.

## Quick Start Guide
1. Download simplified kubernetes setup for WSO2 API Manager (delpoy.sh). 

1. In the command line, move into the directory where you have downloaded the simplified kubernetes-apim setup. (Usually, the file would be in the 
“Downloads” directory unless you have changed the default directory to somewhere else.)
1. Provide permissions for the setup file to execute by running **chmod +x deploy.sh**
1. Run ./deploy.sh on the terminal. You will be asked to provide you wso2 subscription username and password. 
1. Once this is done a kubernetes configuration setup for wso2 API Manager, “deployment.yaml” is created in the same directory. Try running “ls” in the terminal and confirm.
1. Now you can run the command **kubectl create -f deployment.yaml** to deploy simplified WSO2 API Manager in your cluster. 
1. Check if the deployment is up and running with **kubectl get pods -n wso2**. This indicates all pods *STATUS* as **Running** and *READY* as **1/1** if wso2-apim is deployed successfully.
1. Try navigating to https://< NODE-IP >:30596/carbon/ your favourite browser.



