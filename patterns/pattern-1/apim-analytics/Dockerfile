FROM wso2/wso2am-analytics:2.1.0

#ARG USER=wso2user
#ARG GROUP=wso2

COPY carbon/ /home/wso2user/wso2am-analytics-2.1.0/
COPY artifacts/mysql-connector-java-5.1.34-bin.jar \
	/home/wso2user/wso2am-analytics-2.1.0/repository/components/lib/
#USER root
#RUN chown -R ${USER}:${GROUP} ${USER_HOME} \
#	&& chmod -R 0755 ${USER_HOME} 
#USER ${USER}

#RUN chgrp -R 0 ${USER_HOME} \
#  && chmod -R g+rwX ${USER_HOME}
