#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------------

set -e

# bash variables
k8s_obj_file="deployment.yaml"; NODE_IP=''; str_sec=""

# wso2 subscription variables
WUMUsername=''; WUMPassword=''

: ${namespace:="wso2"}
: ${randomPort:=False}; : ${NP_1:=30243}; : ${NP_2:=30443}

# testgrid directory
OUTPUT_DIR=$4; INPUT_DIR=$2

# bash functions
function usage(){
  echo "Usage: "
  echo -e "-d, --deploy     Deploy WSO2 API Manager"
  echo -e "-u, --undeploy   Undeploy WSO2 API Manager"
  echo -e "-h, --help       Display usage instrusctions"
}
function undeploy(){
  echoBold "Undeploying WSO2 API Manager ... \n"
  kubectl delete -f deployment.yaml
  exit 0
}
function echoBold () {
    echo -en  $'\e[1m'"${1}"$'\e[0m'
}

function display_msg(){
    msg=$@
    echoBold "${msg}"
    exit 1
}

function st(){
  cycles=${1}
  i=0
  while [[ i -lt $cycles ]]
  do
    echoBold "* "
    let "i=i+1"
  done
}
function sp(){
  cycles=${1}
  i=0
  while [[ i -lt $cycles ]]
  do
    echoBold " "
    let "i=i+1"
  done
}
function product_name(){
  #wso2apim
  echo -e "\n"
  st 1; sp 8; st 1; sp 2; sp 1; st 3; sp 3; sp 2; st 3; sp 4; sp 1; st 3; sp 3; sp 8; sp 2; st 3; sp 1; sp 3; st 3; sp 3; st 5; sp 2; st 1; sp 8; st 1;
  echo ""
  st 1; sp 8; st 1; sp 2; st 1; sp 4; st 1; sp 2; st 1; sp 6; st 1; sp 2; st 1; sp 4; st 1; sp 2; sp 8; sp 1; st 1; sp 4; st 1; sp 3; st 1; sp 4; st 1; sp 2; sp 3; st 1; sp 6; st 2; sp 4; st 2;
  echo ""
  st 1; sp 3; st 1; sp 3; st 1; sp 2; st 1; sp 8; st 1; sp 6; st 1; sp 2; sp 6; st 1; sp 2; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp 4; st 1; sp 2; sp 3; st 1; sp 6; st 1; sp 1; st 1; sp 2; st 1; sp 1; st 1;
  echo ""
  st 1; sp 2; st 1; st 1; sp 2; st 1; sp 2; sp 1; st 3; sp 3; st 1; sp 6; st 1; sp 2; sp 4; st 1; sp 4; st 3; sp 2; st 5; sp 2; st 3; sp 3; sp 4; st 1; sp 6; st 1; sp 2; st 2; sp 2; st 1;
  echo ""
  st 1; sp 1; st 1; sp 2; st 1; sp 1; st 1; sp 2; sp 6; st 1; sp 2; st 1; sp 6; st 1; sp 2; sp 2; st 1; sp 6; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp  7; sp 4; st 1; sp 6; st 1; sp 3; st 1; sp 3; st 1;
  echo ""
  st 2; sp 4; st 2; sp 2; st 1; sp 4; st 1; sp 2; st 1; sp 6; st 1; sp 2; st 1; sp 8; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp 7; sp 4; st 1; sp 6; st 1; sp 8; st 1;
  echo ""
  st 1; sp 8; st 1; sp 2; sp 1; st 3; sp 3; sp 2; st 3; sp 4; st 4; sp 2; sp 8; st 1; sp 6; st 1; sp 2; st 1; sp 7; st 5; sp 2; st 1; sp 8; st 1;
  echo -e "\n"
}
function create_yaml(){

cat > $k8s_obj_file << "EOF"
EOF
if [ "$namespace" == "wso2" ]; then
cat >> $k8s_obj_file << "EOF"
apiVersion: v1
kind: Namespace
metadata:
  name: wso2
spec:
  finalizers:
    - kubernetes
---
EOF
fi
cat >> $k8s_obj_file << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: wso2svc-account
  namespace: $namespace
secrets:
  - name: wso2svc-account-token-t7s49
---

apiVersion: v1
data:
  .dockerconfigjson: $str_sec
kind: Secret
metadata:
  name: wso2creds
  namespace: $namespace
type: kubernetes.io/dockerconfigjson
---
EOF
cat >> $k8s_obj_file << "EOF"
apiVersion: v1
data:
  axis2.xml: |
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <axisconfig name="AxisJava2.0">
        <parameter name="hotdeployment" locked="false">true</parameter>
        <parameter name="hotupdate" locked="false">true</parameter>
        <parameter name="enableMTOM" locked="false">false</parameter>
        <parameter name="enableSwA" locked="false">false</parameter>
        <parameter name="cacheAttachments" locked="false">false</parameter>
        <parameter name="attachmentDIR" locked="false">work/mtom</parameter>
        <parameter name="sizeThreshold" locked="false">4000</parameter>
        <parameter name="disableREST" locked="false">false</parameter>
        <parameter name="Sandesha2StorageManager" locked="false">inmemory</parameter>
        <parameter name="servicePath" locked="false">services</parameter>
        <parameter name="ServicesDirectory">axis2services</parameter>
        <parameter name="ModulesDirectory">axis2modules</parameter>
        <parameter name="userAgent" locked="true">WSO2 AM 2.1.0</parameter>
        <parameter name="server" locked="true">WSO2 AM 2.1.0</parameter>
        <parameter name="sendStacktraceDetailsWithFaults" locked="false">false</parameter>
        <parameter name="DrillDownToRootCauseForFaultReason" locked="false">false</parameter>
        <parameter name="manageTransportSession" locked="false">true</parameter>
        <parameter name="ConfigContextTimeoutInterval" locked="false">30000</parameter>
        <parameter name="SynapseConfig.ConfigurationFile" locked="false">repository/deployment/server/synapse-configs</parameter>
        <parameter name="SynapseConfig.HomeDirectory" locked="false">.</parameter>
        <parameter name="SynapseConfig.ResolveRoot" locked="false">.</parameter>
        <parameter name="SynapseConfig.ServerName" locked="false">localhost</parameter>
        <listener class="org.wso2.carbon.core.deployment.DeploymentInterceptor"/>
        <messageReceivers>
            <messageReceiver mep="http://www.w3.org/ns/wsdl/in-only"
                             class="org.apache.axis2.rpc.receivers.RPCInOnlyMessageReceiver"/>
            <messageReceiver mep="http://www.w3.org/ns/wsdl/robust-in-only"
                             class="org.apache.axis2.rpc.receivers.RPCInOnlyMessageReceiver"/>
            <messageReceiver mep="http://www.w3.org/ns/wsdl/in-out"
                             class="org.apache.axis2.rpc.receivers.RPCMessageReceiver"/>
        </messageReceivers>
        <messageFormatters>
           <messageFormatter contentType="application/x-www-form-urlencoded"
                              class="org.apache.axis2.transport.http.XFormURLEncodedFormatter"/>
            <messageFormatter contentType="multipart/form-data"
                              class="org.apache.axis2.transport.http.MultipartFormDataFormatter"/>
            <messageFormatter contentType="text/html"
                              class="org.apache.axis2.transport.http.ApplicationXMLFormatter"/>
            <messageFormatter contentType="application/xml"
                              class="org.apache.axis2.transport.http.ApplicationXMLFormatter"/>
            <messageFormatter contentType="text/xml"
                             class="org.apache.axis2.transport.http.SOAPMessageFormatter"/>
            <messageFormatter contentType="application/soap+xml"
                             class="org.apache.axis2.transport.http.SOAPMessageFormatter"/>
            <messageFormatter contentType="text/plain"
                             class="org.apache.axis2.format.PlainTextFormatter"/>
            <messageFormatter contentType="application/json"
                              class="org.apache.synapse.commons.json.JsonStreamFormatter"/>
            <messageFormatter contentType="application/json/badgerfish"
                              class="org.apache.axis2.json.JSONBadgerfishMessageFormatter"/>
            <messageFormatter contentType="text/javascript"
                              class="org.apache.axis2.json.JSONMessageFormatter"/>
            <messageFormatter contentType="application/octet-stream"
                              class="org.wso2.carbon.relay.ExpandingMessageFormatter"/>
        </messageFormatters>
        <messageBuilders>
        <messageBuilder contentType="application/xml"
                            class="org.apache.axis2.builder.ApplicationXMLBuilder"/>
            <messageBuilder contentType="text/html"
                            class="org.wso2.carbon.relay.BinaryRelayBuilder"/>
            <messageBuilder contentType="application/x-www-form-urlencoded"
                            class="org.apache.synapse.commons.builders.XFormURLEncodedBuilder"/>
            <messageBuilder contentType="multipart/form-data"
                            class="org.apache.axis2.builder.MultipartFormDataBuilder"/>
            <messageBuilder contentType="text/plain"
                            class="org.apache.axis2.format.PlainTextBuilder"/>
            <messageBuilder contentType="application/json"
                            class="org.apache.synapse.commons.json.JsonStreamBuilder"/>
            <messageBuilder contentType="application/json/badgerfish"
                            class="org.apache.axis2.json.JSONBadgerfishOMBuilder"/>
            <messageBuilder contentType="text/javascript"
                            class="org.apache.axis2.json.JSONBuilder"/>
            <messageBuilder contentType="application/octet-stream"
                            class="org.wso2.carbon.relay.BinaryRelayBuilder"/>
        </messageBuilders>
        <transportReceiver name="http" class="org.apache.synapse.transport.passthru.PassThroughHttpListener">
            <parameter name="port" locked="false">8280</parameter>
            <parameter name="non-blocking" locked="false">true</parameter>
            <parameter name="httpGetProcessor" locked="false">org.wso2.carbon.mediation.transport.handlers.PassThroughNHttpGetProcessor</parameter>
        </transportReceiver>
       <transportReceiver name="https" class="org.apache.synapse.transport.passthru.PassThroughHttpSSLListener">
            <parameter name="port" locked="false">8243</parameter>
            <parameter name="non-blocking" locked="false">true</parameter>
           <parameter name="httpGetProcessor" locked="false">org.wso2.carbon.mediation.transport.handlers.PassThroughNHttpGetProcessor</parameter>
            <parameter name="keystore" locked="false">
                <KeyStore>
                    <Location>repository/resources/security/wso2carbon.jks</Location>
                    <Type>JKS</Type>
                    <Password>wso2carbon</Password>
                    <KeyPassword>wso2carbon</KeyPassword>
                </KeyStore>
            </parameter>
            <parameter name="truststore" locked="false">
                <TrustStore>
                    <Location>repository/resources/security/client-truststore.jks</Location>
                    <Type>JKS</Type>
                    <Password>wso2carbon</Password>
                </TrustStore>
            </parameter>
        </transportReceiver>
        <transportReceiver name="local" class="org.wso2.carbon.core.transports.local.CarbonLocalTransportReceiver"/>
        <transportSender name="http" class="org.apache.synapse.transport.passthru.PassThroughHttpSender">
            <parameter name="non-blocking" locked="false">true</parameter>
        </transportSender>
        <transportSender name="local" class="org.wso2.carbon.core.transports.local.CarbonLocalTransportSender"/>
        <transportSender name="https" class="org.apache.synapse.transport.passthru.PassThroughHttpSSLSender">
            <parameter name="non-blocking" locked="false">true</parameter>
            <parameter name="keystore" locked="false">
                <KeyStore>
                    <Location>repository/resources/security/wso2carbon.jks</Location>
                    <Type>JKS</Type>
                    <Password>wso2carbon</Password>
                    <KeyPassword>wso2carbon</KeyPassword>
                </KeyStore>
            </parameter>
            <parameter name="truststore" locked="false">
                <TrustStore>
                    <Location>repository/resources/security/client-truststore.jks</Location>
                    <Type>JKS</Type>
                    <Password>wso2carbon</Password>
                </TrustStore>
            </parameter>
            <parameter name="dynamicSSLProfilesConfig">
                <filePath>repository/resources/security/sslprofiles.xml</filePath>
                <fileReadInterval>600000</fileReadInterval>
            </parameter>
            <parameter name="HostnameVerifier">AllowAll</parameter>
        </transportSender>
        <transportSender name="ws" class="org.wso2.carbon.websocket.transport.WebsocketTransportSender">
            <parameter name="ws.outflow.dispatch.sequence" locked="false">outflowDispatchSeq</parameter>
            <parameter name="ws.outflow.dispatch.fault.sequence" locked="false">outflowFaultSeq</parameter>
        </transportSender>

        <transportSender name="wss" class="org.wso2.carbon.websocket.transport.WebsocketTransportSender">
            <parameter name="ws.outflow.dispatch.sequence" locked="false">outflowDispatchSeq</parameter>
            <parameter name="ws.outflow.dispatch.fault.sequence" locked="false">outflowFaultSeq</parameter>
            <parameter name="ws.trust.store" locked="false">
                <ws.trust.store.location>repository/resources/security/client-truststore.jks</ws.trust.store.location>
                <ws.trust.store.Password>wso2carbon</ws.trust.store.Password>
            </parameter>
        </transportSender>
        <module ref="addressing"/>
        <clustering class="org.wso2.carbon.core.clustering.hazelcast.HazelcastClusteringAgent"
                    enable="false">
            <parameter name="AvoidInitiation">true</parameter>
            <parameter name="membershipScheme">multicast</parameter>
            <parameter name="domain">wso2.carbon.domain</parameter>
            <parameter name="mcastPort">45564</parameter>

            <parameter name="mcastTTL">100</parameter>

            <parameter name="mcastTimeout">60</parameter>
            <parameter name="localMemberHost">10.12.5.129</parameter>
            <parameter name="localMemberPort">4000</parameter>
            <parameter name="properties">
                <property name="backendServerURL" value="https://${hostName}:${httpsPort}/services/"/>
                <property name="mgtConsoleURL" value="https://${hostName}:${httpsPort}/"/>
                <property name="subDomain" value="worker"/>
            </parameter>
            <members>
                <member>
                    <hostName>127.0.0.1</hostName>
                    <port>4000</port>
                </member>
            </members>
            <groupManagement enable="false">
                <applicationDomain name="wso2.apim.domain"
                                   description="APIM group"
                                   agent="org.wso2.carbon.core.clustering.hazelcast.HazelcastGroupManagementAgent"
                                   subDomain="worker"
                                   port="2222"/>
            </groupManagement>
        </clustering>
        <phaseOrder type="InFlow">
        <phase name="MsgInObservation">
            <handler name="TraceMessageBuilderDispatchHandler"
                         class="org.apache.synapse.transport.passthru.util.TraceMessageBuilderDispatchHandler"/>
        </phase>
        <phase name="Validation"/>
            <phase name="Transport">
                <handler name="RequestURIBasedDispatcher"
                         class="org.apache.axis2.dispatchers.RequestURIBasedDispatcher">
                    <order phase="Transport"/>
                </handler>
            <handler name="CarbonContextConfigurator"
            class="org.wso2.carbon.mediation.initializer.handler.CarbonContextConfigurator"/>
                <handler name="SOAPActionBasedDispatcher"
                         class="org.apache.axis2.dispatchers.SOAPActionBasedDispatcher">
                    <order phase="Transport"/>
                </handler>
                <handler name="CarbonContentConfigurator"
                         class="org.wso2.carbon.mediation.initializer.handler.CarbonContextConfigurator"/>
            </phase>
            <phase name="Addressing">
                <handler name="AddressingBasedDispatcher"
                         class="org.apache.axis2.dispatchers.AddressingBasedDispatcher">
                    <order phase="Addressing"/>
                </handler>

            </phase>
            <phase name="Security"/>
            <phase name="PreDispatch"/>
            <phase name="Dispatch" class="org.apache.axis2.engine.DispatchPhase">
                <handler name="RequestURIBasedDispatcher"
                         class="org.apache.axis2.dispatchers.RequestURIBasedDispatcher"/>
                <handler name="SOAPActionBasedDispatcher"
                         class="org.apache.axis2.dispatchers.SOAPActionBasedDispatcher"/>
                <handler name="RequestURIOperationDispatcher"
                         class="org.apache.axis2.dispatchers.RequestURIOperationDispatcher"/>
                <handler name="SOAPMessageBodyBasedDispatcher"
                         class="org.apache.axis2.dispatchers.SOAPMessageBodyBasedDispatcher"/>

            <handler name="HTTPLocationBasedDispatcher"
                         class="org.apache.axis2.dispatchers.HTTPLocationBasedDispatcher"/>
                <handler name="MultitenantDispatcher"
                         class="org.wso2.carbon.tenant.dispatcher.MultitenantDispatcher"/>
                <handler name="SynapseDispatcher"
                         class="org.apache.synapse.core.axis2.SynapseDispatcher"/>
                <handler name="SynapseMustUnderstandHandler"
                         class="org.apache.synapse.core.axis2.SynapseMustUnderstandHandler"/>
            </phase>
            <phase name="RMPhase"/>
            <phase name="OpPhase"/>
            <phase name="AuthPhase"/>
            <phase name="MUPhase"/>
            <phase name="OperationInPhase"/>
        </phaseOrder>

        <phaseOrder type="OutFlow">
            <phase name="UEPPhase" />
            <phase name="RMPhase"/>
            <phase name="MUPhase"/>
            <phase name="OpPhase"/>
            <phase name="OperationOutPhase"/>
            <phase name="PolicyDetermination"/>
            <phase name="PTSecurityOutPhase">
                <handler name="RelaySecuirtyMessageBuilderDispatchandler"
                         class="org.apache.synapse.transport.passthru.util.RelaySecuirtyMessageBuilderDispatchandler"/>
            </phase>
            <phase name="MessageOut"/>
            <phase name="Security"/>
            <phase name="MsgOutObservation"/>
        </phaseOrder>

        <phaseOrder type="InFaultFlow">
            <phase name="MsgInObservation"/>
        <phase name="Validation"/>

            <phase name="Transport">
                <handler name="RequestURIBasedDispatcher"
                         class="org.apache.axis2.dispatchers.RequestURIBasedDispatcher">
                    <order phase="Transport"/>
                </handler>
                <handler name="SOAPActionBasedDispatcher"
                         class="org.apache.axis2.dispatchers.SOAPActionBasedDispatcher">
                    <order phase="Transport"/>
                </handler>
            <handler name="CarbonContentConfigurator"
                class="org.wso2.carbon.mediation.initializer.handler.CarbonContextConfigurator"/>
               </phase>

               <phase name="Addressing">
                <handler name="AddressingBasedDispatcher"
                         class="org.apache.axis2.dispatchers.AddressingBasedDispatcher">
                    <order phase="Addressing"/>
                </handler>
               </phase>

            <phase name="Security"/>
            <phase name="PreDispatch"/>
            <phase name="Dispatch" class="org.apache.axis2.engine.DispatchPhase">
                <handler name="RequestURIBasedDispatcher"
                         class="org.apache.axis2.dispatchers.RequestURIBasedDispatcher"/>
                <handler name="SOAPActionBasedDispatcher"
                         class="org.apache.axis2.dispatchers.SOAPActionBasedDispatcher"/>
                <handler name="RequestURIOperationDispatcher"
                         class="org.apache.axis2.dispatchers.RequestURIOperationDispatcher"/>
                <handler name="SOAPMessageBodyBasedDispatcher"
                         class="org.apache.axis2.dispatchers.SOAPMessageBodyBasedDispatcher"/>

                <handler name="HTTPLocationBasedDispatcher"
                         class="org.apache.axis2.dispatchers.HTTPLocationBasedDispatcher"/>
            </phase>
            <phase name="RMPhase"/>
            <phase name="OpPhase"/>
            <phase name="MUPhase"/>
            <phase name="OperationInFaultPhase"/>
        </phaseOrder>

        <phaseOrder type="OutFaultFlow">
            <phase name="UEPPhase" />
            <phase name="RMPhase"/>
            <phase name="MUPhase"/>
            <phase name="OperationOutFaultPhase"/>
            <phase name="PolicyDetermination"/>
            <phase name="MessageOut"/>
            <phase name="Security"/>
        <phase name="Transport"/>
            <phase name="MsgOutObservation"/>
        </phaseOrder>

    </axisconfig>
kind: ConfigMap
metadata:
    name: apim-conf-axis2
EOF

cat >> $k8s_obj_file << EOF
    namespace: $namespace
---
EOF

cat >> $k8s_obj_file << "EOF"
apiVersion: v1
data:
  api-manager.xml: |
    <APIManager>
        <DataSourceName>jdbc/WSO2AM_DB</DataSourceName>
        <GatewayType>Synapse</GatewayType>
        <EnableSecureVault>false</EnableSecureVault>
        <AuthManager>
            <ServerURL>https://localhost:${mgt.transport.https.port}${carbon.context}services/</ServerURL>
            <Username>${admin.username}</Username>
            <Password>${admin.password}</Password>
            <CheckPermissionsRemotely>false</CheckPermissionsRemotely>
        </AuthManager>
        <JWTConfiguration>
            <JWTHeader>X-JWT-Assertion</JWTHeader>
            <JWTGeneratorImpl>org.wso2.carbon.apimgt.keymgt.token.JWTGenerator</JWTGeneratorImpl>
        </JWTConfiguration>
        <APIGateway>
            <Environments>
                <Environment type="hybrid" api-console="true">
                    <Name>Production and Sandbox</Name>
                    <Description>This is a hybrid gateway that handles both production and sandbox token traffic.</Description>
                    <ServerURL>https://localhost:${mgt.transport.https.port}${carbon.context}services/</ServerURL>
                    <Username>${admin.username}</Username>
                    <Password>${admin.password}</Password>
EOF


echo "                    <GatewayEndpoint>http://'$NODE_IP':30243,https://'$NODE_IP':30243</GatewayEndpoint>" >> $k8s_obj_file

cat >> $k8s_obj_file << "EOF"
                    <GatewayWSEndpoint>ws://${carbon.local.ip}:9099</GatewayWSEndpoint>
                </Environment>
            </Environments>
        </APIGateway>
        <CacheConfigurations>
            <EnableGatewayTokenCache>true</EnableGatewayTokenCache>
            <EnableGatewayResourceCache>true</EnableGatewayResourceCache>
            <EnableKeyManagerTokenCache>false</EnableKeyManagerTokenCache>
            <EnableRecentlyAddedAPICache>false</EnableRecentlyAddedAPICache>
            <EnableScopeCache>true</EnableScopeCache>
            <EnablePublisherRoleCache>true</EnablePublisherRoleCache>
            <EnableJWTClaimCache>true</EnableJWTClaimCache>
        </CacheConfigurations>
        <Analytics>
            <Enabled>true</Enabled>
            <StreamProcessorServerURL>tcp://wso2apim-with-analytics-apim-analytics-service:7612</StreamProcessorServerURL>
            <StreamProcessorAuthServerURL>ssl://wso2apim-with-analytics-apim-analytics-service:7712</StreamProcessorAuthServerURL>
            <StreamProcessorUsername>${admin.username}</StreamProcessorUsername>
            <StreamProcessorPassword>${admin.password}</StreamProcessorPassword>
            <StatsProviderImpl>org.wso2.carbon.apimgt.usage.client.impl.APIUsageStatisticsRestClientImpl</StatsProviderImpl>
            <StreamProcessorRestApiURL>https://wso2apim-with-analytics-apim-analytics-service:7444</StreamProcessorRestApiURL>
            <StreamProcessorRestApiUsername>${admin.username}</StreamProcessorRestApiUsername>
            <StreamProcessorRestApiPassword>${admin.password}</StreamProcessorRestApiPassword>
            <SkipEventReceiverConnection>false</SkipEventReceiverConnection>
            <SkipWorkflowEventPublisher>false</SkipWorkflowEventPublisher>
            <PublisherClass>org.wso2.carbon.apimgt.usage.publisher.APIMgtUsageDataBridgeDataPublisher</PublisherClass>
            <PublishResponseMessageSize>false</PublishResponseMessageSize>
            <Streams>
                <Request>
                    <Name>org.wso2.apimgt.statistics.request</Name>
                    <Version>3.0.0</Version>
                </Request>
                <Fault>
                    <Name>org.wso2.apimgt.statistics.fault</Name>
                    <Version>3.0.0</Version>
                </Fault>
                <Throttle>
                    <Name>org.wso2.apimgt.statistics.throttle</Name>
                    <Version>3.0.0</Version>
                </Throttle>
                <Workflow>
                    <Name>org.wso2.apimgt.statistics.workflow</Name>
                    <Version>1.0.0</Version>
                </Workflow>
                <AlertTypes>
                    <Name>org.wso2.analytics.apim.alertStakeholderInfo</Name>
                    <Version>1.0.1</Version>
                </AlertTypes>
            </Streams>
        </Analytics>
        <APIKeyValidator>
            <ServerURL>https://localhost:${mgt.transport.https.port}${carbon.context}services/</ServerURL>
            <Username>${admin.username}</Username>
            <Password>${admin.password}</Password>
            <KeyValidatorClientType>ThriftClient</KeyValidatorClientType>
            <ThriftClientConnectionTimeOut>10000</ThriftClientConnectionTimeOut>
            <EnableThriftServer>true</EnableThriftServer>
            <ThriftServerHost>localhost</ThriftServerHost>
            <KeyValidationHandlerClassName>org.wso2.carbon.apimgt.keymgt.handlers.DefaultKeyValidationHandler</KeyValidationHandlerClassName>
        </APIKeyValidator>
        <OAuthConfigurations>
            <ApplicationTokenScope>am_application_scope</ApplicationTokenScope>
            <TokenEndPointName>/oauth2/token</TokenEndPointName>
            <RevokeAPIURL>https://localhost:${https.nio.port}/revoke</RevokeAPIURL>
            <EncryptPersistedTokens>false</EncryptPersistedTokens>
            <EnableTokenHashMode>false</EnableTokenHashMode>
        </OAuthConfigurations>
        <TierManagement>
            <EnableUnlimitedTier>true</EnableUnlimitedTier>
        </TierManagement>
        <APIStore>
            <CompareCaseInsensitively>true</CompareCaseInsensitively>
            <DisplayURL>false</DisplayURL>
EOF

echo "            <URL>https://$NODE_IP:30443/store</URL>" >> $k8s_obj_file
echo "            <ServerURL>https://localhost:9443/services/</ServerURL>" >> $k8s_obj_file

cat >> $k8s_obj_file << "EOF"
            <Username>${admin.username}</Username>
            <Password>${admin.password}</Password>
            <DisplayMultipleVersions>false</DisplayMultipleVersions>
            <DisplayAllAPIs>false</DisplayAllAPIs>
            <DisplayComments>true</DisplayComments>
            <DisplayRatings>true</DisplayRatings>
        </APIStore>
        <APIPublisher>
            <DisplayURL>false</DisplayURL>
            <URL>https://localhost:${mgt.transport.https.port}/publisher</URL>
            <EnableAccessControl>true</EnableAccessControl>
        </APIPublisher>
        <CORSConfiguration>
            <Enabled>true</Enabled>
            <Access-Control-Allow-Origin>*</Access-Control-Allow-Origin>
            <Access-Control-Allow-Methods>GET,PUT,POST,DELETE,PATCH,OPTIONS</Access-Control-Allow-Methods>
            <Access-Control-Allow-Headers>authorization,Access-Control-Allow-Origin,Content-Type,SOAPAction</Access-Control-Allow-Headers>
            <Access-Control-Allow-Credentials>false</Access-Control-Allow-Credentials>
        </CORSConfiguration>
        <RESTAPI>
            <WhiteListedURIs>
                <WhiteListedURI>
                    <URI>/api/am/publisher/{version}/swagger.json</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/swagger.json</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/admin/{version}/swagger.json</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis/{apiId}</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis/{apiId}/swagger</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis/{apiId}/documents</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis/{apiId}/documents/{documentId}</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis/{apiId}/documents/{documentId}/content</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/apis/{apiId}/thumbnail</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/tags</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/tiers/{tierLevel}</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
                <WhiteListedURI>
                    <URI>/api/am/store/{version}/tiers/{tierLevel}/{tierName}</URI>
                    <HTTPMethods>GET,HEAD</HTTPMethods>
                </WhiteListedURI>
            </WhiteListedURIs>
            <ETagSkipList>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/apis</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/apis/generate-sdk</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/apis/{apiId}/documents</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/applications</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/applications/generate-keys</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/subscriptions</URI>
                    <HTTPMethods>GET,POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/tags</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/tiers/{tierLevel}</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/store/{version}/tiers/{tierLevel}/{tierName}</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis</URI>
                    <HTTPMethods>GET,POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}</URI>
                    <HTTPMethods>GET,DELETE,PUT</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/swagger</URI>
                    <HTTPMethods>GET,PUT</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/thumbnail</URI>
                    <HTTPMethods>GET,POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/change-lifecycle</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/copy-api</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/applications/{applicationId}</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/documents</URI>
                    <HTTPMethods>GET,POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/documents/{documentId}/content</URI>
                    <HTTPMethods>GET,POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/apis/{apiId}/documents/{documentId}</URI>
                    <HTTPMethods>GET,PUT,DELETE</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/environments</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/subscriptions</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/subscriptions/block-subscription</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/subscriptions/{subscriptionId}</URI>
                    <HTTPMethods>GET</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/subscriptions/unblock-subscription</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/tiers/{tierLevel}</URI>
                    <HTTPMethods>GET,POST</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/tiers/{tierLevel}/{tierName}</URI>
                    <HTTPMethods>GET,PUT,DELETE</HTTPMethods>
                </ETagSkipURI>
                <ETagSkipURI>
                    <URI>/api/am/publisher/{version}/tiers/update-permission</URI>
                    <HTTPMethods>POST</HTTPMethods>
                </ETagSkipURI>
            </ETagSkipList>
        </RESTAPI>
        <ThrottlingConfigurations>
            <EnableAdvanceThrottling>true</EnableAdvanceThrottling>
            <TrafficManager>
                <Type>Binary</Type>
                <ReceiverUrlGroup>tcp://${carbon.local.ip}:${receiver.url.port}</ReceiverUrlGroup>
                <AuthUrlGroup>ssl://${carbon.local.ip}:${auth.url.port}</AuthUrlGroup>
                <Username>${admin.username}</Username>
                <Password>${admin.password}</Password>
            </TrafficManager>
            <DataPublisher>
                <Enabled>true</Enabled>
                <DataPublisherPool>
                    <MaxIdle>1000</MaxIdle>
                    <InitIdleCapacity>200</InitIdleCapacity>
                </DataPublisherPool>
                <DataPublisherThreadPool>
                    <CorePoolSize>200</CorePoolSize>
                    <MaxmimumPoolSize>1000</MaxmimumPoolSize>
                    <KeepAliveTime>200</KeepAliveTime>
                </DataPublisherThreadPool>
            </DataPublisher>
            <PolicyDeployer>
                <Enabled>true</Enabled>
                <ServiceURL>https://localhost:${mgt.transport.https.port}${carbon.context}services/</ServiceURL>
                <Username>${admin.username}</Username>
                <Password>${admin.password}</Password>
            </PolicyDeployer>
            <BlockCondition>
                <Enabled>true</Enabled>
            </BlockCondition>
            <JMSConnectionDetails>
                <Enabled>true</Enabled>
                <JMSConnectionParameters>
                    <transport.jms.ConnectionFactoryJNDIName>TopicConnectionFactory</transport.jms.ConnectionFactoryJNDIName>
                    <transport.jms.DestinationType>topic</transport.jms.DestinationType>
                    <java.naming.factory.initial>org.wso2.andes.jndi.PropertiesFileInitialContextFactory</java.naming.factory.initial>
                    <connectionfactory.TopicConnectionFactory>amqp://${admin.username}:${admin.password}@clientid/carbon?brokerlist='tcp://${carbon.local.ip}:${jms.port}'</connectionfactory.TopicConnectionFactory>
                </JMSConnectionParameters>
            </JMSConnectionDetails>=
            <EnableUnlimitedTier>true</EnableUnlimitedTier>
            <EnableHeaderConditions>false</EnableHeaderConditions>
            <EnableJWTClaimConditions>false</EnableJWTClaimConditions>
            <EnableQueryParamConditions>false</EnableQueryParamConditions>
        </ThrottlingConfigurations>
        <WorkflowConfigurations>
            <Enabled>false</Enabled>
            <ServerUrl>https://localhost:9445/bpmn</ServerUrl>
            <ServerUser>${admin.username}</ServerUser>
            <ServerPassword>${admin.password}</ServerPassword>
            <WorkflowCallbackAPI>https://localhost:${mgt.transport.https.port}/api/am/publisher/v0.14/workflows/update-workflow-status</WorkflowCallbackAPI>
            <TokenEndPoint>https://localhost:${https.nio.port}/token</TokenEndPoint>
            <DCREndPoint>https://localhost:${mgt.transport.https.port}/client-registration/v0.14/register</DCREndPoint>
            <DCREndPointUser>${admin.username}</DCREndPointUser>
            <DCREndPointPassword>${admin.password}</DCREndPointPassword>
        </WorkflowConfigurations>
        <SwaggerCodegen>
            <ClientGeneration>
                <GroupId>org.wso2</GroupId>
                <ArtifactId>org.wso2.client.</ArtifactId>
                <ModelPackage>org.wso2.client.model.</ModelPackage>
                <ApiPackage>org.wso2.client.api.</ApiPackage>
                <SupportedLanguages>java,android</SupportedLanguages>
            </ClientGeneration>
        </SwaggerCodegen>
    </APIManager>
  carbon.xml: |
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <Server xmlns="http://wso2.org/projects/carbon/carbon.xml">
        <Name>WSO2 API Manager</Name>
        <ServerKey>AM</ServerKey>
        <Version>2.6.0</Version>
