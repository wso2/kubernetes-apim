FROM openjdk:8u111-jdk-alpine
MAINTAINER dev@wso2.org

WORKDIR /mnt

ADD apache-activemq-5.14.0-bin.tar.gz  .
COPY activemq.sh .

EXPOSE 61616

RUN apk update && \
    addgroup -S wso2 && \
    adduser -S -g wso2 wso2 && \
    chown -R wso2:wso2 /mnt/activemq.sh && \
    chown -R wso2:wso2 /mnt/apache-activemq-5.14.0 && \
    chmod u+x /mnt/activemq.sh

USER wso2

CMD ["/mnt/activemq.sh"]
