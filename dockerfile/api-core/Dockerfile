FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

WORKDIR /opt
COPY wso2apim-3.0.0-m6.zip /opt
COPY deployment.yaml /opt

RUN unzip wso2apim-3.0.0-m6.zip && \
    chown -R wso2:wso2 /opt/wso2apim-3.0.0-m6 && \
    rm -rf /opt/wso2apim-3.0.0-m6.zip && \
    cp /opt/deployment.yaml /opt/wso2apim-3.0.0-m6/conf

EXPOSE 9292

CMD ["/opt/wso2apim-3.0.0-m6/bin/carbon.sh"]