EOF

echo "        <HostName>wso2.us-central1a-google-clouds.com</HostName>" >> $k8s_obj_file

echo "        <MgtHostName>wso2.us-central1a-google-clouds.com</MgtHostName>" >> $k8s_obj_file

cat >> $k8s_obj_file << "EOF"
        <ServerURL>local:/${carbon.context}/services/</ServerURL>
        <ServerRoles>
            <Role>APIManager</Role>
        </ServerRoles>
        <Package>org.wso2.carbon</Package>
        <WebContextRoot>/</WebContextRoot>
        <ItemsPerPage>15</ItemsPerPage>
        <Ports>
            <Offset>0</Offset>
            <JMX>
                <RMIRegistryPort>9999</RMIRegistryPort>
                <RMIServerPort>11111</RMIServerPort>
            </JMX>
            <EmbeddedLDAP>
                <LDAPServerPort>10389</LDAPServerPort>
                <KDCServerPort>8000</KDCServerPort>
            </EmbeddedLDAP>
            <ThriftEntitlementReceivePort>10500</ThriftEntitlementReceivePort>
        </Ports>
        <JNDI>
            <DefaultInitialContextFactory>org.wso2.carbon.tomcat.jndi.CarbonJavaURLContextFactory</DefaultInitialContextFactory>
            <Restrictions>
                <AllTenants>
                    <UrlContexts>
                        <UrlContext>
                            <Scheme>java</Scheme>
                        </UrlContext>
                    </UrlContexts>
                </AllTenants>
            </Restrictions>
        </JNDI>
        <IsCloudDeployment>false</IsCloudDeployment>
        <EnableMetering>false</EnableMetering>
        <MaxThreadExecutionTime>600</MaxThreadExecutionTime>
        <GhostDeployment>
            <Enabled>false</Enabled>
        </GhostDeployment>
        <Tenant>
            <LoadingPolicy>
                <LazyLoading>
                    <IdleTime>30</IdleTime>
                </LazyLoading>
            </LoadingPolicy>
        </Tenant>
        <Cache>
            <DefaultCacheTimeout>15</DefaultCacheTimeout>
            <ForceLocalCache>false</ForceLocalCache>
        </Cache>
        <Axis2Config>
            <RepositoryLocation>${carbon.home}/repository/deployment/server/</RepositoryLocation>
            <DeploymentUpdateInterval>15</DeploymentUpdateInterval>
            <ConfigurationFile>${carbon.home}/repository/conf/axis2/axis2.xml</ConfigurationFile>
            <ServiceGroupContextIdleTime>30000</ServiceGroupContextIdleTime>
            <ClientRepositoryLocation>${carbon.home}/repository/deployment/client/</ClientRepositoryLocation>
            <clientAxis2XmlLocation>${carbon.home}/repository/conf/axis2/axis2_client.xml</clientAxis2XmlLocation>
            <HideAdminServiceWSDLs>true</HideAdminServiceWSDLs>
        </Axis2Config>
        <ServiceUserRoles>
            <Role>
                <Name>admin</Name>
                <Description>Default Administrator Role</Description>
            </Role>
            <Role>
                <Name>user</Name>
                <Description>Default User Role</Description>
            </Role>
        </ServiceUserRoles>
        <CryptoService>
            <Enabled>true</Enabled>
            <InternalCryptoProviderClassName>org.wso2.carbon.crypto.provider.KeyStoreBasedInternalCryptoProvider</InternalCryptoProviderClassName>
            <ExternalCryptoProviderClassName>org.wso2.carbon.core.encryption.KeyStoreBasedExternalCryptoProvider</ExternalCryptoProviderClassName>
            <KeyResolvers>
                <KeyResolver className="org.wso2.carbon.crypto.defaultProvider.resolver.ContextIndependentKeyResolver" priority="-1"/>
            </KeyResolvers>
        </CryptoService>
        <Security>
            <KeyStore>
                <Location>${carbon.home}/repository/resources/security/wso2carbon.jks</Location>
                <Type>JKS</Type>
                <Password>wso2carbon</Password>
                <KeyAlias>wso2carbon</KeyAlias>
                <KeyPassword>wso2carbon</KeyPassword>
            </KeyStore>
            <InternalKeyStore>
                <Location>${carbon.home}/repository/resources/security/wso2carbon.jks</Location>
                <Type>JKS</Type>
                <Password>wso2carbon</Password>
                <KeyAlias>wso2carbon</KeyAlias>
                <KeyPassword>wso2carbon</KeyPassword>
            </InternalKeyStore>
            <TrustStore>
                <Location>${carbon.home}/repository/resources/security/client-truststore.jks</Location>
                <Type>JKS</Type>
                <Password>wso2carbon</Password>
            </TrustStore>
            <NetworkAuthenticatorConfig>
            </NetworkAuthenticatorConfig>
            <TomcatRealm>UserManager</TomcatRealm>
            <DisableTokenStore>false</DisableTokenStore>
            <XSSPreventionConfig>
                <Enabled>true</Enabled>
                <Rule>allow</Rule>
                <Patterns>
                </Patterns>
            </XSSPreventionConfig>
        </Security>
        <HideMenuItemIds>
            <HideMenuItemId>claim_mgt_menu</HideMenuItemId>
            <HideMenuItemId>identity_mgt_emailtemplate_menu</HideMenuItemId>
            <HideMenuItemId>identity_security_questions_menu</HideMenuItemId>
        </HideMenuItemIds>
        <WorkDirectory>${carbon.home}/tmp/work</WorkDirectory>
        <HouseKeeping>
            <AutoStart>true</AutoStart>
            <Interval>10</Interval>
            <MaxTempFileLifetime>30</MaxTempFileLifetime>
        </HouseKeeping>
        <FileUploadConfig>
            <TotalFileSizeLimit>100</TotalFileSizeLimit>
            <Mapping>
                <Actions>
                    <Action>keystore</Action>
                    <Action>certificate</Action>
                    <Action>*</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.AnyFileUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>jarZip</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.JarZipUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>dbs</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.DBSFileUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>tools</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsFileUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>toolsAny</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsAnyFileUploadExecutor</Class>
            </Mapping>
        </FileUploadConfig>
        <HttpGetRequestProcessors>
            <Processor>
                <Item>info</Item>
                <Class>org.wso2.carbon.core.transports.util.InfoProcessor</Class>
            </Processor>
            <Processor>
                <Item>wsdl</Item>
                <Class>org.wso2.carbon.core.transports.util.Wsdl11Processor</Class>
            </Processor>
            <Processor>
                <Item>wsdl2</Item>
                <Class>org.wso2.carbon.core.transports.util.Wsdl20Processor</Class>
            </Processor>
            <Processor>
                <Item>xsd</Item>
                <Class>org.wso2.carbon.core.transports.util.XsdProcessor</Class>
            </Processor>
        </HttpGetRequestProcessors>
        <DeploymentSynchronizer>
            <Enabled>false</Enabled>
            <AutoCommit>false</AutoCommit>
            <AutoCheckout>true</AutoCheckout>
            <RepositoryType>svn</RepositoryType>
            <SvnUrl>http://svnrepo.example.com/repos/</SvnUrl>
            <SvnUser>username</SvnUser>
            <SvnPassword>password</SvnPassword>
            <SvnUrlAppendTenantId>true</SvnUrlAppendTenantId>
        </DeploymentSynchronizer>
        <ServerInitializers>
        </ServerInitializers>
        <RequireCarbonServlet>${require.carbon.servlet}</RequireCarbonServlet>
        <StatisticsReporterDisabled>true</StatisticsReporterDisabled>
        <FeatureRepository>
            <RepositoryName>default repository</RepositoryName>
            <RepositoryURL>http://product-dist.wso2.com/p2/carbon/releases/wilkes/</RepositoryURL>
        </FeatureRepository>
        <APIManagement>
            <Enabled>true</Enabled>
            <LoadAPIContextsInServerStartup>true</LoadAPIContextsInServerStartup>
        </APIManagement>
    </Server>
  user-mgt.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <UserManager>
        <Realm>
            <Configuration>
                <AddAdmin>true</AddAdmin>
                <AdminRole>admin</AdminRole>
                <AdminUser>
                    <UserName>admin</UserName>
                    <Password>admin</Password>
                </AdminUser>
                <EveryOneRoleName>everyone</EveryOneRoleName>
                <Property name="isCascadeDeleteEnabled">true</Property>
                <Property name="initializeNewClaimManager">true</Property>
                <Property name="dataSource">jdbc/WSO2UM_DB</Property>
            </Configuration>
            <UserStoreManager class="org.wso2.carbon.user.core.jdbc.JDBCUserStoreManager">
                <Property name="TenantManager">org.wso2.carbon.user.core.tenant.JDBCTenantManager</Property>
                <Property name="ReadOnly">false</Property>
                <Property name="ReadGroups">true</Property>
                <Property name="WriteGroups">true</Property>
                <Property name="UsernameJavaRegEx">^[\S]{3,30}$</Property>
                <Property name="UsernameJavaScriptRegEx">^[\S]{3,30}$</Property>
                <Property name="UsernameJavaRegExViolationErrorMsg">Username pattern policy violated</Property>
                <Property name="PasswordJavaRegEx">^[\S]{5,30}$</Property>
                <Property name="PasswordJavaScriptRegEx">^[\S]{5,30}$</Property>
                <Property name="PasswordJavaRegExViolationErrorMsg">Password length should be within 5 to 30 characters</Property>
                <Property name="RolenameJavaRegEx">^[\S]{3,30}$</Property>
                <Property name="RolenameJavaScriptRegEx">^[\S]{3,30}$</Property>
                <Property name="CaseInsensitiveUsername">true</Property>
                <Property name="SCIMEnabled">false</Property>
                <Property name="IsBulkImportSupported">true</Property>
                <Property name="PasswordDigest">SHA-256</Property>
                <Property name="StoreSaltedPassword">true</Property>
                <Property name="MultiAttributeSeparator">,</Property>
                <Property name="MaxUserNameListLength">100</Property>
                <Property name="MaxRoleNameListLength">100</Property>
                <Property name="UserRolesCacheEnabled">true</Property>
                <Property name="UserNameUniqueAcrossTenants">false</Property>
            </UserStoreManager>
                  <AuthorizationManager class="org.wso2.carbon.user.core.authorization.JDBCAuthorizationManager">
                <Property name="AdminRoleManagementPermissions">/permission</Property>
                <Property name="AuthorizationCacheEnabled">true</Property>
                <Property name="GetAllRolesOfUserEnabled">false</Property>
            </AuthorizationManager>
        </Realm>
    </UserManager>
