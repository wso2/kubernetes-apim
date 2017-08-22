FROM ubuntu:16.04

WORKDIR /mnt
COPY wso2is-5.4.0-m2.zip /mnt
COPY jdk-8u131-linux-x64.tar.gz /mnt

ENV JAVA_HOME /mnt/jdk1.8.0_131

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      zip unzip net-tools && \
    unzip /mnt/wso2is-5.4.0-m2.zip && \
    tar zxvf jdk-8u131-linux-x64.tar.gz && \
    rm -rf jdk-8u131-linux-x64.tar.gz wso2is-5.4.0-m2.zip

USER root
EXPOSE 9443 9763
ENTRYPOINT ["/mnt/wso2is-5.4.0-m2/bin/wso2server.sh"]
