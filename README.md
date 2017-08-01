# Kubernetes Artifacts for WSO2 API Manager 2.1.0

## Building Docker Images
1. Clone the puppet common repo:
https://github.com/wso2/puppet-common

2. Go to <puppet_common> and run following setup.sh command.
`./setup.sh -p apim -t v2.1.0`

3. Provide an empty folder for **PUPPET_HOME** when prompted.

4. Export the PUPPET_HOME folder provided.
 `export PUPPET_HOME=/home/puppet/`
 
5. Remove content of <PUPPET_HOME>/hieradata/dev/wso2 folder.
`rm -rf <PUPPET_HOME>/hieradata/dev/wso2/`

6. Create symlink for the hieradata folder in this repository.
 `ln -s <KUBERNETES_APIM_HOME>/hieradata/  <PUPPET_HOME>/hieradata/dev/wso2/`
 
7. Copy jdk distribution and wso2 server pack distributions, mysql-connect jar file, kubernetes membership scheme to puppet modules.

8. Clone docker-apim repo:

    `https://github.com/wso2/docker-apim`

    `git clone https://github.com/wso2/docker-apim.git`

    `git checkout 2.1.x`

    `git submodule init`

    `git submodule update`

9. To build API-M Image run the following command in from <DOCKER_APIM_HOME>/dockerfiles/wso2am-runtime
  `bash build.sh -v 2.1.0 -r puppet -s kubernetes -p 3 -m wso2am_runtime -l gateway-manager`
 
10. Run deploy.sh in <KUBERNETES_APIM_HOME>/artifacts/<pattern>/deploy.sh.
=======
# WSO2 API Manager Docker Artifacts

This repository contains following Docker artifacts:
- WSO2 API Manager Dockerfile
- WSO2 API Manager Docker Compose File

## Getting Started

Execute following command to clone the repository:

```bash
git clone https://github.com/wso2/docker-apim.git
```

Checkout required product version branch:

```bash
git branch
git checkout <product-version>
```

The bash files in dockerfile folder make use of scripts in [wso2/docker-common](https://github.com/wso2/docker-common) repository
and it has been imported into dockerfile/common folder as a sub-module. Once the clone process is completed execute following 
commands to pull the sub-module content:

```bash
git submodule init
git submodule update
```
