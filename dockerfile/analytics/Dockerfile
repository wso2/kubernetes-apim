FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

WORKDIR /mnt
COPY wso2apim-das-3.0.0-m6.zip /mnt

RUN unzip wso2apim-das-3.0.0-m6.zip && \
    chown -R wso2:wso2 /mnt/wso2apim-das-3.0.0-m6 && \
    rm -rf /mnt/wso2apim-das-3.0.0-m6.zip 

EXPOSE 9091

ENTRYPOINT ["/mnt/wso2apim-das-3.0.0-m6/bin/worker.sh"]
