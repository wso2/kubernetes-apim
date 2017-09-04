FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

WORKDIR /opt

COPY wso2apim-gateway-3.0.0-m6.zip .
COPY gateway.sh .

RUN unzip wso2apim-gateway-3.0.0-m6.zip && \
    chown -R wso2:wso2 /opt/wso2apim-gateway-3.0.0-m6 && \
    rm -rf wso2apim-gateway-3.0.0-m6.zip && \
    chmod +x /opt/gateway.sh

EXPOSE 9090

ENTRYPOINT ["/opt/gateway.sh"]
