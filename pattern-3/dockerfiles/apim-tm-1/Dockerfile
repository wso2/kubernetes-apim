FROM wso2/wso2am:2.1.0

ARG USER=wso2user
ARG STARTUP_SCRIPT=init_carbon.sh

COPY ${STARTUP_SCRIPT} /home/${USER}/scripts/
COPY carbon/ /home/${USER}/tmp/carbon/

USER root
RUN chown -R ${USER} /home/${USER}/
USER ${USER}
