FROM openjdk:8u111-jdk-alpine
MAINTAINER dev@wso2.org

RUN apk update && \
    apk add curl bash bash-doc bash-completion zip unzip && \
    addgroup -S wso2 && \
    adduser -S -g wso2 wso2
