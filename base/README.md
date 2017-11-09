# Building the docker images

##### 1. Download the relevant files

For analytics

- wso2am-analytics-2.1.0.zip 
- jdk-8u*-linux-x64.tar.gz (Any JDK 8u* version)
- dnsjava-2.1.8.jar (http://www.dnsjava.org/)
- [`kubernetes-membership-scheme-1.0.1.jar`](https://github.com/wso2/kubernetes-common/releases/tag/v1.0.1)
- mysql-connector-java-5*-bin.jar (Any mysql connector 5* version)


Add the above files to analytics/files location.

For apim

- wso2am-2.1.0.zip
- jdk-8u*-linux-x64.tar.gz (Any JDK 8u* version)
- dnsjava-2.1.8.jar (http://www.dnsjava.org/)
- [`kubernetes-membership-scheme-1.0.1.jar`](https://github.com/wso2/kubernetes-common/releases/tag/v1.0.1)
- mysql-connector-java-5*-bin.jar (Any mysql connector 5* version)

Add the above files to apim/files location.

> mysql docker image does not need any files.

##### 2. Build docker images

Run build.sh
```
./build.sh
```