FROM openjdk:8u111-jdk-alpine
MAINTAINER dev@wso2.org

WORKDIR /opt

ADD apache-activemq-5.14.0-bin.tar.gz  .
COPY activemq.sh .

EXPOSE 61616

RUN apk update && \
    addgroup -S wso2 && \
    adduser -S -g wso2 wso2 && \
    chown -R wso2:wso2 /opt/activemq.sh && \
    chown -R wso2:wso2 /opt/apache-activemq-5.14.0 && \
    chmod u+x /opt/activemq.sh

USER wso2

CMD ["/opt/activemq.sh"]
