FROM wso2/wso2am:2.1.0

ARG USER=wso2user

COPY carbon/ /home/${USER}/tmp/carbon/

USER root
RUN chown -R ${USER} /home/${USER}/
USER ${USER}
