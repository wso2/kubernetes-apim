FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

WORKDIR /mnt

COPY wso2apim-gateway-3.0.0-m6.zip .
COPY gateway.sh .

RUN unzip wso2apim-gateway-3.0.0-m6.zip && \
    chown -R wso2:wso2 /mnt/wso2apim-gateway-3.0.0-m6 && \
    rm -rf wso2apim-gateway-3.0.0-m6.zip && \
    chmod +x /mnt/gateway.sh

EXPOSE 9090

ENTRYPOINT ["/mnt/gateway.sh"]
