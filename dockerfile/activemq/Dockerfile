FROM docker.wso2.com/base-c5
WORKDIR /opt
ADD apache-activemq-5.14.0-bin.tar.gz  .
COPY activemq.sh . 
EXPOSE 61616
RUN chgrp -R 0 /opt && chmod -R g+rwX /opt
CMD ["/opt/activemq.sh"]