kind: ConfigMap
metadata:
  name: apim-conf
EOF

cat >> $k8s_obj_file << EOF
  namespace: $namespace
---

apiVersion: v1
data:
  master-datasources.xml: |
    <datasources-configuration xmlns:svns="http://org.wso2.securevault/configuration">
        <providers>
            <provider>org.wso2.carbon.ndatasource.rdbms.RDBMSDataSourceReader</provider>
        </providers>
        <datasources>
            <datasource>
                <name>WSO2_CARBON_DB</name>
                <description>The datasource used for registry and user manager</description>
                <jndiConfig>
                    <name>jdbc/WSO2CarbonDB</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:h2:repository/database/WSO2CARBON_DB;DB_CLOSE_ON_EXIT=FALSE</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>org.h2.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <defaultAutoCommit>true</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2AM_DB</name>
                <description>The datasource used for API Manager database</description>
                <jndiConfig>
                    <name>jdbc/WSO2AM_DB</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_APIMGT_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <defaultAutoCommit>false</defaultAutoCommit>
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2UM_DB</name>
                <description>The datasource used by user manager</description>
                <jndiConfig>
                    <name>jdbc/WSO2UM_DB</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_COMMON_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2REG_DB</name>
                <description>The datasource used by the registry</description>
                <jndiConfig>
                    <name>jdbc/WSO2REG_DB</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_COMMON_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                <defaultAutoCommit>true</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2_MB_STORE_DB</name>
                <description>The datasource used for message broker database</description>
                <jndiConfig>
                    <name>WSO2MBStoreDB</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:h2:repository/database/WSO2MB_DB;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>org.h2.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <defaultAutoCommit>false</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
        </datasources>
    </datasources-configuration>
kind: ConfigMap
metadata:
  name: apim-conf-datasources
  namespace: $namespace
---
EOF

cat >> $k8s_obj_file << "EOF"
apiVersion: v1
data:
  deployment.yaml: |
    wso2.carbon:
      type: wso2-apim-analytics
      id: wso2-am-analytics
      name: WSO2 API Manager Analytics Server
      ports:
        offset: 1
    wso2.transport.http:
      transportProperties:
        -
          name: "server.bootstrap.socket.timeout"
          value: 60
        -
          name: "client.bootstrap.socket.timeout"
          value: 60
        -
          name: "latency.metrics.enabled"
          value: true
      listenerConfigurations:
        -
          id: "default"
          host: "0.0.0.0"
          port: 9091
        -
          id: "msf4j-https"
          host: "0.0.0.0"
          port: 9444
          scheme: https
          keyStoreFile: "${carbon.home}/resources/security/wso2carbon.jks"
          keyStorePassword: wso2carbon
          certPass: wso2carbon
      senderConfigurations:
        -
          id: "http-sender"
    siddhi.stores.query.api:
      transportProperties:
        -
          name: "server.bootstrap.socket.timeout"
          value: 60
        -
          name: "client.bootstrap.socket.timeout"
          value: 60
        -
          name: "latency.metrics.enabled"
          value: true
      listenerConfigurations:
        -
          id: "default"
          host: "0.0.0.0"
          port: 7071
        -
          id: "msf4j-https"
          host: "0.0.0.0"
          port: 7444
          scheme: https
          keyStoreFile: "${carbon.home}/resources/security/wso2carbon.jks"
          keyStorePassword: wso2carbon
          certPass: wso2carbon
    databridge.config:
      workerThreads: 10
      maxEventBufferCapacity: 10000000
      eventBufferSize: 2000
      keyStoreLocation : ${sys:carbon.home}/resources/security/wso2carbon.jks
      keyStorePassword : wso2carbon
      clientTimeoutMin: 30
      dataReceivers:
      -
        dataReceiver:
          type: Thrift
          properties:
            tcpPort: '7611'
            sslPort: '7711'
      -
        dataReceiver:
          type: Binary
          properties:
            tcpPort: '9611'
            sslPort: '9711'
            tcpReceiverThreadPoolSize: '100'
            sslReceiverThreadPoolSize: '100'
            hostName: 0.0.0.0
    data.agent.config:
      agents:
      -
        agentConfiguration:
          name: Thrift
          dataEndpointClass: org.wso2.carbon.databridge.agent.endpoint.thrift.ThriftDataEndpoint
          publishingStrategy: async
          trustStorePath: '${sys:carbon.home}/resources/security/client-truststore.jks'
          trustStorePassword: 'wso2carbon'
          queueSize: 32768
          batchSize: 200
          corePoolSize: 1
          socketTimeoutMS: 30000
          maxPoolSize: 1
          keepAliveTimeInPool: 20
          reconnectionInterval: 30
          maxTransportPoolSize: 250
          maxIdleConnections: 250
          evictionTimePeriod: 5500
          minIdleTimeInPool: 5000
          secureMaxTransportPoolSize: 250
          secureMaxIdleConnections: 250
          secureEvictionTimePeriod: 5500
          secureMinIdleTimeInPool: 5000
          sslEnabledProtocols: TLSv1.1,TLSv1.2
          ciphers: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
      -
        agentConfiguration:
          name: Binary
          dataEndpointClass: org.wso2.carbon.databridge.agent.endpoint.binary.BinaryDataEndpoint
          publishingStrategy: async
          trustStorePath: '${sys:carbon.home}/resources/security/client-truststore.jks'
          trustStorePassword: 'wso2carbon'
          queueSize: 32768
          batchSize: 200
          corePoolSize: 1
          socketTimeoutMS: 30000
          maxPoolSize: 1
          keepAliveTimeInPool: 20
          reconnectionInterval: 30
          maxTransportPoolSize: 250
          maxIdleConnections: 250
          evictionTimePeriod: 5500
          minIdleTimeInPool: 5000
          secureMaxTransportPoolSize: 250
          secureMaxIdleConnections: 250
          secureEvictionTimePeriod: 5500
          secureMinIdleTimeInPool: 5000
          sslEnabledProtocols: TLSv1.1,TLSv1.2
          ciphers: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    wso2.metrics:
      enabled: false
      reporting:
        console:
          -
            name: Console
            enabled: false
            pollingPeriod: 5
    wso2.metrics.jdbc:
      dataSource:
        - &JDBC01
          dataSourceName: java:comp/env/jdbc/WSO2MetricsDB
          scheduledCleanup:
            enabled: true
            daysToKeep: 3
            scheduledCleanupPeriod: 86400
      reporting:
        jdbc:
          -
            name: JDBC
            enabled: true
            dataSource: *JDBC01
            pollingPeriod: 60
    wso2.artifact.deployment:
      updateInterval: 5
    state.persistence:
      enabled: false
      intervalInMin: 1
      revisionsToKeep: 2
      persistenceStore: org.wso2.carbon.stream.processor.core.persistence.FileSystemPersistenceStore
      config:
        location: siddhi-app-persistence
    wso2.securevault:
      secretRepository:
        type: org.wso2.carbon.secvault.repository.DefaultSecretRepository
        parameters:
          privateKeyAlias: wso2carbon
          keystoreLocation: ${sys:carbon.home}/resources/security/securevault.jks
          secretPropertiesFile: ${sys:carbon.home}/conf/${sys:wso2.runtime}/secrets.properties
      masterKeyReader:
        type: org.wso2.carbon.secvault.reader.DefaultMasterKeyReader
        parameters:
          masterKeyReaderFile: ${sys:carbon.home}/conf/${sys:wso2.runtime}/master-keys.yaml
    wso2.datasources:
      dataSources:
        -
          definition:
            configuration:
              connectionTestQuery: "SELECT 1"
              driverClassName: com.mysql.jdbc.Driver
              idleTimeout: 60000
              isAutoCommit: false
              jdbcUrl: 'jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_COMMON_DB?useSSL=false'
              maxPoolSize: 50
              password: wso2carbon
              username: wso2carbon
              validationTimeout: 30000
            type: RDBMS
          description: "The datasource used for registry and user manager"
          name: WSO2_CARBON_DB
        - name: WSO2_METRICS_DB
          description: The datasource used for dashboard feature
          jndiConfig:
            name: jdbc/WSO2MetricsDB
          definition:
            type: RDBMS
            configuration:
              jdbcUrl: 'jdbc:h2:${sys:carbon.home}/wso2/dashboard/database/metrics;AUTO_SERVER=TRUE'
              username: wso2carbon
              password: wso2carbon
              driverClassName: org.h2.Driver
              maxPoolSize: 30
              idleTimeout: 60000
              connectionTestQuery: SELECT 1
              validationTimeout: 30000
              isAutoCommit: false
        - name: WSO2_PERMISSIONS_DB
          description: The datasource used for permission feature
          jndiConfig:
            name: jdbc/PERMISSION_DB
            useJndiReference: true
          definition:
            type: RDBMS
            configuration:
              jdbcUrl: 'jdbc:h2:${sys:carbon.home}/wso2/${sys:wso2.runtime}/database/PERMISSION_DB;IFEXISTS=TRUE;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000;MVCC=TRUE'
              username: wso2carbon
              password: wso2carbon
              driverClassName: org.h2.Driver
              maxPoolSize: 10
              idleTimeout: 60000
              connectionTestQuery: SELECT 1
              validationTimeout: 30000
              isAutoCommit: false
        - name: Message_Tracing_DB
          description: "The datasource used for message tracer to store span information."
          jndiConfig:
            name: jdbc/Message_Tracing_DB
          definition:
            type: RDBMS
            configuration:
              jdbcUrl: 'jdbc:h2:${sys:carbon.home}/wso2/dashboard/database/MESSAGE_TRACING_DB;AUTO_SERVER=TRUE'
              username: wso2carbon
              password: wso2carbon
              driverClassName: org.h2.Driver
              maxPoolSize: 50
              idleTimeout: 60000
              connectionTestQuery: SELECT 1
              validationTimeout: 30000
              isAutoCommit: false
        - name: GEO_LOCATION_DATA
          description: "The data source used for geo location database"
          jndiConfig:
            name: jdbc/GEO_LOCATION_DATA
          definition:
            type: RDBMS
            configuration:
              jdbcUrl: 'jdbc:h2:${sys:carbon.home}/wso2/worker/database/GEO_LOCATION_DATA;AUTO_SERVER=TRUE'
              username: wso2carbon
              password: wso2carbon
              driverClassName: org.h2.Driver
              maxPoolSize: 50
              idleTimeout: 60000
              validationTimeout: 30000
              isAutoCommit: false
        - name: APIM_ANALYTICS_DB
          description: "The datasource used for APIM statistics aggregated data."
          jndiConfig:
            name: jdbc/APIM_ANALYTICS_DB
          definition:
            type: RDBMS
            configuration:
              jdbcUrl: 'jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_STAT_DB?useSSL=false'
              username: wso2carbon
              password: wso2carbon
              driverClassName: com.mysql.jdbc.Driver
              maxPoolSize: 50
              idleTimeout: 60000
              connectionTestQuery: SELECT 1
              validationTimeout: 30000
              isAutoCommit: false
        - name: WSO2AM_MGW_ANALYTICS_DB
          description: "The datasource used for APIM MGW analytics data."
          jndiConfig:
            name: jdbc/WSO2AM_MGW_ANALYTICS_DB
          definition:
            type: RDBMS
            configuration:
              jdbcUrl: 'jdbc:h2:${sys:carbon.home}/wso2/worker/database/WSO2AM_MGW_ANALYTICS_DB;AUTO_SERVER=TRUE'
              username: wso2carbon
              password: wso2carbon
              driverClassName: org.h2.Driver
              maxPoolSize: 50
              idleTimeout: 60000
              connectionTestQuery: SELECT 1
              validationTimeout: 30000
              isAutoCommit: false
    siddhi:
      extensions:
        -
          extension:
            name: 'findCountryFromIP'
            namespace: 'geo'
            properties:
              geoLocationResolverClass: org.wso2.extension.siddhi.execution.geo.internal.impl.DefaultDBBasedGeoLocationResolver
              isCacheEnabled: true
              cacheSize: 10000
              isPersistInDatabase: true
              datasource: GEO_LOCATION_DATA
        -
          extension:
            name: 'findCityFromIP'
            namespace: 'geo'
            properties:
              geoLocationResolverClass: org.wso2.extension.siddhi.execution.geo.internal.impl.DefaultDBBasedGeoLocationResolver
              isCacheEnabled: true
              cacheSize: 10000
              isPersistInDatabase: true
              datasource: GEO_LOCATION_DATA
    cluster.config:
      enabled: false
      groupId:  sp
      coordinationStrategyClass: org.wso2.carbon.cluster.coordinator.rdbms.RDBMSCoordinationStrategy
      strategyConfig:
        datasource: WSO2_CARBON_DB
        heartbeatInterval: 1000
        heartbeatMaxRetry: 2
        eventPollingInterval: 1000
