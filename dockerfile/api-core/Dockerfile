FROM docker.wso2.com/base-c5
MAINTAINER dev@wso2.org

WORKDIR /mnt
COPY wso2apim-3.0.0-m6.zip /mnt
COPY deployment.yaml /mnt

RUN unzip wso2apim-3.0.0-m6.zip && \
    chown -R wso2:wso2 /mnt/wso2apim-3.0.0-m6 && \
    rm -rf /mnt/wso2apim-3.0.0-m6.zip && \
    cp /mnt/deployment.yaml /mnt/wso2apim-3.0.0-m6/conf

EXPOSE 9292

CMD ["/mnt/wso2apim-3.0.0-m6/bin/carbon.sh"]
