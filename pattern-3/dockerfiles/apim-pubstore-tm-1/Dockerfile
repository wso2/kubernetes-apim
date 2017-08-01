FROM wso2/wso2am:2.1.0

ARG USER=wso2user

COPY carbon/ /home/${USER}/tmp/carbon/
COPY artifacts/mysql-connector-java-5.1.34-bin.jar \
        /home/${USER}/wso2am-2.1.0/repository/components/lib/

USER root
RUN chown -R wso2user /home/${USER}/
USER ${USER}
