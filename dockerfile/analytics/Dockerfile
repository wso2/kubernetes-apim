FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

WORKDIR /opt
COPY wso2apim-das-3.0.0-m6.zip /opt

RUN unzip wso2apim-das-3.0.0-m6.zip && \
    chown -R wso2:wso2 /opt/wso2apim-das-3.0.0-m6 && \
    rm -rf /opt/wso2apim-das-3.0.0-m6.zip 

EXPOSE 9091

ENTRYPOINT ["/opt/wso2apim-das-3.0.0-m6/bin/worker.sh"]
