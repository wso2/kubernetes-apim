FROM ubuntu:16.04
MAINTAINER dev@wso2.org

WORKDIR /opt
COPY wso2is-5.4.0-m2.zip /opt
COPY jdk-8u131-linux-x64.tar.gz /opt

ENV JAVA_HOME /opt/jdk1.8.0_131

# TODO: set proxy ports as needed

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      zip unzip net-tools && \
    unzip /opt/wso2is-5.4.0-m2.zip && \
    tar zxvf jdk-8u131-linux-x64.tar.gz && \
    rm -rf jdk-8u131-linux-x64.tar.gz wso2is-5.4.0-m2.zip

USER root
EXPOSE 9443 9763
ENTRYPOINT ["/opt/wso2is-5.4.0-m2/bin/wso2server.sh"]