kind: ConfigMap
metadata:
  name: apim-analytics-conf-worker
EOF

cat >> $k8s_obj_file << EOF
  namespace: $namespace
---
EOF

cat >> $k8s_obj_file << "EOF"
apiVersion: v1
data:
  init.sql: |
    DROP DATABASE IF EXISTS WSO2AM_COMMON_DB;
    DROP DATABASE IF EXISTS WSO2AM_APIMGT_DB;
    DROP DATABASE IF EXISTS WSO2AM_STAT_DB;
    CREATE DATABASE WSO2AM_COMMON_DB;
    CREATE DATABASE WSO2AM_APIMGT_DB;
    CREATE DATABASE WSO2AM_STAT_DB;
    CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    GRANT ALL ON WSO2AM_COMMON_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    GRANT ALL ON WSO2AM_APIMGT_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    GRANT ALL ON WSO2AM_STAT_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    USE WSO2AM_COMMON_DB;
    CREATE TABLE IF NOT EXISTS REG_CLUSTER_LOCK (
                 REG_LOCK_NAME VARCHAR (20),
                 REG_LOCK_STATUS VARCHAR (20),
                 REG_LOCKED_TIME TIMESTAMP,
                 REG_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (REG_LOCK_NAME)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_LOG (
                 REG_LOG_ID INTEGER AUTO_INCREMENT,
                 REG_PATH VARCHAR (750),
                 REG_USER_ID VARCHAR (31) NOT NULL,
                 REG_LOGGED_TIME TIMESTAMP NOT NULL,
                 REG_ACTION INTEGER NOT NULL,
                 REG_ACTION_DATA VARCHAR (500),
                 REG_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (REG_LOG_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX REG_LOG_IND_BY_REGLOG USING HASH ON REG_LOG(REG_LOGGED_TIME, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_PATH(
                 REG_PATH_ID INTEGER NOT NULL AUTO_INCREMENT,
                 REG_PATH_VALUE VARCHAR(750) NOT NULL,
                 REG_PATH_PARENT_ID INTEGER,
                 REG_TENANT_ID INTEGER DEFAULT 0,
                 CONSTRAINT PK_REG_PATH PRIMARY KEY(REG_PATH_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX REG_PATH_IND_BY_PATH_VALUE USING HASH ON REG_PATH(REG_PATH_VALUE, REG_TENANT_ID);
    CREATE INDEX REG_PATH_IND_BY_PATH_PARENT_ID USING HASH ON REG_PATH(REG_PATH_PARENT_ID, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_CONTENT (
                 REG_CONTENT_ID INTEGER NOT NULL AUTO_INCREMENT,
                 REG_CONTENT_DATA LONGBLOB,
                 REG_TENANT_ID INTEGER DEFAULT 0,
                 CONSTRAINT PK_REG_CONTENT PRIMARY KEY(REG_CONTENT_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_CONTENT_HISTORY (
                 REG_CONTENT_ID INTEGER NOT NULL,
                 REG_CONTENT_DATA LONGBLOB,
                 REG_DELETED   SMALLINT,
                 REG_TENANT_ID INTEGER DEFAULT 0,
                 CONSTRAINT PK_REG_CONTENT_HISTORY PRIMARY KEY(REG_CONTENT_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_RESOURCE (
                REG_PATH_ID         INTEGER NOT NULL,
                REG_NAME            VARCHAR(256),
                REG_VERSION         INTEGER NOT NULL AUTO_INCREMENT,
                REG_MEDIA_TYPE      VARCHAR(500),
                REG_CREATOR         VARCHAR(31) NOT NULL,
                REG_CREATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                REG_LAST_UPDATOR    VARCHAR(31),
                REG_LAST_UPDATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                REG_DESCRIPTION     VARCHAR(1000),
                REG_CONTENT_ID      INTEGER,
                REG_TENANT_ID INTEGER DEFAULT 0,
                REG_UUID VARCHAR(100) NOT NULL,
                CONSTRAINT PK_REG_RESOURCE PRIMARY KEY(REG_VERSION, REG_TENANT_ID)
    )ENGINE INNODB;
    ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_CONTENT_ID FOREIGN KEY (REG_CONTENT_ID, REG_TENANT_ID) REFERENCES REG_CONTENT (REG_CONTENT_ID, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_IND_BY_NAME USING HASH ON REG_RESOURCE(REG_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_IND_BY_PATH_ID_NAME USING HASH ON REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_IND_BY_UUID USING HASH ON REG_RESOURCE(REG_UUID);
    CREATE INDEX REG_RESOURCE_IND_BY_TENAN USING HASH ON REG_RESOURCE(REG_TENANT_ID, REG_UUID);
    CREATE INDEX REG_RESOURCE_IND_BY_TYPE USING HASH ON REG_RESOURCE(REG_TENANT_ID, REG_MEDIA_TYPE);
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_HISTORY (
                REG_PATH_ID         INTEGER NOT NULL,
                REG_NAME            VARCHAR(256),
                REG_VERSION         INTEGER NOT NULL,
                REG_MEDIA_TYPE      VARCHAR(500),
                REG_CREATOR         VARCHAR(31) NOT NULL,
                REG_CREATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                REG_LAST_UPDATOR    VARCHAR(31),
                REG_LAST_UPDATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                REG_DESCRIPTION     VARCHAR(1000),
                REG_CONTENT_ID      INTEGER,
                REG_DELETED         SMALLINT,
                REG_TENANT_ID INTEGER DEFAULT 0,
                REG_UUID VARCHAR(100) NOT NULL,
                CONSTRAINT PK_REG_RESOURCE_HISTORY PRIMARY KEY(REG_VERSION, REG_TENANT_ID)
    )ENGINE INNODB;
    ALTER TABLE REG_RESOURCE_HISTORY ADD CONSTRAINT REG_RESOURCE_HIST_FK_BY_PATHID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    ALTER TABLE REG_RESOURCE_HISTORY ADD CONSTRAINT REG_RESOURCE_HIST_FK_BY_CONTENT_ID FOREIGN KEY (REG_CONTENT_ID, REG_TENANT_ID) REFERENCES REG_CONTENT_HISTORY (REG_CONTENT_ID, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_HISTORY_IND_BY_NAME USING HASH ON REG_RESOURCE_HISTORY(REG_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_HISTORY_IND_BY_PATH_ID_NAME USING HASH ON REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_COMMENT (
                REG_ID        INTEGER NOT NULL AUTO_INCREMENT,
                REG_COMMENT_TEXT      VARCHAR(500) NOT NULL,
                REG_USER_ID           VARCHAR(31) NOT NULL,
                REG_COMMENTED_TIME    TIMESTAMP NOT NULL,
                REG_TENANT_ID INTEGER DEFAULT 0,
                CONSTRAINT PK_REG_COMMENT PRIMARY KEY(REG_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_COMMENT (
                REG_COMMENT_ID          INTEGER NOT NULL,
                REG_VERSION             INTEGER,
                REG_PATH_ID             INTEGER,
                REG_RESOURCE_NAME       VARCHAR(256),
                REG_TENANT_ID INTEGER DEFAULT 0
    )ENGINE INNODB;
    ALTER TABLE REG_RESOURCE_COMMENT ADD CONSTRAINT REG_RESOURCE_COMMENT_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    ALTER TABLE REG_RESOURCE_COMMENT ADD CONSTRAINT REG_RESOURCE_COMMENT_FK_BY_COMMENT_ID FOREIGN KEY (REG_COMMENT_ID, REG_TENANT_ID) REFERENCES REG_COMMENT (REG_ID, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_COMMENT_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_COMMENT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_COMMENT_IND_BY_VERSION USING HASH ON REG_RESOURCE_COMMENT(REG_VERSION, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_RATING (
                REG_ID     INTEGER NOT NULL AUTO_INCREMENT,
                REG_RATING        INTEGER NOT NULL,
                REG_USER_ID       VARCHAR(31) NOT NULL,
                REG_RATED_TIME    TIMESTAMP NOT NULL,
                REG_TENANT_ID INTEGER DEFAULT 0,
                CONSTRAINT PK_REG_RATING PRIMARY KEY(REG_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_RATING (
                REG_RATING_ID           INTEGER NOT NULL,
                REG_VERSION             INTEGER,
                REG_PATH_ID             INTEGER,
                REG_RESOURCE_NAME       VARCHAR(256),
                REG_TENANT_ID INTEGER DEFAULT 0
    )ENGINE INNODB;
    ALTER TABLE REG_RESOURCE_RATING ADD CONSTRAINT REG_RESOURCE_RATING_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    ALTER TABLE REG_RESOURCE_RATING ADD CONSTRAINT REG_RESOURCE_RATING_FK_BY_RATING_ID FOREIGN KEY (REG_RATING_ID, REG_TENANT_ID) REFERENCES REG_RATING (REG_ID, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_RATING_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_RATING(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_RATING_IND_BY_VERSION USING HASH ON REG_RESOURCE_RATING(REG_VERSION, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_TAG (
                REG_ID         INTEGER NOT NULL AUTO_INCREMENT,
                REG_TAG_NAME       VARCHAR(500) NOT NULL,
                REG_USER_ID        VARCHAR(31) NOT NULL,
                REG_TAGGED_TIME    TIMESTAMP NOT NULL,
                REG_TENANT_ID INTEGER DEFAULT 0,
                CONSTRAINT PK_REG_TAG PRIMARY KEY(REG_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_TAG (
                REG_TAG_ID              INTEGER NOT NULL,
                REG_VERSION             INTEGER,
                REG_PATH_ID             INTEGER,
                REG_RESOURCE_NAME       VARCHAR(256),
                REG_TENANT_ID INTEGER DEFAULT 0
    )ENGINE INNODB;
    ALTER TABLE REG_RESOURCE_TAG ADD CONSTRAINT REG_RESOURCE_TAG_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    ALTER TABLE REG_RESOURCE_TAG ADD CONSTRAINT REG_RESOURCE_TAG_FK_BY_TAG_ID FOREIGN KEY (REG_TAG_ID, REG_TENANT_ID) REFERENCES REG_TAG (REG_ID, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_TAG_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_TAG(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_TAG_IND_BY_VERSION USING HASH ON REG_RESOURCE_TAG(REG_VERSION, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_PROPERTY (
                REG_ID         INTEGER NOT NULL AUTO_INCREMENT,
                REG_NAME       VARCHAR(100) NOT NULL,
                REG_VALUE        VARCHAR(1000),
                REG_TENANT_ID INTEGER DEFAULT 0,
                CONSTRAINT PK_REG_PROPERTY PRIMARY KEY(REG_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_PROPERTY (
                REG_PROPERTY_ID         INTEGER NOT NULL,
                REG_VERSION             INTEGER,
                REG_PATH_ID             INTEGER,
                REG_RESOURCE_NAME       VARCHAR(256),
                REG_TENANT_ID INTEGER DEFAULT 0
    )ENGINE INNODB;
    ALTER TABLE REG_RESOURCE_PROPERTY ADD CONSTRAINT REG_RESOURCE_PROPERTY_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    ALTER TABLE REG_RESOURCE_PROPERTY ADD CONSTRAINT REG_RESOURCE_PROPERTY_FK_BY_TAG_ID FOREIGN KEY (REG_PROPERTY_ID, REG_TENANT_ID) REFERENCES REG_PROPERTY (REG_ID, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_PROPERTY_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_PROPERTY(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
    CREATE INDEX REG_RESOURCE_PROPERTY_IND_BY_VERSION USING HASH ON REG_RESOURCE_PROPERTY(REG_VERSION, REG_TENANT_ID);
    CREATE TABLE IF NOT EXISTS REG_ASSOCIATION (
                REG_ASSOCIATION_ID INTEGER AUTO_INCREMENT,
                REG_SOURCEPATH VARCHAR (750) NOT NULL,
                REG_TARGETPATH VARCHAR (750) NOT NULL,
                REG_ASSOCIATION_TYPE VARCHAR (2000) NOT NULL,
                REG_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (REG_ASSOCIATION_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS REG_SNAPSHOT (
                REG_SNAPSHOT_ID     INTEGER NOT NULL AUTO_INCREMENT,
                REG_PATH_ID            INTEGER NOT NULL,
                REG_RESOURCE_NAME      VARCHAR(255),
                REG_RESOURCE_VIDS     LONGBLOB NOT NULL,
                REG_TENANT_ID INTEGER DEFAULT 0,
                CONSTRAINT PK_REG_SNAPSHOT PRIMARY KEY(REG_SNAPSHOT_ID, REG_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX REG_SNAPSHOT_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_SNAPSHOT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
    ALTER TABLE REG_SNAPSHOT ADD CONSTRAINT REG_SNAPSHOT_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
    CREATE TABLE UM_TENANT (
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DOMAIN_NAME VARCHAR(255) NOT NULL,
                UM_EMAIL VARCHAR(255),
                UM_ACTIVE BOOLEAN DEFAULT FALSE,
                UM_CREATED_DATE TIMESTAMP NOT NULL,
                UM_USER_CONFIG LONGBLOB,
                PRIMARY KEY (UM_ID),
                UNIQUE(UM_DOMAIN_NAME)
    )ENGINE INNODB;
    CREATE TABLE UM_DOMAIN(
                UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DOMAIN_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME
                        ON UM_TENANT (UM_DOMAIN_NAME);
    CREATE TABLE UM_USER (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,
                 UM_SALT_VALUE VARCHAR(31),
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SYSTEM_USER (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,
                 UM_SALT_VALUE VARCHAR(31),
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_ROLE (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
            UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_ROLE_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_MODULE(
        UM_ID INTEGER  NOT NULL AUTO_INCREMENT,
        UM_MODULE_NAME VARCHAR(100),
        UNIQUE(UM_MODULE_NAME),
        PRIMARY KEY(UM_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_MODULE_ACTIONS(
        UM_ACTION VARCHAR(255) NOT NULL,
        UM_MODULE_ID INTEGER NOT NULL,
        PRIMARY KEY(UM_ACTION, UM_MODULE_ID),
        FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE UM_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_RESOURCE_ID VARCHAR(255) NOT NULL,
                 UM_ACTION VARCHAR(255) NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
            UM_MODULE_ID INTEGER DEFAULT 0,
                       UNIQUE(UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);
    CREATE TABLE UM_ROLE_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_PERMISSION_ID INTEGER NOT NULL,
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,
                 UM_IS_ALLOWED SMALLINT NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
             UM_DOMAIN_ID INTEGER,
                 UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),
             FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
             FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    -- REMOVED UNIQUE (UM_PERMISSION_ID, UM_ROLE_ID)
    CREATE TABLE UM_USER_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_PERMISSION_ID INTEGER NOT NULL,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_IS_ALLOWED SMALLINT NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    -- REMOVED UNIQUE (UM_PERMISSION_ID, UM_USER_ID)
    CREATE TABLE UM_USER_ROLE (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_ROLE_ID INTEGER NOT NULL,
                 UM_USER_ID INTEGER NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),
                 FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID),
                 FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SHARED_USER_ROLE(
        UM_ROLE_ID INTEGER NOT NULL,
        UM_USER_ID INTEGER NOT NULL,
        UM_USER_TENANT_ID INTEGER NOT NULL,
        UM_ROLE_TENANT_ID INTEGER NOT NULL,
        UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),
        FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,
        FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE UM_ACCOUNT_MAPPING(
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,
        UM_USER_NAME VARCHAR(255) NOT NULL,
        UM_TENANT_ID INTEGER NOT NULL,
        UM_USER_STORE_DOMAIN VARCHAR(100),
        UM_ACC_LINK_ID INTEGER NOT NULL,
        UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),
        FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,
        PRIMARY KEY (UM_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_ATTRIBUTE (
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ATTR_NAME VARCHAR(255) NOT NULL,
                UM_ATTR_VALUE VARCHAR(1024),
                UM_PROFILE_ID VARCHAR(255),
                UM_USER_ID INTEGER,
                UM_TENANT_ID INTEGER DEFAULT 0,
                FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX UM_USER_ID_INDEX ON UM_USER_ATTRIBUTE(UM_USER_ID);
    CREATE TABLE UM_DIALECT(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_URI VARCHAR(255) NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE(UM_DIALECT_URI, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_CLAIM(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_ID INTEGER NOT NULL,
                UM_CLAIM_URI VARCHAR(255) NOT NULL,
                UM_DISPLAY_TAG VARCHAR(255),
                UM_DESCRIPTION VARCHAR(255),
                UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),
                UM_MAPPED_ATTRIBUTE VARCHAR(255),
                UM_REG_EX VARCHAR(255),
                UM_SUPPORTED SMALLINT,
                UM_REQUIRED SMALLINT,
                UM_DISPLAY_ORDER INTEGER,
            UM_CHECKED_ATTRIBUTE SMALLINT,
                UM_READ_ONLY SMALLINT,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN),
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_PROFILE_CONFIG(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_ID INTEGER NOT NULL,
                UM_PROFILE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS UM_CLAIM_BEHAVIOR(
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,
        UM_PROFILE_ID INTEGER,
        UM_CLAIM_ID INTEGER,
        UM_BEHAVIOUR SMALLINT,
        UM_TENANT_ID INTEGER DEFAULT 0,
        FOREIGN KEY(UM_PROFILE_ID, UM_TENANT_ID) REFERENCES UM_PROFILE_CONFIG(UM_ID,UM_TENANT_ID),
        FOREIGN KEY(UM_CLAIM_ID, UM_TENANT_ID) REFERENCES UM_CLAIM(UM_ID,UM_TENANT_ID),
        PRIMARY KEY(UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ROLE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_USER_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255),
                UM_ROLE_ID INTEGER NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
            UM_DOMAIN_ID INTEGER,
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
            FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SYSTEM_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ROLE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX SYSTEM_ROLE_IND_BY_RN_TI ON UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID);
    CREATE TABLE UM_SYSTEM_USER_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255),
                UM_ROLE_ID INTEGER NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_REMEMBER_ME(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255) NOT NULL,
                UM_COOKIE_VALUE VARCHAR(1024),
                UM_CREATED_TIME TIMESTAMP,
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    USE WSO2AM_APIMGT_DB;
    -- Start of IDENTITY Tables--
    CREATE TABLE IF NOT EXISTS IDN_BASE_TABLE (
                PRODUCT_NAME VARCHAR(20),
                PRIMARY KEY (PRODUCT_NAME)
    )ENGINE INNODB;
    INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');
    CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                CONSUMER_KEY VARCHAR(255),
                CONSUMER_SECRET VARCHAR(2048),
                USERNAME VARCHAR(255),
                TENANT_ID INTEGER DEFAULT 0,
                USER_DOMAIN VARCHAR(50),
                APP_NAME VARCHAR(255),
                OAUTH_VERSION VARCHAR(128),
                CALLBACK_URL VARCHAR(1024),
                GRANT_TYPES VARCHAR (1024),
                PKCE_MANDATORY CHAR(1) DEFAULT '0',
                PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',
                APP_STATE VARCHAR (25) DEFAULT 'ACTIVE',
                USER_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,
                APP_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,
                REFRESH_TOKEN_EXPIRE_TIME BIGINT DEFAULT 84600,
                ID_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,
                CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_VALIDATORS (
        APP_ID INTEGER NOT NULL,
        SCOPE_VALIDATOR VARCHAR (128) NOT NULL,
        PRIMARY KEY (APP_ID,SCOPE_VALIDATOR),
        FOREIGN KEY (APP_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_REQUEST_TOKEN (
                REQUEST_TOKEN VARCHAR(255),
                REQUEST_TOKEN_SECRET VARCHAR(512),
                CONSUMER_KEY_ID INTEGER,
                CALLBACK_URL VARCHAR(1024),
                SCOPE VARCHAR(2048),
                AUTHORIZED VARCHAR(128),
                OAUTH_VERIFIER VARCHAR(512),
                AUTHZ_USER VARCHAR(512),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (REQUEST_TOKEN),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_ACCESS_TOKEN (
                ACCESS_TOKEN VARCHAR(255),
                ACCESS_TOKEN_SECRET VARCHAR(512),
                CONSUMER_KEY_ID INTEGER,
                SCOPE VARCHAR(2048),
                AUTHZ_USER VARCHAR(512),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ACCESS_TOKEN),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN (
                TOKEN_ID VARCHAR (255),
                ACCESS_TOKEN VARCHAR(2048),
                REFRESH_TOKEN VARCHAR(2048),
                CONSUMER_KEY_ID INTEGER,
                AUTHZ_USER VARCHAR (100),
                TENANT_ID INTEGER,
                USER_DOMAIN VARCHAR(50),
                USER_TYPE VARCHAR (25),
                GRANT_TYPE VARCHAR (50),
                TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                VALIDITY_PERIOD BIGINT,
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
                TOKEN_SCOPE_HASH VARCHAR(32),
                TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',
                TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',
                SUBJECT_IDENTIFIER VARCHAR(255),
                ACCESS_TOKEN_HASH VARCHAR(512),
                REFRESH_TOKEN_HASH VARCHAR(512),
                PRIMARY KEY (TOKEN_ID),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
                CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,
                                               TOKEN_STATE,TOKEN_STATE_ID)
    )ENGINE INNODB;
    CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
    CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);
    CREATE INDEX IDX_ATH ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN_HASH);
    CREATE INDEX IDX_AT_TI_UD ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, TENANT_ID, TOKEN_STATE, USER_DOMAIN);
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_AUDIT (
                TOKEN_ID VARCHAR (255),
                ACCESS_TOKEN VARCHAR(2048),
                REFRESH_TOKEN VARCHAR(2048),
                CONSUMER_KEY_ID INTEGER,
                AUTHZ_USER VARCHAR (100),
                TENANT_ID INTEGER,
                USER_DOMAIN VARCHAR(50),
                USER_TYPE VARCHAR (25),
                GRANT_TYPE VARCHAR (50),
                TIME_CREATED TIMESTAMP NULL,
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NULL,
                VALIDITY_PERIOD BIGINT,
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
                TOKEN_SCOPE_HASH VARCHAR(32),
                TOKEN_STATE VARCHAR(25),
                TOKEN_STATE_ID VARCHAR (128) ,
                SUBJECT_IDENTIFIER VARCHAR(255),
                ACCESS_TOKEN_HASH VARCHAR(512),
                REFRESH_TOKEN_HASH VARCHAR(512),
                INVALIDATED_TIME TIMESTAMP NULL
    );
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE (
                CODE_ID VARCHAR (255),
                AUTHORIZATION_CODE VARCHAR(2048),
                CONSUMER_KEY_ID INTEGER,
                CALLBACK_URL VARCHAR(1024),
                SCOPE VARCHAR(2048),
                AUTHZ_USER VARCHAR (100),
                TENANT_ID INTEGER,
                USER_DOMAIN VARCHAR(50),
                TIME_CREATED TIMESTAMP,
                VALIDITY_PERIOD BIGINT,
                STATE VARCHAR (25) DEFAULT 'ACTIVE',
                TOKEN_ID VARCHAR(255),
                SUBJECT_IDENTIFIER VARCHAR(255),
                PKCE_CODE_CHALLENGE VARCHAR(255),
                PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),
                AUTHORIZATION_CODE_HASH VARCHAR(512),
                PRIMARY KEY (CODE_ID),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE INDEX IDX_AUTHORIZATION_CODE_HASH ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHORIZATION_CODE_HASH,CONSUMER_KEY_ID);
    CREATE INDEX IDX_AUTHORIZATION_CODE_AU_TI ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHZ_USER,TENANT_ID, USER_DOMAIN, STATE);
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
                TOKEN_ID VARCHAR (255),
                TOKEN_SCOPE VARCHAR (60),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
                FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE (
                SCOPE_ID INTEGER NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(255) NOT NULL,
                DISPLAY_NAME VARCHAR(255) NOT NULL,
                DESCRIPTION VARCHAR(512),
                TENANT_ID INTEGER NOT NULL DEFAULT -1,
                PRIMARY KEY (SCOPE_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_BINDING (
                SCOPE_ID INTEGER NOT NULL,
                SCOPE_BINDING VARCHAR(255),
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE(SCOPE_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_RESOURCE_SCOPE (
                RESOURCE_PATH VARCHAR(255) NOT NULL,
                SCOPE_ID INTEGER NOT NULL,
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (RESOURCE_PATH),
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_SCIM_GROUP (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                ROLE_NAME VARCHAR(255) NOT NULL,
                ATTR_NAME VARCHAR(1024) NOT NULL,
                ATTR_VALUE VARCHAR(1024),
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME);
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN_AN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME, ATTR_NAME);
    CREATE TABLE IF NOT EXISTS IDN_OPENID_REMEMBER_ME (
                USER_NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT 0,
                COOKIE_VALUE VARCHAR(1024),
                CREATED_TIME TIMESTAMP,
                PRIMARY KEY (USER_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OPENID_USER_RPS (
                USER_NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT 0,
                RP_URL VARCHAR(255) NOT NULL,
                TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
                LAST_VISIT DATE NOT NULL,
                VISIT_COUNT INTEGER DEFAULT 0,
                DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
                PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OPENID_ASSOCIATIONS (
                HANDLE VARCHAR(255) NOT NULL,
                ASSOC_TYPE VARCHAR(255) NOT NULL,
                EXPIRE_IN TIMESTAMP NOT NULL,
                MAC_KEY VARCHAR(255) NOT NULL,
                ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (HANDLE)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_STS_STORE (
                ID INTEGER AUTO_INCREMENT,
                TOKEN_ID VARCHAR(255) NOT NULL,
                TOKEN_CONTENT BLOB(1024) NOT NULL,
                CREATE_DATE TIMESTAMP NOT NULL,
                EXPIRE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                STATE INTEGER DEFAULT 0,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_USER_DATA (
                TENANT_ID INTEGER DEFAULT -1234,
                USER_NAME VARCHAR(255) NOT NULL,
                DATA_KEY VARCHAR(255) NOT NULL,
                DATA_VALUE VARCHAR(2048),
                PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_META_DATA (
                USER_NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1234,
                METADATA_TYPE VARCHAR(255) NOT NULL,
                METADATA VARCHAR(255) NOT NULL,
                VALID VARCHAR(255) NOT NULL,
                PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (
                SESSION_ID VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(255) NOT NULL,
                CREATED_TIME VARCHAR(255) NOT NULL,
                LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (SESSION_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_AUTH_SESSION_STORE (
                SESSION_ID VARCHAR (100) NOT NULL,
                SESSION_TYPE VARCHAR(100) NOT NULL,
                OPERATION VARCHAR(10) NOT NULL,
                SESSION_OBJECT BLOB,
                TIME_CREATED BIGINT,
                TENANT_ID INTEGER DEFAULT -1,
                EXPIRY_TIME BIGINT,
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
    )ENGINE INNODB;
    CREATE INDEX IDX_IDN_AUTH_SESSION_TIME ON IDN_AUTH_SESSION_STORE (TIME_CREATED);
    CREATE TABLE IF NOT EXISTS IDN_AUTH_TEMP_SESSION_STORE (
                SESSION_ID VARCHAR (100) NOT NULL,
                SESSION_TYPE VARCHAR(100) NOT NULL,
                OPERATION VARCHAR(10) NOT NULL,
                SESSION_OBJECT BLOB,
                TIME_CREATED BIGINT,
                TENANT_ID INTEGER DEFAULT -1,
                EXPIRY_TIME BIGINT,
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
    )ENGINE INNODB;
    CREATE INDEX IDX_IDN_AUTH_TMP_SESSION_TIME ON IDN_AUTH_TEMP_SESSION_STORE (TIME_CREATED);
    CREATE TABLE IF NOT EXISTS SP_APP (
            ID INTEGER NOT NULL AUTO_INCREMENT,
            TENANT_ID INTEGER NOT NULL,
                APP_NAME VARCHAR (255) NOT NULL ,
                USER_STORE VARCHAR (255) NOT NULL,
            USERNAME VARCHAR (255) NOT NULL ,
            DESCRIPTION VARCHAR (1024),
                ROLE_CLAIM VARCHAR (512),
            AUTH_TYPE VARCHAR (255) NOT NULL,
                PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),
                IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',
                IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',
                IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',
            IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
            IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
            ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0',
                SUBJECT_CLAIM_URI VARCHAR (512),
                IS_SAAS_APP CHAR(1) DEFAULT '0',
                IS_DUMB_MODE CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID);
    CREATE TABLE IF NOT EXISTS SP_METADATA (
                ID INTEGER AUTO_INCREMENT,
                SP_ID INTEGER,
                NAME VARCHAR(255) NOT NULL,
                VALUE VARCHAR(255) NOT NULL,
                DISPLAY_NAME VARCHAR(255),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ID),
                CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),
                FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS SP_INBOUND_AUTH (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                INBOUND_AUTH_KEY VARCHAR (255),
                INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,
                INBOUND_CONFIG_TYPE VARCHAR (255) NOT NULL,
                PROP_NAME VARCHAR (255),
                PROP_VALUE VARCHAR (1024) ,
                APP_ID INTEGER NOT NULL,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_AUTH_STEP (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                STEP_ORDER INTEGER DEFAULT 1,
                APP_ID INTEGER NOT NULL ,
                IS_SUBJECT_STEP CHAR(1) DEFAULT '0',
                IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_FEDERATED_IDP (
                ID INTEGER NOT NULL,
                TENANT_ID INTEGER NOT NULL,
                AUTHENTICATOR_ID INTEGER NOT NULL,
                PRIMARY KEY (ID, AUTHENTICATOR_ID)
    )ENGINE INNODB;
    ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_CLAIM_DIALECT (
            ID INTEGER NOT NULL AUTO_INCREMENT,
            TENANT_ID INTEGER NOT NULL,
            SP_DIALECT VARCHAR (512) NOT NULL,
            APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));
    ALTER TABLE SP_CLAIM_DIALECT ADD CONSTRAINT DIALECTID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_CLAIM_MAPPING (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                IDP_CLAIM VARCHAR (512) NOT NULL ,
                SP_CLAIM VARCHAR (512) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                IS_REQUESTED VARCHAR(128) DEFAULT '0',
            IS_MANDATORY VARCHAR(128) DEFAULT '0',
                DEFAULT_VALUE VARCHAR(255),
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_ROLE_MAPPING (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                IDP_ROLE VARCHAR (255) NOT NULL ,
                SP_ROLE VARCHAR (255) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_REQ_PATH_AUTHENTICATOR (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_PROVISIONING_CONNECTOR (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                IDP_NAME VARCHAR (255) NOT NULL ,
                CONNECTOR_NAME VARCHAR (255) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',
                BLOCKING CHAR(1) NOT NULL DEFAULT '0',
                RULE_ENABLED CHAR(1) NOT NULL DEFAULT '0',
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE SP_AUTH_SCRIPT (
      ID         INTEGER AUTO_INCREMENT NOT NULL,
      TENANT_ID  INTEGER                NOT NULL,
      APP_ID     INTEGER                NOT NULL,
      TYPE       VARCHAR(255)           NOT NULL,
      CONTENT    BLOB    DEFAULT NULL,
      IS_ENABLED CHAR(1) NOT NULL DEFAULT '0',
      PRIMARY KEY (ID));
    CREATE TABLE IF NOT EXISTS SP_TEMPLATE (
      ID         INTEGER AUTO_INCREMENT NOT NULL,
      TENANT_ID  INTEGER                NOT NULL,
      NAME VARCHAR(255) NOT NULL,
      DESCRIPTION VARCHAR(1023),
      CONTENT BLOB DEFAULT NULL,
      PRIMARY KEY (ID),
      CONSTRAINT SP_TEMPLATE_CONSTRAINT UNIQUE (TENANT_ID, NAME));
    CREATE INDEX IDX_SP_TEMPLATE ON SP_TEMPLATE (TENANT_ID, NAME);
    CREATE TABLE IF NOT EXISTS IDN_AUTH_WAIT_STATUS (
      ID              INTEGER AUTO_INCREMENT NOT NULL,
      TENANT_ID       INTEGER                NOT NULL,
      LONG_WAIT_KEY   VARCHAR(255)           NOT NULL,
      WAIT_STATUS     CHAR(1) NOT NULL DEFAULT '1',
      TIME_CREATED    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      EXPIRE_TIME     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (ID),
      CONSTRAINT IDN_AUTH_WAIT_STATUS_KEY UNIQUE (LONG_WAIT_KEY));
    CREATE TABLE IF NOT EXISTS IDP (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                NAME VARCHAR(254) NOT NULL,
                IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',
                IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',
                HOME_REALM_ID VARCHAR(254),
                IMAGE MEDIUMBLOB,
                CERTIFICATE BLOB,
                ALIAS VARCHAR(254),
                INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',
                INBOUND_PROV_USER_STORE_ID VARCHAR(254),
                USER_CLAIM_URI VARCHAR(254),
                ROLE_CLAIM_URI VARCHAR(254),
                DESCRIPTION VARCHAR (1024),
                DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),
                DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),
                PROVISIONING_ROLE VARCHAR(128),
                IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',
                IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',
                DISPLAY_NAME VARCHAR(255),
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, NAME)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_ROLE (
                ID INTEGER AUTO_INCREMENT,
                IDP_ID INTEGER,
                TENANT_ID INTEGER,
                ROLE VARCHAR(254),
                PRIMARY KEY (ID),
                UNIQUE (IDP_ID, ROLE),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_ROLE_MAPPING (
                ID INTEGER AUTO_INCREMENT,
                IDP_ROLE_ID INTEGER,
                TENANT_ID INTEGER,
                USER_STORE_ID VARCHAR (253),
                LOCAL_ROLE VARCHAR(253),
                PRIMARY KEY (ID),
                UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),
                FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_CLAIM (
                ID INTEGER AUTO_INCREMENT,
                IDP_ID INTEGER,
                TENANT_ID INTEGER,
                CLAIM VARCHAR(254),
                PRIMARY KEY (ID),
                UNIQUE (IDP_ID, CLAIM),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_CLAIM_MAPPING (
                ID INTEGER AUTO_INCREMENT,
                IDP_CLAIM_ID INTEGER,
                TENANT_ID INTEGER,
                LOCAL_CLAIM VARCHAR(253),
                DEFAULT_VALUE VARCHAR(255),
                IS_REQUESTED VARCHAR(128) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),
                FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                IDP_ID INTEGER,
                NAME VARCHAR(255) NOT NULL,
                IS_ENABLED CHAR (1) DEFAULT '1',
                DISPLAY_NAME VARCHAR(255),
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, IDP_ID, NAME),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_METADATA (
                ID INTEGER AUTO_INCREMENT,
                IDP_ID INTEGER,
                NAME VARCHAR(255) NOT NULL,
                VALUE VARCHAR(255) NOT NULL,
                DISPLAY_NAME VARCHAR(255),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ID),
                CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR_PROPERTY (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                AUTHENTICATOR_ID INTEGER,
                PROPERTY_KEY VARCHAR(255) NOT NULL,
                PROPERTY_VALUE VARCHAR(2047),
                IS_SECRET CHAR (1) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),
                FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_CONFIG (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                IDP_ID INTEGER,
                PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,
                IS_ENABLED CHAR (1) DEFAULT '0',
                IS_BLOCKING CHAR (1) DEFAULT '0',
                IS_RULES_ENABLED CHAR (1) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_PROV_CONFIG_PROPERTY (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                PROVISIONING_CONFIG_ID INTEGER,
                PROPERTY_KEY VARCHAR(255) NOT NULL,
                PROPERTY_VALUE VARCHAR(2048),
                PROPERTY_BLOB_VALUE BLOB,
                PROPERTY_TYPE CHAR(32) NOT NULL,
                IS_SECRET CHAR (1) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_ENTITY (
                ID INTEGER AUTO_INCREMENT,
                PROVISIONING_CONFIG_ID INTEGER,
                ENTITY_TYPE VARCHAR(255) NOT NULL,
                ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,
                ENTITY_NAME VARCHAR(255) NOT NULL,
                ENTITY_VALUE VARCHAR(255),
                TENANT_ID INTEGER,
                ENTITY_LOCAL_ID VARCHAR(255),
                PRIMARY KEY (ID),
                UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),
                UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_LOCAL_CLAIM (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                IDP_ID INTEGER,
                CLAIM_URI VARCHAR(255) NOT NULL,
                DEFAULT_VALUE VARCHAR(255),
                IS_REQUESTED VARCHAR(128) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_ASSOCIATED_ID (
                ID INTEGER AUTO_INCREMENT,
                IDP_USER_ID VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1234,
                IDP_ID INTEGER NOT NULL,
                DOMAIN_NAME VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(255) NOT NULL,
                PRIMARY KEY (ID),
                UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_USER_ACCOUNT_ASSOCIATION (
                ASSOCIATION_KEY VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER,
                DOMAIN_NAME VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(255) NOT NULL,
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS FIDO_DEVICE_STORE (
                TENANT_ID INTEGER,
                DOMAIN_NAME VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(45) NOT NULL,
                TIME_REGISTERED TIMESTAMP,
                KEY_HANDLE VARCHAR(200) NOT NULL,
                DEVICE_DATA VARCHAR(2048) NOT NULL,
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE)
            )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_REQUEST (
        UUID VARCHAR (45),
        CREATED_BY VARCHAR (255),
        TENANT_ID INTEGER DEFAULT -1,
        OPERATION_TYPE VARCHAR (50),
        CREATED_AT TIMESTAMP,
        UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        STATUS VARCHAR (30),
        REQUEST BLOB,
        PRIMARY KEY (UUID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_BPS_PROFILE (
        PROFILE_NAME VARCHAR(45),
        HOST_URL_MANAGER VARCHAR(255),
        HOST_URL_WORKER VARCHAR(255),
        USERNAME VARCHAR(45),
        PASSWORD VARCHAR(1023),
        CALLBACK_HOST VARCHAR (45),
        CALLBACK_USERNAME VARCHAR (45),
        CALLBACK_PASSWORD VARCHAR (255),
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (PROFILE_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW(
        ID VARCHAR (45),
        WF_NAME VARCHAR (45),
        DESCRIPTION VARCHAR (255),
        TEMPLATE_ID VARCHAR (45),
        IMPL_ID VARCHAR (45),
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_ASSOCIATION(
        ID INTEGER NOT NULL AUTO_INCREMENT,
        ASSOC_NAME VARCHAR (45),
        EVENT_ID VARCHAR(45),
        ASSOC_CONDITION VARCHAR (2000),
        WORKFLOW_ID VARCHAR (45),
        IS_ENABLED CHAR (1) DEFAULT '1',
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY(ID),
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_CONFIG_PARAM(
        WORKFLOW_ID VARCHAR (45),
        PARAM_NAME VARCHAR (45),
        PARAM_VALUE VARCHAR (1000),
        PARAM_QNAME VARCHAR (45),
        PARAM_HOLDER VARCHAR (45),
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_REQUEST_ENTITY_RELATIONSHIP(
      REQUEST_ID VARCHAR (45),
      ENTITY_NAME VARCHAR (255),
      ENTITY_TYPE VARCHAR (50),
      TENANT_ID INTEGER DEFAULT -1,
      PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_REQUEST_RELATION(
      RELATIONSHIP_ID VARCHAR (45),
      WORKFLOW_ID VARCHAR (45),
      REQUEST_ID VARCHAR (45),
      UPDATED_AT TIMESTAMP,
      STATUS VARCHAR (30),
      TENANT_ID INTEGER DEFAULT -1,
      PRIMARY KEY (RELATIONSHIP_ID),
      FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_RECOVERY_DATA (
      USER_NAME VARCHAR(255) NOT NULL,
      USER_DOMAIN VARCHAR(127) NOT NULL,
      TENANT_ID INTEGER DEFAULT -1,
      CODE VARCHAR(255) NOT NULL,
      SCENARIO VARCHAR(255) NOT NULL,
      STEP VARCHAR(127) NOT NULL,
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      REMAINING_SETS VARCHAR(2500) DEFAULT NULL,
      PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),
      UNIQUE(CODE)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_PASSWORD_HISTORY_DATA (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      USER_NAME   VARCHAR(255) NOT NULL,
      USER_DOMAIN VARCHAR(127) NOT NULL,
      TENANT_ID   INTEGER DEFAULT -1,
      SALT_VALUE  VARCHAR(255),
      HASH        VARCHAR(255) NOT NULL,
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY(ID),
      UNIQUE (USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_DIALECT (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      DIALECT_URI VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      DIALECT_ID INTEGER,
      CLAIM_URI VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,
      CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPED_ATTRIBUTE (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      LOCAL_CLAIM_ID INTEGER,
      USER_STORE_DOMAIN_NAME VARCHAR (255) NOT NULL,
      ATTRIBUTE_NAME VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_PROPERTY (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      LOCAL_CLAIM_ID INTEGER,
      PROPERTY_NAME VARCHAR (255) NOT NULL,
      PROPERTY_VALUE VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPING (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      EXT_CLAIM_ID INTEGER NOT NULL,
      MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS  IDN_SAML2_ASSERTION_STORE (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      SAML2_ID  VARCHAR(255) ,
      SAML2_ISSUER  VARCHAR(255) ,
      SAML2_SUBJECT  VARCHAR(255) ,
      SAML2_SESSION_INDEX  VARCHAR(255) ,
      SAML2_AUTHN_CONTEXT_CLASS_REF  VARCHAR(255) ,
      SAML2_ASSERTION  VARCHAR(4096) ,
      PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IDN_SAML2_ARTIFACT_STORE (
      ID INT(11) NOT NULL AUTO_INCREMENT,
      SOURCE_ID VARCHAR(255) NOT NULL,
      MESSAGE_HANDLER VARCHAR(255) NOT NULL,
      AUTHN_REQ_DTO BLOB NOT NULL,
      SESSION_ID VARCHAR(255) NOT NULL,
      EXP_TIMESTAMP TIMESTAMP NOT NULL,
      INIT_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      ASSERTION_ID VARCHAR(255),
      PRIMARY KEY (`ID`)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_JTI (
      JWT_ID VARCHAR(255) NOT NULL,
      EXP_TIME TIMESTAMP NOT NULL ,
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
      PRIMARY KEY (JWT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS  IDN_OIDC_PROPERTY (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      TENANT_ID  INTEGER,
      CONSUMER_KEY  VARCHAR(255) ,
      PROPERTY_KEY  VARCHAR(255) NOT NULL,
      PROPERTY_VALUE  VARCHAR(2047) ,
      PRIMARY KEY (ID),
      FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_REFERENCE (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      CONSUMER_KEY_ID INTEGER ,
      CODE_ID VARCHAR(255) ,
      TOKEN_ID VARCHAR(255) ,
      SESSION_DATA_KEY VARCHAR(255),
      PRIMARY KEY (ID),
      FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
      FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE,
      FOREIGN KEY (CODE_ID) REFERENCES IDN_OAUTH2_AUTHORIZATION_CODE(CODE_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_CLAIMS (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      REQ_OBJECT_ID INTEGER,
      CLAIM_ATTRIBUTE VARCHAR(255) ,
      ESSENTIAL CHAR(1) NOT NULL DEFAULT '0' ,
      VALUE VARCHAR(255) ,
      IS_USERINFO CHAR(1) NOT NULL DEFAULT '0',
      PRIMARY KEY (ID),
      FOREIGN KEY (REQ_OBJECT_ID) REFERENCES IDN_OIDC_REQ_OBJECT_REFERENCE (ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJ_CLAIM_VALUES (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      REQ_OBJECT_CLAIMS_ID INTEGER ,
      CLAIM_VALUES VARCHAR(255) ,
      PRIMARY KEY (ID),
      FOREIGN KEY (REQ_OBJECT_CLAIMS_ID) REFERENCES  IDN_OIDC_REQ_OBJECT_CLAIMS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CERTIFICATE (
                 ID INTEGER NOT NULL AUTO_INCREMENT,
                 NAME VARCHAR(100),
                 CERTIFICATE_IN_PEM BLOB,
                 TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY(ID),
                 CONSTRAINT CERTIFICATE_UNIQUE_KEY UNIQUE (NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE_CLAIM_MAPPING (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                SCOPE_ID INTEGER,
                EXTERNAL_CLAIM_ID INTEGER,
                PRIMARY KEY (ID),
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OIDC_SCOPE(ID) ON DELETE CASCADE,
                FOREIGN KEY (EXTERNAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE INDEX IDX_AT_SI_ECI ON IDN_OIDC_SCOPE_CLAIM_MAPPING(SCOPE_ID, EXTERNAL_CLAIM_ID);
    CREATE TABLE CM_PII_CATEGORY (
      ID           INTEGER AUTO_INCREMENT,
      NAME         VARCHAR(255) NOT NULL,
      DESCRIPTION  VARCHAR(1023),
      DISPLAY_NAME VARCHAR(255),
      IS_SENSITIVE INTEGER      NOT NULL,
      TENANT_ID    INTEGER DEFAULT '-1234',
      UNIQUE KEY (NAME, TENANT_ID),
      PRIMARY KEY (ID)
    );
    CREATE TABLE CM_RECEIPT (
      CONSENT_RECEIPT_ID  VARCHAR(255) NOT NULL,
      VERSION             VARCHAR(255) NOT NULL,
      JURISDICTION        VARCHAR(255) NOT NULL,
      CONSENT_TIMESTAMP   TIMESTAMP    NOT NULL,
      COLLECTION_METHOD   VARCHAR(255) NOT NULL,
      LANGUAGE            VARCHAR(255) NOT NULL,
      PII_PRINCIPAL_ID    VARCHAR(255) NOT NULL,
      PRINCIPAL_TENANT_ID INTEGER DEFAULT '-1234',
      POLICY_URL          VARCHAR(255) NOT NULL,
      STATE               VARCHAR(255) NOT NULL,
      PII_CONTROLLER      VARCHAR(2048) NOT NULL,
      PRIMARY KEY (CONSENT_RECEIPT_ID)
    );
    CREATE TABLE CM_PURPOSE (
      ID            INTEGER AUTO_INCREMENT,
      NAME          VARCHAR(255) NOT NULL,
      DESCRIPTION   VARCHAR(1023),
      PURPOSE_GROUP VARCHAR(255) NOT NULL,
      GROUP_TYPE    VARCHAR(255) NOT NULL,
      TENANT_ID     INTEGER DEFAULT '-1234',
      UNIQUE KEY (NAME, TENANT_ID, PURPOSE_GROUP, GROUP_TYPE),
      PRIMARY KEY (ID)
    );
    CREATE TABLE CM_PURPOSE_CATEGORY (
      ID          INTEGER AUTO_INCREMENT,
      NAME        VARCHAR(255) NOT NULL,
      DESCRIPTION VARCHAR(1023),
      TENANT_ID   INTEGER DEFAULT '-1234',
      UNIQUE KEY (NAME, TENANT_ID),
      PRIMARY KEY (ID)
    );
    CREATE TABLE CM_RECEIPT_SP_ASSOC (
      ID                 INTEGER AUTO_INCREMENT,
      CONSENT_RECEIPT_ID VARCHAR(255) NOT NULL,
      SP_NAME            VARCHAR(255) NOT NULL,
      SP_DISPLAY_NAME    VARCHAR(255),
      SP_DESCRIPTION     VARCHAR(255),
      SP_TENANT_ID       INTEGER DEFAULT '-1234',
      UNIQUE KEY (CONSENT_RECEIPT_ID, SP_NAME, SP_TENANT_ID),
      PRIMARY KEY (ID)
    );
    CREATE TABLE CM_SP_PURPOSE_ASSOC (
      ID                     INTEGER AUTO_INCREMENT,
      RECEIPT_SP_ASSOC       INTEGER      NOT NULL,
      PURPOSE_ID             INTEGER      NOT NULL,
      CONSENT_TYPE           VARCHAR(255) NOT NULL,
      IS_PRIMARY_PURPOSE     INTEGER      NOT NULL,
      TERMINATION            VARCHAR(255) NOT NULL,
      THIRD_PARTY_DISCLOSURE INTEGER      NOT NULL,
      THIRD_PARTY_NAME       VARCHAR(255),
      UNIQUE KEY (RECEIPT_SP_ASSOC, PURPOSE_ID),
      PRIMARY KEY (ID)
    );
    CREATE TABLE CM_SP_PURPOSE_PURPOSE_CAT_ASSC (
      SP_PURPOSE_ASSOC_ID INTEGER NOT NULL,
      PURPOSE_CATEGORY_ID INTEGER NOT NULL,
      UNIQUE KEY (SP_PURPOSE_ASSOC_ID, PURPOSE_CATEGORY_ID)
    );
    CREATE TABLE CM_PURPOSE_PII_CAT_ASSOC (
      PURPOSE_ID         INTEGER NOT NULL,
      CM_PII_CATEGORY_ID INTEGER NOT NULL,
      IS_MANDATORY       INTEGER NOT NULL,
      UNIQUE KEY (PURPOSE_ID, CM_PII_CATEGORY_ID)
    );
    CREATE TABLE CM_SP_PURPOSE_PII_CAT_ASSOC (
      SP_PURPOSE_ASSOC_ID INTEGER NOT NULL,
      PII_CATEGORY_ID     INTEGER NOT NULL,
      VALIDITY            VARCHAR(1023),
      UNIQUE KEY (SP_PURPOSE_ASSOC_ID, PII_CATEGORY_ID)
    );
    CREATE TABLE CM_CONSENT_RECEIPT_PROPERTY (
      CONSENT_RECEIPT_ID VARCHAR(255)  NOT NULL,
      NAME               VARCHAR(255)  NOT NULL,
      VALUE              VARCHAR(1023) NOT NULL,
      UNIQUE KEY (CONSENT_RECEIPT_ID, NAME)
    );
    ALTER TABLE CM_RECEIPT_SP_ASSOC
      ADD CONSTRAINT CM_RECEIPT_SP_ASSOC_fk0 FOREIGN KEY (CONSENT_RECEIPT_ID) REFERENCES CM_RECEIPT (CONSENT_RECEIPT_ID);
    ALTER TABLE CM_SP_PURPOSE_ASSOC
      ADD CONSTRAINT CM_SP_PURPOSE_ASSOC_fk0 FOREIGN KEY (RECEIPT_SP_ASSOC) REFERENCES CM_RECEIPT_SP_ASSOC (ID);
    ALTER TABLE CM_SP_PURPOSE_ASSOC
      ADD CONSTRAINT CM_SP_PURPOSE_ASSOC_fk1 FOREIGN KEY (PURPOSE_ID) REFERENCES CM_PURPOSE (ID);
    ALTER TABLE CM_SP_PURPOSE_PURPOSE_CAT_ASSC
      ADD CONSTRAINT CM_SP_P_P_CAT_ASSOC_fk0 FOREIGN KEY (SP_PURPOSE_ASSOC_ID) REFERENCES CM_SP_PURPOSE_ASSOC (ID);
    ALTER TABLE CM_SP_PURPOSE_PURPOSE_CAT_ASSC
      ADD CONSTRAINT CM_SP_P_P_CAT_ASSOC_fk1 FOREIGN KEY (PURPOSE_CATEGORY_ID) REFERENCES CM_PURPOSE_CATEGORY (ID);
    ALTER TABLE CM_SP_PURPOSE_PII_CAT_ASSOC
      ADD CONSTRAINT CM_SP_P_PII_CAT_ASSOC_fk0 FOREIGN KEY (SP_PURPOSE_ASSOC_ID) REFERENCES CM_SP_PURPOSE_ASSOC (ID);
    ALTER TABLE CM_SP_PURPOSE_PII_CAT_ASSOC
      ADD CONSTRAINT CM_SP_P_PII_CAT_ASSOC_fk1 FOREIGN KEY (PII_CATEGORY_ID) REFERENCES CM_PII_CATEGORY (ID);
    ALTER TABLE CM_CONSENT_RECEIPT_PROPERTY
      ADD CONSTRAINT CM_CONSENT_RECEIPT_PRT_fk0 FOREIGN KEY (CONSENT_RECEIPT_ID) REFERENCES CM_RECEIPT (CONSENT_RECEIPT_ID);
    INSERT INTO CM_PURPOSE (NAME, DESCRIPTION, PURPOSE_GROUP, GROUP_TYPE, TENANT_ID) VALUES ('DEFAULT', 'For core functionalities of the product', 'DEFAULT', 'SP', '-1234');
    INSERT INTO CM_PURPOSE_CATEGORY (NAME, DESCRIPTION, TENANT_ID) VALUES ('DEFAULT','For core functionalities of the product', '-1234');
    CREATE TABLE IF NOT EXISTS AM_SUBSCRIBER (
        SUBSCRIBER_ID INTEGER AUTO_INCREMENT,
        USER_ID VARCHAR(255) NOT NULL,
        TENANT_ID INTEGER NOT NULL,
        EMAIL_ADDRESS VARCHAR(256) NULL,
        DATE_SUBSCRIBED TIMESTAMP NOT NULL,
        PRIMARY KEY (SUBSCRIBER_ID),
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (TENANT_ID,USER_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_APPLICATION (
        APPLICATION_ID INTEGER AUTO_INCREMENT,
        NAME VARCHAR(100),
        SUBSCRIBER_ID INTEGER,
        APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
        CALLBACK_URL VARCHAR(512),
        DESCRIPTION VARCHAR(512),
        APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
        GROUP_ID VARCHAR(100),
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UUID VARCHAR(256),
        TOKEN_TYPE VARCHAR(10),
        FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY(APPLICATION_ID),
        UNIQUE (NAME,SUBSCRIBER_ID),
        UNIQUE (UUID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_API (
        API_ID INTEGER AUTO_INCREMENT,
        API_PROVIDER VARCHAR(200),
        API_NAME VARCHAR(200),
        API_VERSION VARCHAR(30),
        CONTEXT VARCHAR(256),
        CONTEXT_TEMPLATE VARCHAR(256),
        API_TIER VARCHAR(256),
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(API_ID),
        UNIQUE (API_PROVIDER,API_NAME,API_VERSION)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_API_URL_MAPPING (
        URL_MAPPING_ID INTEGER AUTO_INCREMENT,
        API_ID INTEGER NOT NULL,
        HTTP_METHOD VARCHAR(20) NULL,
        AUTH_SCHEME VARCHAR(50) NULL,
        URL_PATTERN VARCHAR(512) NULL,
        THROTTLING_TIER varchar(512) DEFAULT NULL,
        MEDIATION_SCRIPT BLOB,
        PRIMARY KEY (URL_MAPPING_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION (
        SUBSCRIPTION_ID INTEGER AUTO_INCREMENT,
        TIER_ID VARCHAR(50),
        API_ID INTEGER,
        LAST_ACCESSED TIMESTAMP NULL,
        APPLICATION_ID INTEGER,
        SUB_STATUS VARCHAR(50),
        SUBS_CREATE_STATE VARCHAR(50) DEFAULT 'SUBSCRIBE',
        CREATED_BY VARCHAR(100),
        CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UPDATED_BY VARCHAR(100),
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UUID VARCHAR(256),
        FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY (SUBSCRIPTION_ID),
        UNIQUE (UUID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION_KEY_MAPPING (
        SUBSCRIPTION_ID INTEGER,
        ACCESS_TOKEN VARCHAR(512),
        KEY_TYPE VARCHAR(512) NOT NULL,
        FOREIGN KEY(SUBSCRIPTION_ID) REFERENCES AM_SUBSCRIPTION(SUBSCRIPTION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY(SUBSCRIPTION_ID,ACCESS_TOKEN)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_KEY_MAPPING (
        APPLICATION_ID INTEGER,
        CONSUMER_KEY VARCHAR(255),
        KEY_TYPE VARCHAR(512) NOT NULL,
        STATE VARCHAR(30) NOT NULL,
        CREATE_MODE VARCHAR(30) DEFAULT 'CREATED',
        FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY(APPLICATION_ID,KEY_TYPE)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_API_LC_EVENT (
        EVENT_ID INTEGER AUTO_INCREMENT,
        API_ID INTEGER NOT NULL,
        PREVIOUS_STATE VARCHAR(50),
        NEW_STATE VARCHAR(50) NOT NULL,
        USER_ID VARCHAR(255) NOT NULL,
        TENANT_ID INTEGER NOT NULL,
        EVENT_DATE TIMESTAMP NOT NULL,
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY (EVENT_ID)
    )ENGINE INNODB;
    CREATE TABLE AM_APP_KEY_DOMAIN_MAPPING (
        CONSUMER_KEY VARCHAR(255),
        AUTHZ_DOMAIN VARCHAR(255) DEFAULT 'ALL',
        PRIMARY KEY (CONSUMER_KEY,AUTHZ_DOMAIN)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_API_COMMENTS (
        COMMENT_ID INTEGER AUTO_INCREMENT,
        COMMENT_TEXT VARCHAR(512),
        COMMENTED_USER VARCHAR(255),
        DATE_COMMENTED TIMESTAMP NOT NULL,
        API_ID INTEGER NOT NULL,
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY (COMMENT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_API_RATINGS (
        RATING_ID INTEGER AUTO_INCREMENT,
        API_ID INTEGER,
        RATING INTEGER,
        SUBSCRIBER_ID INTEGER,
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (RATING_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_TIER_PERMISSIONS (
        TIER_PERMISSIONS_ID INTEGER AUTO_INCREMENT,
        TIER VARCHAR(50) NOT NULL,
        PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
        ROLES VARCHAR(512) NOT NULL,
        TENANT_ID INTEGER NOT NULL,
        PRIMARY KEY(TIER_PERMISSIONS_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_EXTERNAL_STORES (
        APISTORE_ID INTEGER AUTO_INCREMENT,
        API_ID INTEGER,
        STORE_ID VARCHAR(255) NOT NULL,
        STORE_DISPLAY_NAME VARCHAR(255) NOT NULL,
        STORE_ENDPOINT VARCHAR(255) NOT NULL,
        STORE_TYPE VARCHAR(255) NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (APISTORE_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_WORKFLOWS(
        WF_ID INTEGER AUTO_INCREMENT,
        WF_REFERENCE VARCHAR(255) NOT NULL,
        WF_TYPE VARCHAR(255) NOT NULL,
        WF_STATUS VARCHAR(255) NOT NULL,
        WF_CREATED_TIME TIMESTAMP,
        WF_UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
        WF_STATUS_DESC VARCHAR(1000),
        TENANT_ID INTEGER,
        TENANT_DOMAIN VARCHAR(255),
        WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,
        PRIMARY KEY (WF_ID),
        UNIQUE (WF_EXTERNAL_REFERENCE)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_REGISTRATION (
        REG_ID INT AUTO_INCREMENT,
        SUBSCRIBER_ID INT,
        WF_REF VARCHAR(255) NOT NULL,
        APP_ID INT,
        TOKEN_TYPE VARCHAR(30),
        TOKEN_SCOPE VARCHAR(1500) DEFAULT 'default',
        INPUTS VARCHAR(1000),
        ALLOWED_DOMAINS VARCHAR(256),
        VALIDITY_PERIOD BIGINT,
        UNIQUE (SUBSCRIBER_ID,APP_ID,TOKEN_TYPE),
        FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY(APP_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
        PRIMARY KEY (REG_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_API_SCOPES (
       API_ID  INTEGER NOT NULL,
       SCOPE_ID  INTEGER NOT NULL,
       FOREIGN KEY (API_ID) REFERENCES AM_API (API_ID) ON DELETE CASCADE ON UPDATE CASCADE,
       FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE ON UPDATE CASCADE,
       PRIMARY KEY (API_ID, SCOPE_ID)
    )ENGINE = INNODB;
    CREATE TABLE IF NOT EXISTS AM_API_DEFAULT_VERSION (
                DEFAULT_VERSION_ID INT AUTO_INCREMENT,
                API_NAME VARCHAR(256) NOT NULL ,
                API_PROVIDER VARCHAR(256) NOT NULL ,
                DEFAULT_API_VERSION VARCHAR(30) ,
                PUBLISHED_DEFAULT_API_VERSION VARCHAR(30) ,
                PRIMARY KEY (DEFAULT_VERSION_ID)
    )ENGINE = INNODB;
    CREATE INDEX IDX_SUB_APP_ID ON AM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID);
    CREATE TABLE IF NOT EXISTS AM_ALERT_TYPES (
                ALERT_TYPE_ID INTEGER AUTO_INCREMENT,
                ALERT_TYPE_NAME VARCHAR(255) NOT NULL ,
            STAKE_HOLDER VARCHAR(100) NOT NULL,
                PRIMARY KEY (ALERT_TYPE_ID)
    )ENGINE = INNODB;
    CREATE TABLE IF NOT EXISTS AM_ALERT_TYPES_VALUES (
                ALERT_TYPE_ID INTEGER,
                USER_NAME VARCHAR(255) NOT NULL ,
            STAKE_HOLDER VARCHAR(100) NOT NULL ,
                PRIMARY KEY (ALERT_TYPE_ID,USER_NAME,STAKE_HOLDER)
    )ENGINE = INNODB;
    CREATE TABLE IF NOT EXISTS AM_ALERT_EMAILLIST (
            EMAIL_LIST_ID INTEGER AUTO_INCREMENT,
                USER_NAME VARCHAR(255) NOT NULL ,
            STAKE_HOLDER VARCHAR(100) NOT NULL ,
                PRIMARY KEY (EMAIL_LIST_ID,USER_NAME,STAKE_HOLDER)
    )ENGINE = INNODB;
    CREATE TABLE IF NOT EXISTS  AM_ALERT_EMAILLIST_DETAILS (
                EMAIL_LIST_ID INTEGER,
            EMAIL VARCHAR(255),
                PRIMARY KEY (EMAIL_LIST_ID,EMAIL)
    )ENGINE = INNODB;
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalResponseTime', 'publisher');
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalBackendTime', 'publisher');
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalRequestsPerMin', 'subscriber');
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalRequestPattern', 'subscriber');
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('UnusualIPAccess', 'subscriber');
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('FrequentTierLimitHitting', 'subscriber');
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('ApiHealthMonitor', 'publisher');
    CREATE TABLE IF NOT EXISTS AM_POLICY_SUBSCRIPTION (
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(512) NOT NULL,
                DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
                TENANT_ID INT(11) NOT NULL,
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
                QUOTA_TYPE VARCHAR(25) NOT NULL,
                QUOTA INT(11) NOT NULL,
                QUOTA_UNIT VARCHAR(10) NULL,
                UNIT_TIME INT(11) NOT NULL,
                TIME_UNIT VARCHAR(25) NOT NULL,
                RATE_LIMIT_COUNT INT(11) NULL DEFAULT NULL,
                RATE_LIMIT_TIME_UNIT VARCHAR(25) NULL DEFAULT NULL,
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,
            CUSTOM_ATTRIBUTES BLOB DEFAULT NULL,
                STOP_ON_QUOTA_REACH BOOLEAN NOT NULL DEFAULT 0,
                BILLING_PLAN VARCHAR(20) NOT NULL,
                UUID VARCHAR(256),
                PRIMARY KEY (POLICY_ID),
                UNIQUE INDEX AM_POLICY_SUBSCRIPTION_NAME_TENANT (NAME, TENANT_ID),
                UNIQUE (UUID)
    )ENGINE = InnoDB;
    CREATE TABLE IF NOT EXISTS AM_POLICY_APPLICATION (
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(512) NOT NULL,
                DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
                TENANT_ID INT(11) NOT NULL,
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
                QUOTA_TYPE VARCHAR(25) NOT NULL,
                QUOTA INT(11) NOT NULL,
                QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
                UNIT_TIME INT(11) NOT NULL,
                TIME_UNIT VARCHAR(25) NOT NULL,
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,
            CUSTOM_ATTRIBUTES BLOB DEFAULT NULL,
                  UUID VARCHAR(256),
                PRIMARY KEY (POLICY_ID),
                UNIQUE INDEX APP_NAME_TENANT (NAME, TENANT_ID),
                UNIQUE (UUID)
    )ENGINE = InnoDB;
    CREATE TABLE IF NOT EXISTS AM_POLICY_HARD_THROTTLING (
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(512) NOT NULL,
                TENANT_ID INT(11) NOT NULL,
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
                QUOTA_TYPE VARCHAR(25) NOT NULL,
                QUOTA INT(11) NOT NULL,
                QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
                UNIT_TIME INT(11) NOT NULL,
                TIME_UNIT VARCHAR(25) NOT NULL,
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,
                PRIMARY KEY (POLICY_ID),
                UNIQUE INDEX POLICY_HARD_NAME_TENANT (NAME, TENANT_ID)
    )ENGINE = InnoDB;
    CREATE TABLE IF NOT EXISTS AM_API_THROTTLE_POLICY (
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(512) NOT NULL,
                DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,
                TENANT_ID INT(11) NOT NULL,
                DESCRIPTION VARCHAR (1024),
                DEFAULT_QUOTA_TYPE VARCHAR(25) NOT NULL,
                DEFAULT_QUOTA INTEGER NOT NULL,
                DEFAULT_QUOTA_UNIT VARCHAR(10) NULL,
                DEFAULT_UNIT_TIME INTEGER NOT NULL,
                DEFAULT_TIME_UNIT VARCHAR(25) NOT NULL,
                APPLICABLE_LEVEL VARCHAR(25) NOT NULL,
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,
                UUID VARCHAR(256),
                PRIMARY KEY (POLICY_ID),
                UNIQUE INDEX API_NAME_TENANT (NAME, TENANT_ID),
                UNIQUE (UUID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_CONDITION_GROUP (
                CONDITION_GROUP_ID INTEGER NOT NULL AUTO_INCREMENT,
                POLICY_ID INTEGER NOT NULL,
                QUOTA_TYPE VARCHAR(25),
                QUOTA INTEGER NOT NULL,
                QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,
                UNIT_TIME INTEGER NOT NULL,
                TIME_UNIT VARCHAR(25) NOT NULL,
                DESCRIPTION VARCHAR (1024) NULL DEFAULT NULL,
                PRIMARY KEY (CONDITION_GROUP_ID),
                FOREIGN KEY (POLICY_ID) REFERENCES AM_API_THROTTLE_POLICY(POLICY_ID) ON DELETE CASCADE ON UPDATE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_QUERY_PARAMETER_CONDITION (
                QUERY_PARAMETER_ID INTEGER NOT NULL AUTO_INCREMENT,
                CONDITION_GROUP_ID INTEGER NOT NULL,
                PARAMETER_NAME VARCHAR(255) DEFAULT NULL,
                PARAMETER_VALUE VARCHAR(255) DEFAULT NULL,
                IS_PARAM_MAPPING BOOLEAN DEFAULT 1,
                PRIMARY KEY (QUERY_PARAMETER_ID),
                FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_HEADER_FIELD_CONDITION (
                HEADER_FIELD_ID INTEGER NOT NULL AUTO_INCREMENT,
                CONDITION_GROUP_ID INTEGER NOT NULL,
                HEADER_FIELD_NAME VARCHAR(255) DEFAULT NULL,
                HEADER_FIELD_VALUE VARCHAR(255) DEFAULT NULL,
                IS_HEADER_FIELD_MAPPING BOOLEAN DEFAULT 1,
                PRIMARY KEY (HEADER_FIELD_ID),
                FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_JWT_CLAIM_CONDITION (
                JWT_CLAIM_ID INTEGER NOT NULL AUTO_INCREMENT,
                CONDITION_GROUP_ID INTEGER NOT NULL,
                CLAIM_URI VARCHAR(512) DEFAULT NULL,
                CLAIM_ATTRIB VARCHAR(1024) DEFAULT NULL,
            IS_CLAIM_MAPPING BOOLEAN DEFAULT 1,
                PRIMARY KEY (JWT_CLAIM_ID),
                FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_IP_CONDITION (
      AM_IP_CONDITION_ID INT NOT NULL AUTO_INCREMENT,
      STARTING_IP VARCHAR(45) NULL,
      ENDING_IP VARCHAR(45) NULL,
      SPECIFIC_IP VARCHAR(45) NULL,
      WITHIN_IP_RANGE BOOLEAN DEFAULT 1,
      CONDITION_GROUP_ID INT NULL,
      PRIMARY KEY (AM_IP_CONDITION_ID),
      INDEX fk_AM_IP_CONDITION_1_idx (CONDITION_GROUP_ID ASC),  CONSTRAINT fk_AM_IP_CONDITION_1    FOREIGN KEY (CONDITION_GROUP_ID)
        REFERENCES AM_CONDITION_GROUP (CONDITION_GROUP_ID)   ON DELETE CASCADE ON UPDATE CASCADE)
    ENGINE = InnoDB;
    CREATE TABLE IF NOT EXISTS AM_POLICY_GLOBAL (
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(512) NOT NULL,
                KEY_TEMPLATE VARCHAR(512) NOT NULL,
                TENANT_ID INT(11) NOT NULL,
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,
                SIDDHI_QUERY BLOB DEFAULT NULL,
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,
                UUID VARCHAR(256),
                PRIMARY KEY (POLICY_ID),
                UNIQUE (UUID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS AM_THROTTLE_TIER_PERMISSIONS (
      THROTTLE_TIER_PERMISSIONS_ID INT NOT NULL AUTO_INCREMENT,
      TIER VARCHAR(50) NULL,
      PERMISSIONS_TYPE VARCHAR(50) NULL,
      ROLES VARCHAR(512) NULL,
      TENANT_ID INT(11) NULL,
      PRIMARY KEY (THROTTLE_TIER_PERMISSIONS_ID))
    ENGINE = InnoDB;
    CREATE TABLE `AM_BLOCK_CONDITIONS` (
      `CONDITION_ID` int(11) NOT NULL AUTO_INCREMENT,
      `TYPE` varchar(45) DEFAULT NULL,
      `VALUE` varchar(512) DEFAULT NULL,
      `ENABLED` varchar(45) DEFAULT NULL,
      `DOMAIN` varchar(45) DEFAULT NULL,
      `UUID` VARCHAR(256),
      PRIMARY KEY (`CONDITION_ID`),
      UNIQUE (`UUID`)
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS `AM_CERTIFICATE_METADATA` (
      `TENANT_ID` INT(11) NOT NULL,
      `ALIAS` VARCHAR(45) NOT NULL,
      `END_POINT` VARCHAR(100) NOT NULL,
      CONSTRAINT PK_ALIAS PRIMARY KEY (`ALIAS`)
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_GROUP_MAPPING (
        APPLICATION_ID INTEGER NOT NULL,
        GROUP_ID VARCHAR(512) NOT NULL,
        TENANT VARCHAR(255),
        PRIMARY KEY (APPLICATION_ID,GROUP_ID,TENANT),
        FOREIGN KEY (APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS AM_USAGE_UPLOADED_FILES (
      TENANT_DOMAIN varchar(255) NOT NULL,
      FILE_NAME varchar(255) NOT NULL,
      FILE_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FILE_PROCESSED tinyint(1) DEFAULT FALSE,
      FILE_CONTENT MEDIUMBLOB DEFAULT NULL,
      PRIMARY KEY (TENANT_DOMAIN, FILE_NAME, FILE_TIMESTAMP)
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS AM_API_LC_PUBLISH_EVENTS (
        ID INTEGER(11) NOT NULL AUTO_INCREMENT,
        TENANT_DOMAIN VARCHAR(500) NOT NULL,
        API_ID VARCHAR(500) NOT NULL,
        EVENT_TIME TIMESTAMP NOT NULL,
        PRIMARY KEY (ID)
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_ATTRIBUTES (
      APPLICATION_ID int(11) NOT NULL,
      NAME varchar(255) NOT NULL,
      VALUE varchar(1024) NOT NULL,
      TENANT_ID int(11) NOT NULL,
      PRIMARY KEY (APPLICATION_ID,NAME),
      FOREIGN KEY (APPLICATION_ID) REFERENCES AM_APPLICATION (APPLICATION_ID) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS AM_LABELS (
      LABEL_ID VARCHAR(50),
      NAME VARCHAR(255),
      DESCRIPTION VARCHAR(1024),
      TENANT_DOMAIN VARCHAR(255),
      UNIQUE (NAME,TENANT_DOMAIN),
      PRIMARY KEY (LABEL_ID)
    ) ENGINE=InnoDB;
    CREATE TABLE IF NOT EXISTS AM_LABEL_URLS (
      LABEL_ID VARCHAR(50),
      ACCESS_URL VARCHAR(255),
      PRIMARY KEY (LABEL_ID,ACCESS_URL),
      FOREIGN KEY (LABEL_ID) REFERENCES AM_LABELS(LABEL_ID) ON UPDATE CASCADE ON DELETE CASCADE
    ) ENGINE=InnoDB;
    create index IDX_ITS_LMT on IDN_THRIFT_SESSION (LAST_MODIFIED_TIME);
    create index IDX_IOAT_UT on IDN_OAUTH2_ACCESS_TOKEN (USER_TYPE);
    create index IDX_AAI_CTX on AM_API (CONTEXT);
    create index IDX_AAKM_CK on AM_APPLICATION_KEY_MAPPING (CONSUMER_KEY);
    create index IDX_AAUM_AI on AM_API_URL_MAPPING (API_ID);
    create index IDX_AAUM_TT on AM_API_URL_MAPPING (THROTTLING_TIER);
    create index IDX_AATP_DQT on AM_API_THROTTLE_POLICY (DEFAULT_QUOTA_TYPE);
    create index IDX_ACG_QT on AM_CONDITION_GROUP (QUOTA_TYPE);
    create index IDX_APS_QT on AM_POLICY_SUBSCRIPTION (QUOTA_TYPE);
    create index IDX_AS_AITIAI on AM_SUBSCRIPTION (API_ID,TIER_ID,APPLICATION_ID);
    create index IDX_APA_QT on AM_POLICY_APPLICATION (QUOTA_TYPE);
    create index IDX_AA_AT_CB on AM_APPLICATION (APPLICATION_TIER,CREATED_BY);
kind: ConfigMap
metadata:
  name: mysql-dbscripts
EOF

cat >> $k8s_obj_file << EOF
  namespace: $namespace
---

apiVersion: v1
kind: Service
metadata:
  name: wso2apim-with-analytics-rdbms-service
  namespace: $namespace
spec:
  type: ClusterIP
  selector:
    deployment: wso2apim-with-analytics-mysql
  ports:
    - name: mysql-port
      port: 3306
      targetPort: 3306
      protocol: TCP
---

apiVersion: v1
kind: Service
metadata:
  name: wso2apim-with-analytics-apim-analytics-service
  namespace: $namespace
spec:
  selector:
    deployment: wso2apim-with-analytics-apim-analytics
  ports:
    -
      name: 'thrift'
      port: 7612
      protocol: TCP
    -
      name: 'thrift-ssl'
      port: 7712
      protocol: TCP
    -
      name: 'rest-api-port-1'
      protocol: TCP
      port: 9444
    -
      name: 'rest-api-port-2'
      protocol: TCP
      port: 9091
    -
      name: 'rest-api-port-3'
      protocol: TCP
      port: 7071
    -
      name: 'rest-api-port-4'
      protocol: TCP
      port: 7444
---

apiVersion: v1
kind: Service
metadata:
  name: wso2apim-with-analytics-apim-service
  namespace: $namespace
  labels:
    deployment: wso2apim-with-analytics-apim
spec:
  selector:
    deployment: wso2apim-with-analytics-apim
  type: NodePort
  ports:
    -
      name: pass-through-http
      protocol: TCP
      port: 8280
    -
      name: pass-through-https
      protocol: TCP
      port: 8243
      nodePort: $NP_1
    -
      name: servlet-http
      protocol: TCP
      port: 9763
    -
      name: servlet-https
      protocol: TCP
      nodePort: $NP_2
      port: 9443
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wso2apim-with-analytics-mysql-deployment
  namespace: $namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      deployment: wso2apim-with-analytics-mysql
      product: wso2am
  template:
    metadata:
      labels:
        deployment: wso2apim-with-analytics-mysql
        product: wso2am
    spec:
      containers:
        - name: wso2apim-with-analytics-mysql
          image: mysql:5.7
          imagePullPolicy: IfNotPresent
          securityContext:
            runAsUser: 999
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
            - name: MYSQL_USER
              value: wso2carbon
            - name: MYSQL_PASSWORD
              value: wso2carbon
          ports:
            - containerPort: 3306
              protocol: TCP
          volumeMounts:
            - name: mysql-dbscripts
              mountPath: /docker-entrypoint-initdb.d
          args: ['--max-connections', '10000']
      volumes:
        - name: mysql-dbscripts
          configMap:
            name: mysql-dbscripts
      serviceAccountName: 'wso2svc-account'
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wso2apim-with-analytics-apim-analytics-deployment
  namespace: $namespace
spec:
  replicas: 1
  minReadySeconds: 30
  selector:
    matchLabels:
      deployment: wso2apim-with-analytics-apim-analytics
      product: wso2am
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        deployment: wso2apim-with-analytics-apim-analytics
        product: wso2am
    spec:
      containers:
        - name: wso2apim-with-analytics-apim-analytics
          image: docker.wso2.com/wso2am-analytics-worker:2.6.0
          resources:
            limits:
              memory: '2Gi'
            requests:
              memory: '2Gi'
          livenessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - nc -z localhost 7712
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - nc -z localhost 7712
            initialDelaySeconds: 10
            periodSeconds: 10
          lifecycle:
            preStop:
              exec:
                command:  ['sh', '-c', '/bin/worker.sh stop']
          imagePullPolicy: Always
          securityContext:
            runAsUser: 802
          ports:
            -
              containerPort: 9764
              protocol: 'TCP'
            -
              containerPort: 9444
              protocol: 'TCP'
            -
              containerPort: 7612
              protocol: 'TCP'
            -
              containerPort: 7712
              protocol: 'TCP'
            -
              containerPort: 9091
              protocol: 'TCP'
            -
              containerPort: 7071
              protocol: 'TCP'
            -
              containerPort: 7444
              protocol: 'TCP'
          volumeMounts:
            - name: apim-analytics-conf-worker
              mountPath: /home/wso2carbon/wso2-config-volume/conf/worker
      initContainers:
        - name: init-apim-with-analytics
          image: busybox
          command: ['sh', '-c', 'echo -e "checking for the availability of MySQL"; while ! nc -z wso2apim-with-analytics-rdbms-service 3306; do sleep 1; printf "-"; done; echo -e "  >> MySQL started";']
      serviceAccountName: 'wso2svc-account'
      imagePullSecrets:
        - name: wso2creds
      volumes:
        - name: apim-analytics-conf-worker
          configMap:
            name: apim-analytics-conf-worker
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wso2apim-with-analytics-apim
  namespace: $namespace
spec:
  replicas: 1
  minReadySeconds: 30
  selector:
    matchLabels:
      deployment: wso2apim-with-analytics-apim
      product: wso2am
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        deployment: wso2apim-with-analytics-apim
        product: wso2am
    spec:
      containers:
        - name: wso2apim-with-analytics-apim-worker
          image: docker.wso2.com/wso2am:2.6.0
          resources:
            limits:
              memory: '3Gi'
              cpu: 3000m
            requests:
              memory: '2Gi'
              cpu: 2000m
          livenessProbe:
            exec:
              command:
                - /bin/bash
                - -c
                - nc -z localhost 9443
            initialDelaySeconds: 60
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - /bin/bash
                - -c
                - nc -z localhost 9443
            initialDelaySeconds: 60
            periodSeconds: 10
          imagePullPolicy: Always
          ports:
            -
              containerPort: 8280
              protocol: 'TCP'
            -
              containerPort: 8243
              protocol: 'TCP'
            -
              containerPort: 9763
              protocol: 'TCP'
            -
              containerPort: 9443
              protocol: 'TCP'
            -
              containerPort: 5672
              protocol: 'TCP'
            -
              containerPort: 9711
              protocol: 'TCP'
            -
              containerPort: 9611
              protocol: 'TCP'
            -
              containerPort: 7711
              protocol: 'TCP'
            -
              containerPort: 7611
              protocol: 'TCP'
          volumeMounts:
            - name: apim-conf
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf
            - name: apim-conf-axis2
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf/axis2
            - name: apim-conf-datasources
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf/datasources
      initContainers:
        - name: init-apim
          image: busybox
          command: ['sh', '-c', 'echo -e "checking for the availability of wso2apim-with-analytics-apim-analytics"; while ! nc -z wso2apim-with-analytics-apim-analytics-service 7712; do sleep 1; printf "-"; done; echo -e " >> wso2is-with-analytics-is-analytics started";']
      serviceAccountName: 'wso2svc-account'
      imagePullSecrets:
        - name: wso2creds
      volumes:
        - name: apim-conf
          configMap:
            name: apim-conf
        - name: apim-conf-axis2
          configMap:
            name: apim-conf-axis2
        - name: apim-conf-datasources
          configMap:
            name: apim-conf-datasources
---
EOF

}
function get_creds(){
  while [[ -z "$WUMUsername" ]]
  do
        read -p "$(echoBold "Enter your WSO2 subscription username: ")" WUMUsername
        if [[ -z "$WUMUsername" ]]
        then
           echo "wso2-subscription-username cannot be empty"
        fi
  done

  while [[ -z "$WUMPassword" ]]
  do
        read -sp "$(echoBold "Enter your WSO2 subscription password: ")" WUMPassword
        echo ""
        if [[ -z "$WUMPassword" ]]
        then
          echo "wso2-subscription-password cannot be empty"
        fi
  done
}
function validate_ip(){
    ip_check=$1
    if [[ $ip_check =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      IFS='.'
      ip=$ip_check
      set -- $ip
      if [[ $1 -le 255 ]] && [[ $2 -le 255 ]] && [[ $3 -le 255 ]] && [[ $4 -le 255 ]]; then
        IFS=''
        NODE_IP=$ip_check
      else
        IFS=''
        echo "Invalid IP. Please try again."
        NODE_IP=""
      fi
    else
      echo "Invalid IP. Please try again."
      NODE_IP=""
    fi
}
function get_node_ip(){
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}')

  if [[ -z $NODE_IP ]]
  then
      if [[ $(kubectl config current-context)="minikube" ]]
      then
          NODE_IP=$(minikube ip)
      else
        echo "We could not find your cluster node-ip."
        while [[ -z "$NODE_IP" ]]
        do
              read -p "$(echo "Enter one of your cluster Node IPs to provision instant access to server: ")" NODE_IP
              if [[ -z "$NODE_IP" ]]
              then
                echo "cluster node ip cannot be empty"
              else
                validate_ip $NODE_IP
              fi
        done
      fi
  fi
  set -- $NODE_IP; NODE_IP=$1
}

function get_nodeports(){
  LOWER=30000; UPPER=32767;
  if [ "$randomPort" == "True" ]; then
    NP_1=0; NP_2=0;
    while [ $NP_1 -lt $LOWER ] || [ $NP_2 -lt $LOWER ]
    do
      NP_1=$RANDOM; NP_2=$RANDOM
      let "NP_1 %= $UPPER"; let "NP_2 %= $UPPER"
    done
  fi
  echo -e "[INFO] nodePorts  are set to $NP_1 and $NP_2"
}
function progress_bar(){

  dep_status=$(kubectl get deployments -n wso2 -o jsonpath='{.items[?(@.spec.selector.matchLabels.product=="wso2am")].status.conditions[?(@.type=="Available")].status}')
  pod_status=$(kubectl get pods -n wso2 -o jsonpath='{.items[?(@.metadata.labels.product=="wso2am")].status.conditions[*].status}')

  num_true_const=0; progress_unit="";num_true=0; time_proc=0;

  arr_dep=($dep_status); arr_pod=($pod_status)

  let "length_total= ${#arr_pod[@]} + ${#arr_dep[@]}";

  echo ""

  while [[ $num_true -lt $length_total ]]
  do

      sleep 4

      num_true=0
      dep_status=$(kubectl get deployments -n wso2 -o jsonpath='{.items[?(@.spec.selector.matchLabels.product=="wso2am")].status.conditions[?(@.type=="Available")].status}')
      pod_status=$(kubectl get pods -n wso2 -o jsonpath='{.items[?(@.metadata.labels.product=="wso2am")].status.conditions[*].status}')

      arr_dep=($dep_status); arr_pod=($pod_status); let "length_total= ${#arr_pod[@]} + ${#arr_dep[@]}";

      for ele_dep in $dep_status
      do
          if [ "$ele_dep" = "True" ]
          then
              let "num_true=num_true+1"
          fi
      done

      for ele_pod in $pod_status
      do
          if [ "$ele_pod" = "True" ]
          then
              let "num_true=num_true+1"
          fi
      done

      printf "Processing WSO2 API Manager ... |"

      printf "%-$((5 * ${length_total-1}))s| $(($num_true_const * 100/ $length_total))"; echo -en ' % \r'

      printf "Processing WSO2 API Manager ... |"
      s=$(printf "%-$((5 * ${num_true_const}))s" "H")
      echo -en "${s// /H}"

      printf "%-$((5 * $(($length_total - $num_true_const))))s| $((100 * $(($num_true_const))/ $length_total))"; echo -en ' %\r '

      if [ $num_true -ne $num_true_const ]
      then
          i=0
          while [[ $i -lt  $((5 * $((${num_true} - ${num_true_const})))) ]]
          do
              let "i=i+1"
              progress_unit=$progress_unit"H"
              printf "Processing WSO2 API Manager ... |"
              echo -n $progress_unit
              printf "%-$((5 * $((${length_total} - ${num_true_const})) - $i))s| $(($(( 100 * $(($num_true_const))/ $length_total)) +  $((20 * $i/$length_total)) ))"; echo -en ' %\r '
              sleep 0.25
          done
          num_true_const=$num_true
          time_proc=0
        else
            let "time_proc=time_proc + 5"
      fi

      printf "Processing WSO2 API Manager ... |"

      printf "%-$((5 * ${length_total-1}))s| $(($num_true_const * 100/ $length_total))"; echo -en ' %\r '

      printf "Processing WSO2 API Manager ... |"
      s=$(printf "%-$((5 * ${num_true_const}))s" "H")
      echo -en "${s// /H}"

      printf "%-$((5 * $(($length_total - $num_true_const))))s| $((100 * $(($num_true_const))/ $length_total))"; echo -en ' %\r '

      sleep 1

      if [[ $time_proc -gt 250 ]]
      then
          echoBold "\n\nSomething went wrong! Please Follow < FAQ-Link > for more information\n"
          exit 2
      fi

  done

  echo -e "\n"

}

function deploy(){
    #checking for required command line tools
    if [[ ! $(which kubectl) ]]
    then
       display_msg "Please install Kubernetes command-line tool (kubectl) before you start with the setup\n"
    fi

    if [[ ! $(which base64) ]]
    then
       display_msg "Please install base64 before you start with the setup\n"
    fi

    echoBold "Checking for an enabled cluster... Your patience is appreciated... "
    cluster_isReady=$(kubectl cluster-info) > /dev/null 2>&1  || true

    if [[ ! $cluster_isReady == *"KubeDNS"* ]]
    then
        display_msg "\nPlease enable your cluster before running the setup.\n\nIf you don't have a kubernetes cluster, follow: https://kubernetes.io/docs/setup/\n\n"
    fi

    echoBold "Done\n"

    #displaying wso2 product name
    product_name

    # check if testgrid
    if test -f "$INPUT_DIR/infrastructure.properties"; then
      file=$INPUT_DIR/infrastructure.properties
      WUMUsername=$(cat $file | grep "WUMUsername" | cut -d'=' -f2)
      WUMPassword=$(cat $file | grep "WUMPassword" | cut -c 13- | tr -d '\')
      randomPort=$(cat $file | grep "randomPort" | cut -d'=' -f2)
      namespace=$(cat $file | grep "namespace" | cut -d'=' -f2)
      echo $WUMUsername
      echo $WUMPassword
      echo $randomPort
      echo $namespace
    else
      get_creds
    fi

    # get node-ip
    get_node_ip

    # create and encode username/password pair
    auth="$WUMUsername:$WUMPassword"
    authb64=`echo -n $auth | base64`

    # create authorisation code
    authstring='{"auths":{"docker.wso2.com":{"username":"'${WUMUsername}'","password":"'${WUMPassword}'","email":"'${WUMUsername}'","auth":"'${authb64}'"}}}'

    # encode in base64
    secdata=`echo -n $authstring | base64`

    for i in $secdata; do
      str_sec=$str_sec$i
    done

    get_nodeports

    # create kubernetes object yaml
    create_yaml

    if ! test -f "$INPUT_DIR/infrastructure.properties"; then
        echoBold "\nDeploying WSO2 API Manager ....\n"

        # Deploy wso2am
        kubectl create -f $k8s_obj_file

        # waiting until deployment is ready
        progress_bar
        echoBold "Successfully deployed WSO2 API Manager.\n\n"

        echoBold "1. Try navigating to https://$NODE_IP:30443/carbon/ from your favourite browser using \n"
        echoBold "\tusername: admin\n"
        echoBold "\tpassword: admin\n"
        echoBold "2. Follow <getting-started-link> to start using WSO2 API Manager.\n\n"
    fi
}

deploy