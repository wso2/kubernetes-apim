FROM wso2/wso2am-analytics:2.1.0

ARG USER=wso2user
ARG USER_HOME=/home/${USER}
ARG ANALYTICS_STARTUP_SCRIPT=init_analytics.sh

COPY carbon/ ${USER_HOME}/tmp/carbon/
COPY artifacts/mysql-connector-java-5.1.34-bin.jar \
        artifacts/dnsjava-2.1.8.jar \
        ${USER_HOME}/wso2am-analytics-2.1.0/repository/components/lib/
COPY artifacts/kubernetes-membership-scheme-1.0.0-SNAPSHOT.jar \
        ${USER_HOME}/wso2am-analytics-2.1.0/repository/components/dropins/

USER root
RUN chown -R ${USER} ${USER_HOME}/
USER ${USER}

EXPOSE 11225 10006 11001 11501 8082 4041
