FROM wso2/wso2am:2.1.0

ARG USER=wso2user

COPY carbon/ /home/${USER}/tmp/carbon/
COPY artifacts/mysql-connector-java-5.1.34-bin.jar \
        artifacts/dnsjava-2.1.8.jar \
        /home/${USER}/wso2am-2.1.0/repository/components/lib/
COPY artifacts/kubernetes-membership-scheme-1.0.0-SNAPSHOT.jar \
        /home/${USER}/wso2am-2.1.0/repository/components/dropins/

USER root
RUN chown -R ${USER} /home/${USER}/
USER ${USER}
