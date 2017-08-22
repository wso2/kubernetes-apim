FROM docker.wso2.com/base-c5
WORKDIR /opt
COPY wso2apim-gateway-3.0.0-m5.zip .
RUN unzip wso2apim-gateway-3.0.0-m5.zip
EXPOSE 9090
WORKDIR /opt/wso2apim-gateway-3.0.0-m5
COPY gateway.sh .
RUN chgrp -R 0 /opt && chmod -R g+rwX /opt
CMD ["./gateway.sh"]
