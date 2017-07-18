FROM docker.wso2.com/base-c5
COPY wso2apim-3.0.0-m4.zip .
RUN unzip wso2apim-3.0.0-m4.zip -d /opt
COPY deployment.yaml /opt/wso2apim-3.0.0-m4/conf/
EXPOSE 9292
RUN chgrp -R 0 /opt && chmod -R g+rwX /opt
CMD ["/opt/wso2apim-3.0.0-m4/bin/carbon.sh"]
