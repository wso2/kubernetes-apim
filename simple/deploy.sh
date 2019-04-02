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

ECHO=`which echo`

function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

WSO2_SUBSCRIPTION_USERNAME=''
WSO2_SUBSCRIPTION_PASSWORD=''

echoBold "Enter your wso2 subscription username"

read -p "USERNAME: " WSO2_SUBSCRIPTION_USERNAME
echoBold "Enter your wso2 subscription password"
read -sp "PASSWORD: " WSO2_SUBSCRIPTION_PASSWORD

echo ""

# create and encode username/password pair
auth="$WSO2_SUBSCRIPTION_USERNAME:$WSO2_SUBSCRIPTION_PASSWORD"
authb64=`echo -n $auth | base64`

# create authorisation code
authstring='{"auths":{"docker.wso2.com": {"username":"'$WSO2_SUBSCRIPTION_USERNAME'","password":"'$WSO2_SUBSCRIPTION_PASSWORD'","email":"'$WSO2_SUBSCRIPTION_USERNAME'","auth":"'$authb64'"}}}'

# encode in base64
secdata=`echo -n $authstring | base64`

echo -e "apiVersion: v1\n\
kind: Namespace\n\
metadata:\n\
  name: wso2\n\
spec:\n\
  finalizers:\n\
    - kubernetes\n---\n" > deployment.yaml

echo -e "apiVersion: v1\n\
kind: ServiceAccount\n\
metadata:\n\
  name: wso2svc-account\n\
  namespace: wso2\n\
secrets:\n\
  - name: wso2svc-account-token-t7s49\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  .dockerconfigjson: $secdata\n\
kind: Secret\n\
metadata:\n\
  name: wso2creds\n\
  namespace: wso2\n\
type: kubernetes.io/dockerconfigjson\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  api-manager.xml: |\n\
    <APIManager>\n\
        <DataSourceName>jdbc/WSO2AM_DB</DataSourceName>\n\
        <GatewayType>Synapse</GatewayType>\n\
        <EnableSecureVault>false</EnableSecureVault>\n\
        <AuthManager>\n\
            <ServerURL>https://localhost:\${mgt.transport.https.port}\${carbon.context}services/</ServerURL>\n\
            <Username>\${admin.username}</Username>\n\
            <Password>\${admin.password}</Password>\n\
            <CheckPermissionsRemotely>false</CheckPermissionsRemotely>\n\
        </AuthManager>\n\
        <JWTConfiguration>\n\
            <JWTHeader>X-JWT-Assertion</JWTHeader>\n\
            <JWTGeneratorImpl>org.wso2.carbon.apimgt.keymgt.token.JWTGenerator</JWTGeneratorImpl>\n\
        </JWTConfiguration>\n\
        <APIGateway>\n\
            <Environments>\n\
                <Environment type=\"hybrid\" api-console=\"true\">\n\
                    <Name>Production and Sandbox</Name>\n\
                    <Description>This is a hybrid gateway that handles both production and sandbox token traffic.</Description>\n\
                    <ServerURL>https://localhost:\${mgt.transport.https.port}\${carbon.context}services/</ServerURL>\n\
                    <Username>\${admin.username}</Username>\n\
                    <Password>\${admin.password}</Password>\n\
                    <GatewayEndpoint>http://wso2apim-gateway,https://wso2apim-gateway</GatewayEndpoint>\n\
                    <GatewayWSEndpoint>ws://\${carbon.local.ip}:9099</GatewayWSEndpoint>\n\
                </Environment>\n\
            </Environments>\n\
        </APIGateway>\n\
        <CacheConfigurations>\n\
            <EnableGatewayTokenCache>true</EnableGatewayTokenCache>\n\
            <EnableGatewayResourceCache>true</EnableGatewayResourceCache>\n\
            <EnableKeyManagerTokenCache>false</EnableKeyManagerTokenCache>\n\
            <EnableRecentlyAddedAPICache>false</EnableRecentlyAddedAPICache>\n\
            <EnableScopeCache>true</EnableScopeCache>\n\
            <EnablePublisherRoleCache>true</EnablePublisherRoleCache>\n\
            <EnableJWTClaimCache>true</EnableJWTClaimCache>\n\
        </CacheConfigurations>\n\
        <Analytics>\n\
            <Enabled>true</Enabled>\n\
            <StreamProcessorServerURL>tcp://wso2apim-with-analytics-apim-analytics-service:7612</StreamProcessorServerURL>\n\
            <StreamProcessorAuthServerURL>ssl://wso2apim-with-analytics-apim-analytics-service:7712</StreamProcessorAuthServerURL>\n\
            <StreamProcessorUsername>\${admin.username}</StreamProcessorUsername>\n\
            <StreamProcessorPassword>\${admin.password}</StreamProcessorPassword>\n\
            <StatsProviderImpl>org.wso2.carbon.apimgt.usage.client.impl.APIUsageStatisticsRestClientImpl</StatsProviderImpl>\n\
            <StreamProcessorRestApiURL>https://wso2apim-with-analytics-apim-analytics-service:7444</StreamProcessorRestApiURL>\n\
            <StreamProcessorRestApiUsername>\${admin.username}</StreamProcessorRestApiUsername>\n\
            <StreamProcessorRestApiPassword>\${admin.password}</StreamProcessorRestApiPassword>\n\
            <SkipEventReceiverConnection>false</SkipEventReceiverConnection>\n\
            <SkipWorkflowEventPublisher>false</SkipWorkflowEventPublisher>\n\
            <PublisherClass>org.wso2.carbon.apimgt.usage.publisher.APIMgtUsageDataBridgeDataPublisher</PublisherClass>\n\
            <PublishResponseMessageSize>false</PublishResponseMessageSize>\n\
            <Streams>\n\
                <Request>\n\
                    <Name>org.wso2.apimgt.statistics.request</Name>\n\
                    <Version>3.0.0</Version>\n\
                </Request>\n\
                <Fault>\n\
                    <Name>org.wso2.apimgt.statistics.fault</Name>\n\
                    <Version>3.0.0</Version>\n\
                </Fault>\n\
                <Throttle>\n\
                    <Name>org.wso2.apimgt.statistics.throttle</Name>\n\
                    <Version>3.0.0</Version>\n\
                </Throttle>\n\
                <Workflow>\n\
                    <Name>org.wso2.apimgt.statistics.workflow</Name>\n\
                    <Version>1.0.0</Version>\n\
                </Workflow>\n\
                <AlertTypes>\n\
                    <Name>org.wso2.analytics.apim.alertStakeholderInfo</Name>\n\
                    <Version>1.0.1</Version>\n\
                </AlertTypes>\n\
            </Streams>\n\
        </Analytics>\n\
        <APIKeyValidator>\n\
            <ServerURL>https://localhost:\${mgt.transport.https.port}\${carbon.context}services/</ServerURL>\n\
            <Username>\${admin.username}</Username>\n\
            <Password>\${admin.password}</Password>\n\
            <KeyValidatorClientType>ThriftClient</KeyValidatorClientType>\n\
            <ThriftClientConnectionTimeOut>10000</ThriftClientConnectionTimeOut>\n\
            <EnableThriftServer>true</EnableThriftServer>\n\
            <ThriftServerHost>localhost</ThriftServerHost>\n\
            <KeyValidationHandlerClassName>org.wso2.carbon.apimgt.keymgt.handlers.DefaultKeyValidationHandler</KeyValidationHandlerClassName>\n\
        </APIKeyValidator>\n\
        <OAuthConfigurations>\n\
            <ApplicationTokenScope>am_application_scope</ApplicationTokenScope>\n\
            <TokenEndPointName>/oauth2/token</TokenEndPointName>\n\
            <RevokeAPIURL>https://localhost:\${https.nio.port}/revoke</RevokeAPIURL>\n\
            <EncryptPersistedTokens>false</EncryptPersistedTokens>\n\
            <EnableTokenHashMode>false</EnableTokenHashMode>\n\
        </OAuthConfigurations>\n\
        <TierManagement>\n\
            <EnableUnlimitedTier>true</EnableUnlimitedTier>\n\
        </TierManagement>\n\
        <APIStore>\n\
            <CompareCaseInsensitively>true</CompareCaseInsensitively>\n\
            <DisplayURL>false</DisplayURL>\n\
            <URL>https://localhost:\${mgt.transport.https.port}/store</URL>\n\
            <ServerURL>https://localhost:\${mgt.transport.https.port}\${carbon.context}services/</ServerURL>\n\
            <Username>\${admin.username}</Username>\n\
            <Password>\${admin.password}</Password>\n\
            <DisplayMultipleVersions>false</DisplayMultipleVersions>\n\
            <DisplayAllAPIs>false</DisplayAllAPIs>\n\
            <DisplayComments>true</DisplayComments>\n\
            <DisplayRatings>true</DisplayRatings>\n\
        </APIStore>\n\
        <APIPublisher>\n\
            <DisplayURL>false</DisplayURL>\n\
            <URL>https://localhost:\${mgt.transport.https.port}/publisher</URL>\n\
            <EnableAccessControl>true</EnableAccessControl>\n\
        </APIPublisher>\n\
        <CORSConfiguration>\n\
            <Enabled>true</Enabled>\n\
            <Access-Control-Allow-Origin>*</Access-Control-Allow-Origin>\n\
            <Access-Control-Allow-Methods>GET,PUT,POST,DELETE,PATCH,OPTIONS</Access-Control-Allow-Methods>\n\
            <Access-Control-Allow-Headers>authorization,Access-Control-Allow-Origin,Content-Type,SOAPAction</Access-Control-Allow-Headers>\n\
            <Access-Control-Allow-Credentials>false</Access-Control-Allow-Credentials>\n\
        </CORSConfiguration>\n\
        <RESTAPI>\n\
            <WhiteListedURIs>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/publisher/{version}/swagger.json</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/swagger.json</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/admin/{version}/swagger.json</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}/swagger</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}/documents</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}/documents/{documentId}</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}/documents/{documentId}/content</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}/thumbnail</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/tags</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/tiers/{tierLevel}</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
                <WhiteListedURI>\n\
                    <URI>/api/am/store/{version}/tiers/{tierLevel}/{tierName}</URI>\n\
                    <HTTPMethods>GET,HEAD</HTTPMethods>\n\
                </WhiteListedURI>\n\
            </WhiteListedURIs>\n\
            <ETagSkipList>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/apis</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/apis/generate-sdk</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/apis/{apiId}/documents</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/applications</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/applications/generate-keys</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/subscriptions</URI>\n\
                    <HTTPMethods>GET,POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/tags</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/tiers/{tierLevel}</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/store/{version}/tiers/{tierLevel}/{tierName}</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis</URI>\n\
                    <HTTPMethods>GET,POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}</URI>\n\
                    <HTTPMethods>GET,DELETE,PUT</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/swagger</URI>\n\
                    <HTTPMethods>GET,PUT</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/thumbnail</URI>\n\
                    <HTTPMethods>GET,POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/change-lifecycle</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/copy-api</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/applications/{applicationId}</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/documents</URI>\n\
                    <HTTPMethods>GET,POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/documents/{documentId}/content</URI>\n\
                    <HTTPMethods>GET,POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/apis/{apiId}/documents/{documentId}</URI>\n\
                    <HTTPMethods>GET,PUT,DELETE</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/environments</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/subscriptions</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/subscriptions/block-subscription</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/subscriptions/{subscriptionId}</URI>\n\
                    <HTTPMethods>GET</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/subscriptions/unblock-subscription</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/tiers/{tierLevel}</URI>\n\
                    <HTTPMethods>GET,POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/tiers/{tierLevel}/{tierName}</URI>\n\
                    <HTTPMethods>GET,PUT,DELETE</HTTPMethods>\n\
                </ETagSkipURI>\n\
                <ETagSkipURI>\n\
                    <URI>/api/am/publisher/{version}/tiers/update-permission</URI>\n\
                    <HTTPMethods>POST</HTTPMethods>\n\
                </ETagSkipURI>\n\
            </ETagSkipList>\n\
        </RESTAPI>\n\
        <ThrottlingConfigurations>\n\
            <EnableAdvanceThrottling>true</EnableAdvanceThrottling>\n\
            <TrafficManager>\n\
                <Type>Binary</Type>\n\
                <ReceiverUrlGroup>tcp://\${carbon.local.ip}:\${receiver.url.port}</ReceiverUrlGroup>\n\
                <AuthUrlGroup>ssl://\${carbon.local.ip}:\${auth.url.port}</AuthUrlGroup>\n\
                <Username>\${admin.username}</Username>\n\
                <Password>\${admin.password}</Password>\n\
            </TrafficManager>\n\
            <DataPublisher>\n\
                <Enabled>true</Enabled>\n\
                <DataPublisherPool>\n\
                    <MaxIdle>1000</MaxIdle>\n\
                    <InitIdleCapacity>200</InitIdleCapacity>\n\
                </DataPublisherPool>\n\
                <DataPublisherThreadPool>\n\
                    <CorePoolSize>200</CorePoolSize>\n\
                    <MaxmimumPoolSize>1000</MaxmimumPoolSize>\n\
                    <KeepAliveTime>200</KeepAliveTime>\n\
                </DataPublisherThreadPool>\n\
            </DataPublisher>\n\
            <PolicyDeployer>\n\
                <Enabled>true</Enabled>\n\
                <ServiceURL>https://localhost:\${mgt.transport.https.port}\${carbon.context}services/</ServiceURL>\n\
                <Username>\${admin.username}</Username>\n\
                <Password>\${admin.password}</Password>\n\
            </PolicyDeployer>\n\
            <BlockCondition>\n\
                <Enabled>true</Enabled>\n\
            </BlockCondition>\n\
            <JMSConnectionDetails>\n\
                <Enabled>true</Enabled>\n\
                <JMSConnectionParameters>\n\
                    <transport.jms.ConnectionFactoryJNDIName>TopicConnectionFactory</transport.jms.ConnectionFactoryJNDIName>\n\
                    <transport.jms.DestinationType>topic</transport.jms.DestinationType>\n\
                    <java.naming.factory.initial>org.wso2.andes.jndi.PropertiesFileInitialContextFactory</java.naming.factory.initial>\n\
                    <connectionfactory.TopicConnectionFactory>amqp://\${admin.username}:\${admin.password}@clientid/carbon?brokerlist='tcp://\${carbon.local.ip}:\${jms.port}'</connectionfactory.TopicConnectionFactory>\n\
                </JMSConnectionParameters>\n\
            </JMSConnectionDetails>=\n\
            <EnableUnlimitedTier>true</EnableUnlimitedTier>\n\
            <EnableHeaderConditions>false</EnableHeaderConditions>\n\
            <EnableJWTClaimConditions>false</EnableJWTClaimConditions>\n\
            <EnableQueryParamConditions>false</EnableQueryParamConditions>\n\
        </ThrottlingConfigurations>\n\
        <WorkflowConfigurations>\n\
            <Enabled>false</Enabled>\n\
            <ServerUrl>https://localhost:9445/bpmn</ServerUrl>\n\
            <ServerUser>\${admin.username}</ServerUser>\n\
            <ServerPassword>\${admin.password}</ServerPassword>\n\
            <WorkflowCallbackAPI>https://localhost:\${mgt.transport.https.port}/api/am/publisher/v0.14/workflows/update-workflow-status</WorkflowCallbackAPI>\n\
            <TokenEndPoint>https://localhost:\${https.nio.port}/token</TokenEndPoint>\n\
            <DCREndPoint>https://localhost:\${mgt.transport.https.port}/client-registration/v0.14/register</DCREndPoint>\n\
            <DCREndPointUser>\${admin.username}</DCREndPointUser>\n\
            <DCREndPointPassword>\${admin.password}</DCREndPointPassword>\n\
        </WorkflowConfigurations>\n\
        <SwaggerCodegen>\n\
            <ClientGeneration>\n\
                <GroupId>org.wso2</GroupId>\n\
                <ArtifactId>org.wso2.client.</ArtifactId>\n\
                <ModelPackage>org.wso2.client.model.</ModelPackage>\n\
                <ApiPackage>org.wso2.client.api.</ApiPackage>\n\
                <SupportedLanguages>java,android</SupportedLanguages>\n\
            </ClientGeneration>\n\
        </SwaggerCodegen>\n\
    </APIManager>\n\
  carbon.xml: |\n\
    <?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n\
    <Server xmlns=\"http://wso2.org/projects/carbon/carbon.xml\">\n\
        <Name>WSO2 API Manager</Name>\n\
        <ServerKey>AM</ServerKey>\n\
        <Version>2.6.0</Version>\n\
        <HostName>wso2apim</HostName>\n\
        <MgtHostName>wso2apim</MgtHostName>\n\
        <ServerURL>local:/\${carbon.context}/services/</ServerURL>\n\
        <ServerRoles>\n\
            <Role>APIManager</Role>\n\
        </ServerRoles>\n\
        <Package>org.wso2.carbon</Package>\n\
        <WebContextRoot>/</WebContextRoot>\n\
        <ItemsPerPage>15</ItemsPerPage>\n\
        <Ports>\n\
            <Offset>0</Offset>\n\
            <JMX>\n\
                <RMIRegistryPort>9999</RMIRegistryPort>\n\
                <RMIServerPort>11111</RMIServerPort>\n\
            </JMX>\n\
            <EmbeddedLDAP>\n\
                <LDAPServerPort>10389</LDAPServerPort>\n\
                <KDCServerPort>8000</KDCServerPort>\n\
            </EmbeddedLDAP>\n\
            <ThriftEntitlementReceivePort>10500</ThriftEntitlementReceivePort>\n\
        </Ports>\n\
        <JNDI>\n\
            <DefaultInitialContextFactory>org.wso2.carbon.tomcat.jndi.CarbonJavaURLContextFactory</DefaultInitialContextFactory>\n\
            <Restrictions>\n\
                <AllTenants>\n\
                    <UrlContexts>\n\
                        <UrlContext>\n\
                            <Scheme>java</Scheme>\n\
                        </UrlContext>\n\
                    </UrlContexts>\n\
                </AllTenants>\n\
            </Restrictions>\n\
        </JNDI>\n\
        <IsCloudDeployment>false</IsCloudDeployment>\n\
        <EnableMetering>false</EnableMetering>\n\
        <MaxThreadExecutionTime>600</MaxThreadExecutionTime>\n\
        <GhostDeployment>\n\
            <Enabled>false</Enabled>\n\
        </GhostDeployment>\n\
        <Tenant>\n\
            <LoadingPolicy>\n\
                <LazyLoading>\n\
                    <IdleTime>30</IdleTime>\n\
                </LazyLoading>\n\
            </LoadingPolicy>\n\
        </Tenant>\n\
        <Cache>\n\
            <DefaultCacheTimeout>15</DefaultCacheTimeout>\n\
            <ForceLocalCache>false</ForceLocalCache>\n\
        </Cache>\n\
        <Axis2Config>\n\
            <RepositoryLocation>\${carbon.home}/repository/deployment/server/</RepositoryLocation>\n\
            <DeploymentUpdateInterval>15</DeploymentUpdateInterval>\n\
            <ConfigurationFile>\${carbon.home}/repository/conf/axis2/axis2.xml</ConfigurationFile>\n\
            <ServiceGroupContextIdleTime>30000</ServiceGroupContextIdleTime>\n\
            <ClientRepositoryLocation>\${carbon.home}/repository/deployment/client/</ClientRepositoryLocation>\n\
            <clientAxis2XmlLocation>\${carbon.home}/repository/conf/axis2/axis2_client.xml</clientAxis2XmlLocation>\n\
            <HideAdminServiceWSDLs>true</HideAdminServiceWSDLs>\n\
        </Axis2Config>\n\
        <ServiceUserRoles>\n\
            <Role>\n\
                <Name>admin</Name>\n\
                <Description>Default Administrator Role</Description>\n\
            </Role>\n\
            <Role>\n\
                <Name>user</Name>\n\
                <Description>Default User Role</Description>\n\
            </Role>\n\
        </ServiceUserRoles>\n\
        <CryptoService>\n\
            <Enabled>true</Enabled>\n\
            <InternalCryptoProviderClassName>org.wso2.carbon.crypto.provider.KeyStoreBasedInternalCryptoProvider</InternalCryptoProviderClassName>\n\
            <ExternalCryptoProviderClassName>org.wso2.carbon.core.encryption.KeyStoreBasedExternalCryptoProvider</ExternalCryptoProviderClassName>\n\
            <KeyResolvers>\n\
                <KeyResolver className=\"org.wso2.carbon.crypto.defaultProvider.resolver.ContextIndependentKeyResolver\" priority=\"-1\"/>\n\
            </KeyResolvers>\n\
        </CryptoService>\n\
        <Security>\n\
            <KeyStore>\n\
                <Location>\${carbon.home}/repository/resources/security/wso2carbon.jks</Location>\n\
                <Type>JKS</Type>\n\
                <Password>wso2carbon</Password>\n\
                <KeyAlias>wso2carbon</KeyAlias>\n\
                <KeyPassword>wso2carbon</KeyPassword>\n\
            </KeyStore>\n\
            <InternalKeyStore>\n\
                <Location>\${carbon.home}/repository/resources/security/wso2carbon.jks</Location>\n\
                <Type>JKS</Type>\n\
                <Password>wso2carbon</Password>\n\
                <KeyAlias>wso2carbon</KeyAlias>\n\
                <KeyPassword>wso2carbon</KeyPassword>\n\
            </InternalKeyStore>\n\
            <TrustStore>\n\
                <Location>\${carbon.home}/repository/resources/security/client-truststore.jks</Location>\n\
                <Type>JKS</Type>\n\
                <Password>wso2carbon</Password>\n\
            </TrustStore>\n\
            <NetworkAuthenticatorConfig>\n\
            </NetworkAuthenticatorConfig>\n\
            <TomcatRealm>UserManager</TomcatRealm>\n\
            <DisableTokenStore>false</DisableTokenStore>\n\
            <XSSPreventionConfig>\n\
                <Enabled>true</Enabled>\n\
                <Rule>allow</Rule>\n\
                <Patterns>\n\
                </Patterns>\n\
            </XSSPreventionConfig>\n\
        </Security>\n\
        <HideMenuItemIds>\n\
            <HideMenuItemId>claim_mgt_menu</HideMenuItemId>\n\
            <HideMenuItemId>identity_mgt_emailtemplate_menu</HideMenuItemId>\n\
            <HideMenuItemId>identity_security_questions_menu</HideMenuItemId>\n\
        </HideMenuItemIds>\n\
        <WorkDirectory>\${carbon.home}/tmp/work</WorkDirectory>\n\
        <HouseKeeping>\n\
            <AutoStart>true</AutoStart>\n\
            <Interval>10</Interval>\n\
            <MaxTempFileLifetime>30</MaxTempFileLifetime>\n\
        </HouseKeeping>\n\
        <FileUploadConfig>\n\
            <TotalFileSizeLimit>100</TotalFileSizeLimit>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>keystore</Action>\n\
                    <Action>certificate</Action>\n\
                    <Action>*</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.AnyFileUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>jarZip</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.JarZipUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>dbs</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.DBSFileUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>tools</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsFileUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>toolsAny</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsAnyFileUploadExecutor</Class>\n\
            </Mapping>\n\
        </FileUploadConfig>\n\
        <HttpGetRequestProcessors>\n\
            <Processor>\n\
                <Item>info</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.InfoProcessor</Class>\n\
            </Processor>\n\
            <Processor>\n\
                <Item>wsdl</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.Wsdl11Processor</Class>\n\
            </Processor>\n\
            <Processor>\n\
                <Item>wsdl2</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.Wsdl20Processor</Class>\n\
            </Processor>\n\
            <Processor>\n\
                <Item>xsd</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.XsdProcessor</Class>\n\
            </Processor>\n\
        </HttpGetRequestProcessors>\n\
        <DeploymentSynchronizer>\n\
            <Enabled>false</Enabled>\n\
            <AutoCommit>false</AutoCommit>\n\
            <AutoCheckout>true</AutoCheckout>\n\
            <RepositoryType>svn</RepositoryType>\n\
            <SvnUrl>http://svnrepo.example.com/repos/</SvnUrl>\n\
            <SvnUser>username</SvnUser>\n\
            <SvnPassword>password</SvnPassword>\n\
            <SvnUrlAppendTenantId>true</SvnUrlAppendTenantId>\n\
        </DeploymentSynchronizer>\n\
        <ServerInitializers>\n\
        </ServerInitializers>\n\
        <RequireCarbonServlet>\${require.carbon.servlet}</RequireCarbonServlet>\n\
        <StatisticsReporterDisabled>true</StatisticsReporterDisabled>\n\
        <FeatureRepository>\n\
            <RepositoryName>default repository</RepositoryName>\n\
            <RepositoryURL>http://product-dist.wso2.com/p2/carbon/releases/wilkes/</RepositoryURL>\n\
        </FeatureRepository>\n\
        <APIManagement>\n\
            <Enabled>true</Enabled>\n\
            <LoadAPIContextsInServerStartup>true</LoadAPIContextsInServerStartup>\n\
        </APIManagement>\n\
    </Server>\n\
kind: ConfigMap\n\
metadata:\n\
  name: apim-conf\n\
  namespace: wso2\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  master-datasources.xml: |\n\
    <datasources-configuration xmlns:svns=\"http://org.wso2.securevault/configuration\">\n\
        <providers>\n\
            <provider>org.wso2.carbon.ndatasource.rdbms.RDBMSDataSourceReader</provider>\n\
        </providers>\n\
        <datasources>\n\
            <datasource>\n\
                <name>WSO2_CARBON_DB</name>\n\
                <description>The datasource used for registry and user manager</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2CarbonDB</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:h2:repository/database/WSO2CARBON_DB;DB_CLOSE_ON_EXIT=FALSE</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>org.h2.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <defaultAutoCommit>true</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2AM_DB</name>\n\
                <description>The datasource used for API Manager database</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2AM_DB</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_APIMGT_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <defaultAutoCommit>false</defaultAutoCommit>\n\
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2UM_DB</name>\n\
                <description>The datasource used by user manager</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2UM_DB</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_COMMON_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2REG_DB</name>\n\
                <description>The datasource used by the registry</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2REG_DB</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_COMMON_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
    		    <defaultAutoCommit>true</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2_MB_STORE_DB</name>\n\
                <description>The datasource used for message broker database</description>\n\
                <jndiConfig>\n\
                    <name>WSO2MBStoreDB</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:h2:repository/database/WSO2MB_DB;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>org.h2.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <defaultAutoCommit>false</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
        </datasources>\n\
    </datasources-configuration>\n\
kind: ConfigMap\n\
metadata:\n\
  name: apim-conf-datasources\n\
  namespace: wso2\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  deployment.yaml: |\n\
    wso2.carbon:\n\
      type: wso2-apim-analytics\n\
      id: wso2-am-analytics\n\
      name: WSO2 API Manager Analytics Server\n\
      ports:\n\
        offset: 1\n\
    wso2.transport.http:\n\
      transportProperties:\n\
        -\n\
          name: \"server.bootstrap.socket.timeout\"\n\
          value: 60\n\
        -\n\
          name: \"client.bootstrap.socket.timeout\"\n\
          value: 60\n\
        -\n\
          name: \"latency.metrics.enabled\"\n\
          value: true\n\
      listenerConfigurations:\n\
        -\n\
          id: \"default\"\n\
          host: \"0.0.0.0\"\n\
          port: 9091\n\
        -\n\
          id: \"msf4j-https\"\n\
          host: \"0.0.0.0\"\n\
          port: 9444\n\
          scheme: https\n\
          keyStoreFile: \"\${carbon.home}/resources/security/wso2carbon.jks\"\n\
          keyStorePassword: wso2carbon\n\
          certPass: wso2carbon\n\
      senderConfigurations:\n\
        -\n\
          id: \"http-sender\"\n\
    siddhi.stores.query.api:\n\
      transportProperties:\n\
        -\n\
          name: \"server.bootstrap.socket.timeout\"\n\
          value: 60\n\
        -\n\
          name: \"client.bootstrap.socket.timeout\"\n\
          value: 60\n\
        -\n\
          name: \"latency.metrics.enabled\"\n\
          value: true\n\
      listenerConfigurations:\n\
        -\n\
          id: \"default\"\n\
          host: \"0.0.0.0\"\n\
          port: 7071\n\
        -\n\
          id: \"msf4j-https\"\n\
          host: \"0.0.0.0\"\n\
          port: 7444\n\
          scheme: https\n\
          keyStoreFile: \"\${carbon.home}/resources/security/wso2carbon.jks\"\n\
          keyStorePassword: wso2carbon\n\
          certPass: wso2carbon\n\
    databridge.config:\n\
      workerThreads: 10\n\
      maxEventBufferCapacity: 10000000\n\
      eventBufferSize: 2000\n\
      keyStoreLocation : \${sys:carbon.home}/resources/security/wso2carbon.jks\n\
      keyStorePassword : wso2carbon\n\
      clientTimeoutMin: 30\n\
      dataReceivers:\n\
      -\n\
        dataReceiver:\n\
          type: Thrift\n\
          properties:\n\
            tcpPort: '7611'\n\
            sslPort: '7711'\n\
      -\n\
        dataReceiver:\n\
          type: Binary\n\
          properties:\n\
            tcpPort: '9611'\n\
            sslPort: '9711'\n\
            tcpReceiverThreadPoolSize: '100'\n\
            sslReceiverThreadPoolSize: '100'\n\
            hostName: 0.0.0.0\n\
    data.agent.config:\n\
      agents:\n\
      -\n\
        agentConfiguration:\n\
          name: Thrift\n\
          dataEndpointClass: org.wso2.carbon.databridge.agent.endpoint.thrift.ThriftDataEndpoint\n\
          publishingStrategy: async\n\
          trustStorePath: '\${sys:carbon.home}/resources/security/client-truststore.jks'\n\
          trustStorePassword: 'wso2carbon'\n\
          queueSize: 32768\n\
          batchSize: 200\n\
          corePoolSize: 1\n\
          socketTimeoutMS: 30000\n\
          maxPoolSize: 1\n\
          keepAliveTimeInPool: 20\n\
          reconnectionInterval: 30\n\
          maxTransportPoolSize: 250\n\
          maxIdleConnections: 250\n\
          evictionTimePeriod: 5500\n\
          minIdleTimeInPool: 5000\n\
          secureMaxTransportPoolSize: 250\n\
          secureMaxIdleConnections: 250\n\
          secureEvictionTimePeriod: 5500\n\
          secureMinIdleTimeInPool: 5000\n\
          sslEnabledProtocols: TLSv1.1,TLSv1.2\n\
          ciphers: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256\n\
      -\n\
        agentConfiguration:\n\
          name: Binary\n\
          dataEndpointClass: org.wso2.carbon.databridge.agent.endpoint.binary.BinaryDataEndpoint\n\
          publishingStrategy: async\n\
          trustStorePath: '\${sys:carbon.home}/resources/security/client-truststore.jks'\n\
          trustStorePassword: 'wso2carbon'\n\
          queueSize: 32768\n\
          batchSize: 200\n\
          corePoolSize: 1\n\
          socketTimeoutMS: 30000\n\
          maxPoolSize: 1\n\
          keepAliveTimeInPool: 20\n\
          reconnectionInterval: 30\n\
          maxTransportPoolSize: 250\n\
          maxIdleConnections: 250\n\
          evictionTimePeriod: 5500\n\
          minIdleTimeInPool: 5000\n\
          secureMaxTransportPoolSize: 250\n\
          secureMaxIdleConnections: 250\n\
          secureEvictionTimePeriod: 5500\n\
          secureMinIdleTimeInPool: 5000\n\
          sslEnabledProtocols: TLSv1.1,TLSv1.2\n\
          ciphers: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256\n\
    wso2.metrics:\n\
      enabled: false\n\
      reporting:\n\
        console:\n\
          -\n\
            name: Console\n\
            enabled: false\n\
            pollingPeriod: 5\n\
    wso2.metrics.jdbc:\n\
      dataSource:\n\
        - &JDBC01\n\
          dataSourceName: java:comp/env/jdbc/WSO2MetricsDB\n\
          scheduledCleanup:\n\
            enabled: true\n\
            daysToKeep: 3\n\
            scheduledCleanupPeriod: 86400\n\
      reporting:\n\
        jdbc:\n\
          -\n\
            name: JDBC\n\
            enabled: true\n\
            dataSource: *JDBC01\n\
            pollingPeriod: 60\n\
    wso2.artifact.deployment:\n\
      updateInterval: 5\n\
    state.persistence:\n\
      enabled: false\n\
      intervalInMin: 1\n\
      revisionsToKeep: 2\n\
      persistenceStore: org.wso2.carbon.stream.processor.core.persistence.FileSystemPersistenceStore\n\
      config:\n\
        location: siddhi-app-persistence\n\
    wso2.securevault:\n\
      secretRepository:\n\
        type: org.wso2.carbon.secvault.repository.DefaultSecretRepository\n\
        parameters:\n\
          privateKeyAlias: wso2carbon\n\
          keystoreLocation: \${sys:carbon.home}/resources/security/securevault.jks\n\
          secretPropertiesFile: \${sys:carbon.home}/conf/\${sys:wso2.runtime}/secrets.properties\n\
      masterKeyReader:\n\
        type: org.wso2.carbon.secvault.reader.DefaultMasterKeyReader\n\
        parameters:\n\
          masterKeyReaderFile: \${sys:carbon.home}/conf/\${sys:wso2.runtime}/master-keys.yaml\n\
    wso2.datasources:\n\
      dataSources:\n\
        -\n\
          definition:\n\
            configuration:\n\
              connectionTestQuery: \"SELECT 1\"\n\
              driverClassName: com.mysql.jdbc.Driver\n\
              idleTimeout: 60000\n\
              isAutoCommit: false\n\
              jdbcUrl: 'jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_COMMON_DB?useSSL=false'\n\
              maxPoolSize: 50\n\
              password: wso2carbon\n\
              username: wso2carbon\n\
              validationTimeout: 30000\n\
            type: RDBMS\n\
          description: \"The datasource used for registry and user manager\"\n\
          name: WSO2_CARBON_DB\n\
        - name: WSO2_METRICS_DB\n\
          description: The datasource used for dashboard feature\n\
          jndiConfig:\n\
            name: jdbc/WSO2MetricsDB\n\
          definition:\n\
            type: RDBMS\n\
            configuration:\n\
              jdbcUrl: 'jdbc:h2:\${sys:carbon.home}/wso2/dashboard/database/metrics;AUTO_SERVER=TRUE'\n\
              username: wso2carbon\n\
              password: wso2carbon\n\
              driverClassName: org.h2.Driver\n\
              maxPoolSize: 30\n\
              idleTimeout: 60000\n\
              connectionTestQuery: SELECT 1\n\
              validationTimeout: 30000\n\
              isAutoCommit: false\n\
        - name: WSO2_PERMISSIONS_DB\n\
          description: The datasource used for permission feature\n\
          jndiConfig:\n\
            name: jdbc/PERMISSION_DB\n\
            useJndiReference: true\n\
          definition:\n\
            type: RDBMS\n\
            configuration:\n\
              jdbcUrl: 'jdbc:h2:\${sys:carbon.home}/wso2/\${sys:wso2.runtime}/database/PERMISSION_DB;IFEXISTS=TRUE;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000;MVCC=TRUE'\n\
              username: wso2carbon\n\
              password: wso2carbon\n\
              driverClassName: org.h2.Driver\n\
              maxPoolSize: 10\n\
              idleTimeout: 60000\n\
              connectionTestQuery: SELECT 1\n\
              validationTimeout: 30000\n\
              isAutoCommit: false\n\
        - name: Message_Tracing_DB\n\
          description: \"The datasource used for message tracer to store span information.\"\n\
          jndiConfig:\n\
            name: jdbc/Message_Tracing_DB\n\
          definition:\n\
            type: RDBMS\n\
            configuration:\n\
              jdbcUrl: 'jdbc:h2:\${sys:carbon.home}/wso2/dashboard/database/MESSAGE_TRACING_DB;AUTO_SERVER=TRUE'\n\
              username: wso2carbon\n\
              password: wso2carbon\n\
              driverClassName: org.h2.Driver\n\
              maxPoolSize: 50\n\
              idleTimeout: 60000\n\
              connectionTestQuery: SELECT 1\n\
              validationTimeout: 30000\n\
              isAutoCommit: false\n\
        - name: GEO_LOCATION_DATA\n\
          description: \"The data source used for geo location database\"\n\
          jndiConfig:\n\
            name: jdbc/GEO_LOCATION_DATA\n\
          definition:\n\
            type: RDBMS\n\
            configuration:\n\
              jdbcUrl: 'jdbc:h2:\${sys:carbon.home}/wso2/worker/database/GEO_LOCATION_DATA;AUTO_SERVER=TRUE'\n\
              username: wso2carbon\n\
              password: wso2carbon\n\
              driverClassName: org.h2.Driver\n\
              maxPoolSize: 50\n\
              idleTimeout: 60000\n\
              validationTimeout: 30000\n\
              isAutoCommit: false\n\
        - name: APIM_ANALYTICS_DB\n\
          description: \"The datasource used for APIM statistics aggregated data.\"\n\
          jndiConfig:\n\
            name: jdbc/APIM_ANALYTICS_DB\n\
          definition:\n\
            type: RDBMS\n\
            configuration:\n\
              jdbcUrl: 'jdbc:mysql://wso2apim-with-analytics-rdbms-service:3306/WSO2AM_STAT_DB?useSSL=false'\n\
              username: wso2carbon\n\
              password: wso2carbon\n\
              driverClassName: com.mysql.jdbc.Driver\n\
              maxPoolSize: 50\n\
              idleTimeout: 60000\n\
              connectionTestQuery: SELECT 1\n\
              validationTimeout: 30000\n\
              isAutoCommit: false\n\
        - name: WSO2AM_MGW_ANALYTICS_DB\n\
          description: \"The datasource used for APIM MGW analytics data.\"\n\
          jndiConfig:\n\
            name: jdbc/WSO2AM_MGW_ANALYTICS_DB\n\
          definition:\n\
            type: RDBMS\n\
            configuration:\n\
              jdbcUrl: 'jdbc:h2:\${sys:carbon.home}/wso2/worker/database/WSO2AM_MGW_ANALYTICS_DB;AUTO_SERVER=TRUE'\n\
              username: wso2carbon\n\
              password: wso2carbon\n\
              driverClassName: org.h2.Driver\n\
              maxPoolSize: 50\n\
              idleTimeout: 60000\n\
              connectionTestQuery: SELECT 1\n\
              validationTimeout: 30000\n\
              isAutoCommit: false\n\
    siddhi:\n\
      extensions:\n\
        -\n\
          extension:\n\
            name: 'findCountryFromIP'\n\
            namespace: 'geo'\n\
            properties:\n\
              geoLocationResolverClass: org.wso2.extension.siddhi.execution.geo.internal.impl.DefaultDBBasedGeoLocationResolver\n\
              isCacheEnabled: true\n\
              cacheSize: 10000\n\
              isPersistInDatabase: true\n\
              datasource: GEO_LOCATION_DATA\n\
        -\n\
          extension:\n\
            name: 'findCityFromIP'\n\
            namespace: 'geo'\n\
            properties:\n\
              geoLocationResolverClass: org.wso2.extension.siddhi.execution.geo.internal.impl.DefaultDBBasedGeoLocationResolver\n\
              isCacheEnabled: true\n\
              cacheSize: 10000\n\
              isPersistInDatabase: true\n\
              datasource: GEO_LOCATION_DATA\n\
    cluster.config:\n\
      enabled: false\n\
      groupId:  sp\n\
      coordinationStrategyClass: org.wso2.carbon.cluster.coordinator.rdbms.RDBMSCoordinationStrategy\n\
      strategyConfig:\n\
        datasource: WSO2_CARBON_DB\n\
        heartbeatInterval: 1000\n\
        heartbeatMaxRetry: 2\n\
        eventPollingInterval: 1000\n\
kind: ConfigMap\n\
metadata:\n\
  name: apim-analytics-conf-worker\n\
  namespace: wso2\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  init.sql: |\n\
    DROP DATABASE IF EXISTS WSO2AM_COMMON_DB;\n\
    DROP DATABASE IF EXISTS WSO2AM_APIMGT_DB;\n\
    DROP DATABASE IF EXISTS WSO2AM_STAT_DB;\n\
    CREATE DATABASE WSO2AM_COMMON_DB;\n\
    CREATE DATABASE WSO2AM_APIMGT_DB;\n\
    CREATE DATABASE WSO2AM_STAT_DB;\n\
    CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    GRANT ALL ON WSO2AM_COMMON_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    GRANT ALL ON WSO2AM_APIMGT_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    GRANT ALL ON WSO2AM_STAT_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    USE WSO2AM_COMMON_DB;\n\
    CREATE TABLE IF NOT EXISTS REG_CLUSTER_LOCK (\n\
                 REG_LOCK_NAME VARCHAR (20),\n\
                 REG_LOCK_STATUS VARCHAR (20),\n\
                 REG_LOCKED_TIME TIMESTAMP,\n\
                 REG_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (REG_LOCK_NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_LOG (\n\
                 REG_LOG_ID INTEGER AUTO_INCREMENT,\n\
                 REG_PATH VARCHAR (750),\n\
                 REG_USER_ID VARCHAR (31) NOT NULL,\n\
                 REG_LOGGED_TIME TIMESTAMP NOT NULL,\n\
                 REG_ACTION INTEGER NOT NULL,\n\
                 REG_ACTION_DATA VARCHAR (500),\n\
                 REG_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (REG_LOG_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX REG_LOG_IND_BY_REGLOG USING HASH ON REG_LOG(REG_LOGGED_TIME, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_PATH(\n\
                 REG_PATH_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 REG_PATH_VALUE VARCHAR(750) NOT NULL,\n\
                 REG_PATH_PARENT_ID INTEGER,\n\
                 REG_TENANT_ID INTEGER DEFAULT 0,\n\
                 CONSTRAINT PK_REG_PATH PRIMARY KEY(REG_PATH_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX REG_PATH_IND_BY_PATH_VALUE USING HASH ON REG_PATH(REG_PATH_VALUE, REG_TENANT_ID);\n\
    CREATE INDEX REG_PATH_IND_BY_PATH_PARENT_ID USING HASH ON REG_PATH(REG_PATH_PARENT_ID, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_CONTENT (\n\
                 REG_CONTENT_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 REG_CONTENT_DATA LONGBLOB,\n\
                 REG_TENANT_ID INTEGER DEFAULT 0,\n\
                 CONSTRAINT PK_REG_CONTENT PRIMARY KEY(REG_CONTENT_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_CONTENT_HISTORY (\n\
                 REG_CONTENT_ID INTEGER NOT NULL,\n\
                 REG_CONTENT_DATA LONGBLOB,\n\
                 REG_DELETED   SMALLINT,\n\
                 REG_TENANT_ID INTEGER DEFAULT 0,\n\
                 CONSTRAINT PK_REG_CONTENT_HISTORY PRIMARY KEY(REG_CONTENT_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_RESOURCE (\n\
                REG_PATH_ID         INTEGER NOT NULL,\n\
                REG_NAME            VARCHAR(256),\n\
                REG_VERSION         INTEGER NOT NULL AUTO_INCREMENT,\n\
                REG_MEDIA_TYPE      VARCHAR(500),\n\
                REG_CREATOR         VARCHAR(31) NOT NULL,\n\
                REG_CREATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                REG_LAST_UPDATOR    VARCHAR(31),\n\
                REG_LAST_UPDATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                REG_DESCRIPTION     VARCHAR(1000),\n\
                REG_CONTENT_ID      INTEGER,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                REG_UUID VARCHAR(100) NOT NULL,\n\
                CONSTRAINT PK_REG_RESOURCE PRIMARY KEY(REG_VERSION, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_CONTENT_ID FOREIGN KEY (REG_CONTENT_ID, REG_TENANT_ID) REFERENCES REG_CONTENT (REG_CONTENT_ID, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_IND_BY_NAME USING HASH ON REG_RESOURCE(REG_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_IND_BY_PATH_ID_NAME USING HASH ON REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_IND_BY_UUID USING HASH ON REG_RESOURCE(REG_UUID);\n\
    CREATE INDEX REG_RESOURCE_IND_BY_TENAN USING HASH ON REG_RESOURCE(REG_TENANT_ID, REG_UUID);\n\
    CREATE INDEX REG_RESOURCE_IND_BY_TYPE USING HASH ON REG_RESOURCE(REG_TENANT_ID, REG_MEDIA_TYPE);\n\
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_HISTORY (\n\
                REG_PATH_ID         INTEGER NOT NULL,\n\
                REG_NAME            VARCHAR(256),\n\
                REG_VERSION         INTEGER NOT NULL,\n\
                REG_MEDIA_TYPE      VARCHAR(500),\n\
                REG_CREATOR         VARCHAR(31) NOT NULL,\n\
                REG_CREATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                REG_LAST_UPDATOR    VARCHAR(31),\n\
                REG_LAST_UPDATED_TIME    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                REG_DESCRIPTION     VARCHAR(1000),\n\
                REG_CONTENT_ID      INTEGER,\n\
                REG_DELETED         SMALLINT,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                REG_UUID VARCHAR(100) NOT NULL,\n\
                CONSTRAINT PK_REG_RESOURCE_HISTORY PRIMARY KEY(REG_VERSION, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE REG_RESOURCE_HISTORY ADD CONSTRAINT REG_RESOURCE_HIST_FK_BY_PATHID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    ALTER TABLE REG_RESOURCE_HISTORY ADD CONSTRAINT REG_RESOURCE_HIST_FK_BY_CONTENT_ID FOREIGN KEY (REG_CONTENT_ID, REG_TENANT_ID) REFERENCES REG_CONTENT_HISTORY (REG_CONTENT_ID, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_HISTORY_IND_BY_NAME USING HASH ON REG_RESOURCE_HISTORY(REG_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_HISTORY_IND_BY_PATH_ID_NAME USING HASH ON REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_COMMENT (\n\
                REG_ID        INTEGER NOT NULL AUTO_INCREMENT,\n\
                REG_COMMENT_TEXT      VARCHAR(500) NOT NULL,\n\
                REG_USER_ID           VARCHAR(31) NOT NULL,\n\
                REG_COMMENTED_TIME    TIMESTAMP NOT NULL,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                CONSTRAINT PK_REG_COMMENT PRIMARY KEY(REG_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_COMMENT (\n\
                REG_COMMENT_ID          INTEGER NOT NULL,\n\
                REG_VERSION             INTEGER,\n\
                REG_PATH_ID             INTEGER,\n\
                REG_RESOURCE_NAME       VARCHAR(256),\n\
                REG_TENANT_ID INTEGER DEFAULT 0\n\
    )ENGINE INNODB;\n\
    ALTER TABLE REG_RESOURCE_COMMENT ADD CONSTRAINT REG_RESOURCE_COMMENT_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    ALTER TABLE REG_RESOURCE_COMMENT ADD CONSTRAINT REG_RESOURCE_COMMENT_FK_BY_COMMENT_ID FOREIGN KEY (REG_COMMENT_ID, REG_TENANT_ID) REFERENCES REG_COMMENT (REG_ID, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_COMMENT_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_COMMENT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_COMMENT_IND_BY_VERSION USING HASH ON REG_RESOURCE_COMMENT(REG_VERSION, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_RATING (\n\
                REG_ID     INTEGER NOT NULL AUTO_INCREMENT,\n\
                REG_RATING        INTEGER NOT NULL,\n\
                REG_USER_ID       VARCHAR(31) NOT NULL,\n\
                REG_RATED_TIME    TIMESTAMP NOT NULL,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                CONSTRAINT PK_REG_RATING PRIMARY KEY(REG_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_RATING (\n\
                REG_RATING_ID           INTEGER NOT NULL,\n\
                REG_VERSION             INTEGER,\n\
                REG_PATH_ID             INTEGER,\n\
                REG_RESOURCE_NAME       VARCHAR(256),\n\
                REG_TENANT_ID INTEGER DEFAULT 0\n\
    )ENGINE INNODB;\n\
    ALTER TABLE REG_RESOURCE_RATING ADD CONSTRAINT REG_RESOURCE_RATING_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    ALTER TABLE REG_RESOURCE_RATING ADD CONSTRAINT REG_RESOURCE_RATING_FK_BY_RATING_ID FOREIGN KEY (REG_RATING_ID, REG_TENANT_ID) REFERENCES REG_RATING (REG_ID, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_RATING_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_RATING(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_RATING_IND_BY_VERSION USING HASH ON REG_RESOURCE_RATING(REG_VERSION, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_TAG (\n\
                REG_ID         INTEGER NOT NULL AUTO_INCREMENT,\n\
                REG_TAG_NAME       VARCHAR(500) NOT NULL,\n\
                REG_USER_ID        VARCHAR(31) NOT NULL,\n\
                REG_TAGGED_TIME    TIMESTAMP NOT NULL,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                CONSTRAINT PK_REG_TAG PRIMARY KEY(REG_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_TAG (\n\
                REG_TAG_ID              INTEGER NOT NULL,\n\
                REG_VERSION             INTEGER,\n\
                REG_PATH_ID             INTEGER,\n\
                REG_RESOURCE_NAME       VARCHAR(256),\n\
                REG_TENANT_ID INTEGER DEFAULT 0\n\
    )ENGINE INNODB;\n\
    ALTER TABLE REG_RESOURCE_TAG ADD CONSTRAINT REG_RESOURCE_TAG_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    ALTER TABLE REG_RESOURCE_TAG ADD CONSTRAINT REG_RESOURCE_TAG_FK_BY_TAG_ID FOREIGN KEY (REG_TAG_ID, REG_TENANT_ID) REFERENCES REG_TAG (REG_ID, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_TAG_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_TAG(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_TAG_IND_BY_VERSION USING HASH ON REG_RESOURCE_TAG(REG_VERSION, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_PROPERTY (\n\
                REG_ID         INTEGER NOT NULL AUTO_INCREMENT,\n\
                REG_NAME       VARCHAR(100) NOT NULL,\n\
                REG_VALUE        VARCHAR(1000),\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                CONSTRAINT PK_REG_PROPERTY PRIMARY KEY(REG_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_RESOURCE_PROPERTY (\n\
                REG_PROPERTY_ID         INTEGER NOT NULL,\n\
                REG_VERSION             INTEGER,\n\
                REG_PATH_ID             INTEGER,\n\
                REG_RESOURCE_NAME       VARCHAR(256),\n\
                REG_TENANT_ID INTEGER DEFAULT 0\n\
    )ENGINE INNODB;\n\
    ALTER TABLE REG_RESOURCE_PROPERTY ADD CONSTRAINT REG_RESOURCE_PROPERTY_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    ALTER TABLE REG_RESOURCE_PROPERTY ADD CONSTRAINT REG_RESOURCE_PROPERTY_FK_BY_TAG_ID FOREIGN KEY (REG_PROPERTY_ID, REG_TENANT_ID) REFERENCES REG_PROPERTY (REG_ID, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_PROPERTY_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_PROPERTY(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);\n\
    CREATE INDEX REG_RESOURCE_PROPERTY_IND_BY_VERSION USING HASH ON REG_RESOURCE_PROPERTY(REG_VERSION, REG_TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS REG_ASSOCIATION (\n\
                REG_ASSOCIATION_ID INTEGER AUTO_INCREMENT,\n\
                REG_SOURCEPATH VARCHAR (750) NOT NULL,\n\
                REG_TARGETPATH VARCHAR (750) NOT NULL,\n\
                REG_ASSOCIATION_TYPE VARCHAR (2000) NOT NULL,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (REG_ASSOCIATION_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS REG_SNAPSHOT (\n\
                REG_SNAPSHOT_ID     INTEGER NOT NULL AUTO_INCREMENT,\n\
                REG_PATH_ID            INTEGER NOT NULL,\n\
                REG_RESOURCE_NAME      VARCHAR(255),\n\
                REG_RESOURCE_VIDS     LONGBLOB NOT NULL,\n\
                REG_TENANT_ID INTEGER DEFAULT 0,\n\
                CONSTRAINT PK_REG_SNAPSHOT PRIMARY KEY(REG_SNAPSHOT_ID, REG_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX REG_SNAPSHOT_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_SNAPSHOT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);\n\
    ALTER TABLE REG_SNAPSHOT ADD CONSTRAINT REG_SNAPSHOT_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);\n\
    CREATE TABLE UM_TENANT (\n\
    			UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	        UM_DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                UM_EMAIL VARCHAR(255),\n\
                UM_ACTIVE BOOLEAN DEFAULT FALSE,\n\
    	        UM_CREATED_DATE TIMESTAMP NOT NULL,\n\
    	        UM_USER_CONFIG LONGBLOB,\n\
    			PRIMARY KEY (UM_ID),\n\
    			UNIQUE(UM_DOMAIN_NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_DOMAIN(\n\
                UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DOMAIN_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME\n\
                        ON UM_TENANT (UM_DOMAIN_NAME);\n\
    CREATE TABLE UM_USER (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,\n\
                 UM_SALT_VALUE VARCHAR(31),\n\
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,\n\
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SYSTEM_USER (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,\n\
                 UM_SALT_VALUE VARCHAR(31),\n\
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,\n\
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_ROLE (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    		UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_ROLE_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_MODULE(\n\
    	UM_ID INTEGER  NOT NULL AUTO_INCREMENT,\n\
    	UM_MODULE_NAME VARCHAR(100),\n\
    	UNIQUE(UM_MODULE_NAME),\n\
    	PRIMARY KEY(UM_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_MODULE_ACTIONS(\n\
    	UM_ACTION VARCHAR(255) NOT NULL,\n\
    	UM_MODULE_ID INTEGER NOT NULL,\n\
    	PRIMARY KEY(UM_ACTION, UM_MODULE_ID),\n\
    	FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_RESOURCE_ID VARCHAR(255) NOT NULL,\n\
                 UM_ACTION VARCHAR(255) NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    		UM_MODULE_ID INTEGER DEFAULT 0,\n\
    			       UNIQUE(UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);\n\
    CREATE TABLE UM_ROLE_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_PERMISSION_ID INTEGER NOT NULL,\n\
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,\n\
                 UM_IS_ALLOWED SMALLINT NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    	     UM_DOMAIN_ID INTEGER,\n\
                 UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),\n\
    	     FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
    	     FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    -- REMOVED UNIQUE (UM_PERMISSION_ID, UM_ROLE_ID)\n\
    CREATE TABLE UM_USER_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_PERMISSION_ID INTEGER NOT NULL,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_IS_ALLOWED SMALLINT NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    -- REMOVED UNIQUE (UM_PERMISSION_ID, UM_USER_ID)\n\
    CREATE TABLE UM_USER_ROLE (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_ROLE_ID INTEGER NOT NULL,\n\
                 UM_USER_ID INTEGER NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),\n\
                 FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID),\n\
                 FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SHARED_USER_ROLE(\n\
        UM_ROLE_ID INTEGER NOT NULL,\n\
        UM_USER_ID INTEGER NOT NULL,\n\
        UM_USER_TENANT_ID INTEGER NOT NULL,\n\
        UM_ROLE_TENANT_ID INTEGER NOT NULL,\n\
        UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),\n\
        FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,\n\
        FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_ACCOUNT_MAPPING(\n\
    	UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	UM_USER_NAME VARCHAR(255) NOT NULL,\n\
    	UM_TENANT_ID INTEGER NOT NULL,\n\
    	UM_USER_STORE_DOMAIN VARCHAR(100),\n\
    	UM_ACC_LINK_ID INTEGER NOT NULL,\n\
    	UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),\n\
    	FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,\n\
    	PRIMARY KEY (UM_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_ATTRIBUTE (\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ATTR_NAME VARCHAR(255) NOT NULL,\n\
                UM_ATTR_VALUE VARCHAR(1024),\n\
                UM_PROFILE_ID VARCHAR(255),\n\
                UM_USER_ID INTEGER,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX UM_USER_ID_INDEX ON UM_USER_ATTRIBUTE(UM_USER_ID);\n\
    CREATE TABLE UM_DIALECT(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_URI VARCHAR(255) NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE(UM_DIALECT_URI, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_CLAIM(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_ID INTEGER NOT NULL,\n\
                UM_CLAIM_URI VARCHAR(255) NOT NULL,\n\
                UM_DISPLAY_TAG VARCHAR(255),\n\
                UM_DESCRIPTION VARCHAR(255),\n\
                UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),\n\
                UM_MAPPED_ATTRIBUTE VARCHAR(255),\n\
                UM_REG_EX VARCHAR(255),\n\
                UM_SUPPORTED SMALLINT,\n\
                UM_REQUIRED SMALLINT,\n\
                UM_DISPLAY_ORDER INTEGER,\n\
    	    UM_CHECKED_ATTRIBUTE SMALLINT,\n\
                UM_READ_ONLY SMALLINT,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN),\n\
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_PROFILE_CONFIG(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_ID INTEGER NOT NULL,\n\
                UM_PROFILE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS UM_CLAIM_BEHAVIOR(\n\
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
        UM_PROFILE_ID INTEGER,\n\
        UM_CLAIM_ID INTEGER,\n\
        UM_BEHAVIOUR SMALLINT,\n\
        UM_TENANT_ID INTEGER DEFAULT 0,\n\
        FOREIGN KEY(UM_PROFILE_ID, UM_TENANT_ID) REFERENCES UM_PROFILE_CONFIG(UM_ID,UM_TENANT_ID),\n\
        FOREIGN KEY(UM_CLAIM_ID, UM_TENANT_ID) REFERENCES UM_CLAIM(UM_ID,UM_TENANT_ID),\n\
        PRIMARY KEY(UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ROLE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_USER_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_USER_NAME VARCHAR(255),\n\
                UM_ROLE_ID INTEGER NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
    	    UM_DOMAIN_ID INTEGER,\n\
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),\n\
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
    	    FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SYSTEM_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ROLE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX SYSTEM_ROLE_IND_BY_RN_TI ON UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID);\n\
    CREATE TABLE UM_SYSTEM_USER_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_USER_NAME VARCHAR(255),\n\
                UM_ROLE_ID INTEGER NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),\n\
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_REMEMBER_ME(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    			UM_USER_NAME VARCHAR(255) NOT NULL,\n\
    			UM_COOKIE_VALUE VARCHAR(1024),\n\
    			UM_CREATED_TIME TIMESTAMP,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
    			PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    USE WSO2AM_APIMGT_DB;\n\
    -- Start of IDENTITY Tables--\n\
    CREATE TABLE IF NOT EXISTS IDN_BASE_TABLE (\n\
                PRODUCT_NAME VARCHAR(20),\n\
                PRIMARY KEY (PRODUCT_NAME)\n\
    )ENGINE INNODB;\n\
    INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                CONSUMER_KEY VARCHAR(255),\n\
                CONSUMER_SECRET VARCHAR(2048),\n\
                USERNAME VARCHAR(255),\n\
                TENANT_ID INTEGER DEFAULT 0,\n\
                USER_DOMAIN VARCHAR(50),\n\
                APP_NAME VARCHAR(255),\n\
                OAUTH_VERSION VARCHAR(128),\n\
                CALLBACK_URL VARCHAR(1024),\n\
                GRANT_TYPES VARCHAR (1024),\n\
                PKCE_MANDATORY CHAR(1) DEFAULT '0',\n\
                PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',\n\
                APP_STATE VARCHAR (25) DEFAULT 'ACTIVE',\n\
                USER_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,\n\
                APP_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,\n\
                REFRESH_TOKEN_EXPIRE_TIME BIGINT DEFAULT 84600,\n\
                ID_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,\n\
                CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_VALIDATORS (\n\
    	APP_ID INTEGER NOT NULL,\n\
    	SCOPE_VALIDATOR VARCHAR (128) NOT NULL,\n\
    	PRIMARY KEY (APP_ID,SCOPE_VALIDATOR),\n\
    	FOREIGN KEY (APP_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_REQUEST_TOKEN (\n\
                REQUEST_TOKEN VARCHAR(255),\n\
                REQUEST_TOKEN_SECRET VARCHAR(512),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                CALLBACK_URL VARCHAR(1024),\n\
                SCOPE VARCHAR(2048),\n\
                AUTHORIZED VARCHAR(128),\n\
                OAUTH_VERIFIER VARCHAR(512),\n\
                AUTHZ_USER VARCHAR(512),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (REQUEST_TOKEN),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_ACCESS_TOKEN (\n\
                ACCESS_TOKEN VARCHAR(255),\n\
                ACCESS_TOKEN_SECRET VARCHAR(512),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                SCOPE VARCHAR(2048),\n\
                AUTHZ_USER VARCHAR(512),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ACCESS_TOKEN),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN (\n\
                TOKEN_ID VARCHAR (255),\n\
                ACCESS_TOKEN VARCHAR(2048),\n\
                REFRESH_TOKEN VARCHAR(2048),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                AUTHZ_USER VARCHAR (100),\n\
                TENANT_ID INTEGER,\n\
                USER_DOMAIN VARCHAR(50),\n\
                USER_TYPE VARCHAR (25),\n\
                GRANT_TYPE VARCHAR (50),\n\
                TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                VALIDITY_PERIOD BIGINT,\n\
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,\n\
                TOKEN_SCOPE_HASH VARCHAR(32),\n\
                TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',\n\
                TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',\n\
                SUBJECT_IDENTIFIER VARCHAR(255),\n\
                ACCESS_TOKEN_HASH VARCHAR(512),\n\
                REFRESH_TOKEN_HASH VARCHAR(512),\n\
                PRIMARY KEY (TOKEN_ID),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,\n\
                CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,\n\
                                               TOKEN_STATE,TOKEN_STATE_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);\n\
    CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);\n\
    CREATE INDEX IDX_ATH ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN_HASH);\n\
    CREATE INDEX IDX_AT_TI_UD ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, TENANT_ID, TOKEN_STATE, USER_DOMAIN);\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_AUDIT (\n\
                TOKEN_ID VARCHAR (255),\n\
                ACCESS_TOKEN VARCHAR(2048),\n\
                REFRESH_TOKEN VARCHAR(2048),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                AUTHZ_USER VARCHAR (100),\n\
                TENANT_ID INTEGER,\n\
                USER_DOMAIN VARCHAR(50),\n\
                USER_TYPE VARCHAR (25),\n\
                GRANT_TYPE VARCHAR (50),\n\
                TIME_CREATED TIMESTAMP NULL,\n\
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NULL,\n\
                VALIDITY_PERIOD BIGINT,\n\
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,\n\
                TOKEN_SCOPE_HASH VARCHAR(32),\n\
                TOKEN_STATE VARCHAR(25),\n\
                TOKEN_STATE_ID VARCHAR (128) ,\n\
                SUBJECT_IDENTIFIER VARCHAR(255),\n\
                ACCESS_TOKEN_HASH VARCHAR(512),\n\
                REFRESH_TOKEN_HASH VARCHAR(512),\n\
                INVALIDATED_TIME TIMESTAMP NULL\n\
    );\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE (\n\
                CODE_ID VARCHAR (255),\n\
                AUTHORIZATION_CODE VARCHAR(2048),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                CALLBACK_URL VARCHAR(1024),\n\
                SCOPE VARCHAR(2048),\n\
                AUTHZ_USER VARCHAR (100),\n\
                TENANT_ID INTEGER,\n\
                USER_DOMAIN VARCHAR(50),\n\
                TIME_CREATED TIMESTAMP,\n\
                VALIDITY_PERIOD BIGINT,\n\
                STATE VARCHAR (25) DEFAULT 'ACTIVE',\n\
                TOKEN_ID VARCHAR(255),\n\
                SUBJECT_IDENTIFIER VARCHAR(255),\n\
                PKCE_CODE_CHALLENGE VARCHAR(255),\n\
                PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),\n\
                AUTHORIZATION_CODE_HASH VARCHAR(512),\n\
                PRIMARY KEY (CODE_ID),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_AUTHORIZATION_CODE_HASH ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHORIZATION_CODE_HASH,CONSUMER_KEY_ID);\n\
    CREATE INDEX IDX_AUTHORIZATION_CODE_AU_TI ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHZ_USER,TENANT_ID, USER_DOMAIN, STATE);\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_SCOPE (\n\
                TOKEN_ID VARCHAR (255),\n\
                TOKEN_SCOPE VARCHAR (60),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),\n\
                FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE (\n\
                SCOPE_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(255) NOT NULL,\n\
                DESCRIPTION VARCHAR(512),\n\
                TENANT_ID INTEGER NOT NULL DEFAULT -1,\n\
                PRIMARY KEY (SCOPE_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_BINDING (\n\
                SCOPE_ID INTEGER NOT NULL,\n\
                SCOPE_BINDING VARCHAR(255),\n\
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE(SCOPE_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_RESOURCE_SCOPE (\n\
                RESOURCE_PATH VARCHAR(255) NOT NULL,\n\
                SCOPE_ID INTEGER NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (RESOURCE_PATH),\n\
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_SCIM_GROUP (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                ROLE_NAME VARCHAR(255) NOT NULL,\n\
                ATTR_NAME VARCHAR(1024) NOT NULL,\n\
                ATTR_VALUE VARCHAR(1024),\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME);\n\
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN_AN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME, ATTR_NAME);\n\
    CREATE TABLE IF NOT EXISTS IDN_OPENID_REMEMBER_ME (\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT 0,\n\
                COOKIE_VALUE VARCHAR(1024),\n\
                CREATED_TIME TIMESTAMP,\n\
                PRIMARY KEY (USER_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OPENID_USER_RPS (\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT 0,\n\
                RP_URL VARCHAR(255) NOT NULL,\n\
                TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',\n\
                LAST_VISIT DATE NOT NULL,\n\
                VISIT_COUNT INTEGER DEFAULT 0,\n\
                DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',\n\
                PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OPENID_ASSOCIATIONS (\n\
                HANDLE VARCHAR(255) NOT NULL,\n\
                ASSOC_TYPE VARCHAR(255) NOT NULL,\n\
                EXPIRE_IN TIMESTAMP NOT NULL,\n\
                MAC_KEY VARCHAR(255) NOT NULL,\n\
                ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (HANDLE)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_STS_STORE (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TOKEN_ID VARCHAR(255) NOT NULL,\n\
                TOKEN_CONTENT BLOB(1024) NOT NULL,\n\
                CREATE_DATE TIMESTAMP NOT NULL,\n\
                EXPIRE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                STATE INTEGER DEFAULT 0,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_USER_DATA (\n\
                TENANT_ID INTEGER DEFAULT -1234,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                DATA_KEY VARCHAR(255) NOT NULL,\n\
                DATA_VALUE VARCHAR(2048),\n\
                PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_META_DATA (\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1234,\n\
                METADATA_TYPE VARCHAR(255) NOT NULL,\n\
                METADATA VARCHAR(255) NOT NULL,\n\
                VALID VARCHAR(255) NOT NULL,\n\
                PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (\n\
                SESSION_ID VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                CREATED_TIME VARCHAR(255) NOT NULL,\n\
                LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (SESSION_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_AUTH_SESSION_STORE (\n\
                SESSION_ID VARCHAR (100) NOT NULL,\n\
                SESSION_TYPE VARCHAR(100) NOT NULL,\n\
                OPERATION VARCHAR(10) NOT NULL,\n\
                SESSION_OBJECT BLOB,\n\
                TIME_CREATED BIGINT,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                EXPIRY_TIME BIGINT,\n\
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_IDN_AUTH_SESSION_TIME ON IDN_AUTH_SESSION_STORE (TIME_CREATED);\n\
    CREATE TABLE IF NOT EXISTS IDN_AUTH_TEMP_SESSION_STORE (\n\
                SESSION_ID VARCHAR (100) NOT NULL,\n\
                SESSION_TYPE VARCHAR(100) NOT NULL,\n\
                OPERATION VARCHAR(10) NOT NULL,\n\
                SESSION_OBJECT BLOB,\n\
                TIME_CREATED BIGINT,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                EXPIRY_TIME BIGINT,\n\
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_IDN_AUTH_TMP_SESSION_TIME ON IDN_AUTH_TEMP_SESSION_STORE (TIME_CREATED);\n\
    CREATE TABLE IF NOT EXISTS SP_APP (\n\
            ID INTEGER NOT NULL AUTO_INCREMENT,\n\
            TENANT_ID INTEGER NOT NULL,\n\
    	    	APP_NAME VARCHAR (255) NOT NULL ,\n\
    	    	USER_STORE VARCHAR (255) NOT NULL,\n\
            USERNAME VARCHAR (255) NOT NULL ,\n\
            DESCRIPTION VARCHAR (1024),\n\
    	    	ROLE_CLAIM VARCHAR (512),\n\
            AUTH_TYPE VARCHAR (255) NOT NULL,\n\
    	    	PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),\n\
    	    	IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',\n\
    	    	IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',\n\
    	    	IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',\n\
            IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',\n\
            IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',\n\
            ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0',\n\
    	    	SUBJECT_CLAIM_URI VARCHAR (512),\n\
    	    	IS_SAAS_APP CHAR(1) DEFAULT '0',\n\
    	    	IS_DUMB_MODE CHAR(1) DEFAULT '0',\n\
            PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS SP_METADATA (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                SP_ID INTEGER,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                VALUE VARCHAR(255) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(255),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ID),\n\
                CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),\n\
                FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS SP_INBOUND_AUTH (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                INBOUND_AUTH_KEY VARCHAR (255),\n\
                INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,\n\
                INBOUND_CONFIG_TYPE VARCHAR (255) NOT NULL,\n\
                PROP_NAME VARCHAR (255),\n\
                PROP_VALUE VARCHAR (1024) ,\n\
                APP_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_AUTH_STEP (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                STEP_ORDER INTEGER DEFAULT 1,\n\
                APP_ID INTEGER NOT NULL ,\n\
                IS_SUBJECT_STEP CHAR(1) DEFAULT '0',\n\
                IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_FEDERATED_IDP (\n\
                ID INTEGER NOT NULL,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                AUTHENTICATOR_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID, AUTHENTICATOR_ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_CLAIM_DIALECT (\n\
    	   	ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	   	TENANT_ID INTEGER NOT NULL,\n\
    	   	SP_DIALECT VARCHAR (512) NOT NULL,\n\
    	   	APP_ID INTEGER NOT NULL,\n\
    	   	PRIMARY KEY (ID));\n\
    ALTER TABLE SP_CLAIM_DIALECT ADD CONSTRAINT DIALECTID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_CLAIM_MAPPING (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                IDP_CLAIM VARCHAR (512) NOT NULL ,\n\
                SP_CLAIM VARCHAR (512) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                IS_REQUESTED VARCHAR(128) DEFAULT '0',\n\
    	    IS_MANDATORY VARCHAR(128) DEFAULT '0',\n\
                DEFAULT_VALUE VARCHAR(255),\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_ROLE_MAPPING (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                IDP_ROLE VARCHAR (255) NOT NULL ,\n\
                SP_ROLE VARCHAR (255) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_REQ_PATH_AUTHENTICATOR (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_PROVISIONING_CONNECTOR (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                IDP_NAME VARCHAR (255) NOT NULL ,\n\
                CONNECTOR_NAME VARCHAR (255) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',\n\
                BLOCKING CHAR(1) NOT NULL DEFAULT '0',\n\
                RULE_ENABLED CHAR(1) NOT NULL DEFAULT '0',\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE SP_AUTH_SCRIPT (\n\
      ID         INTEGER AUTO_INCREMENT NOT NULL,\n\
      TENANT_ID  INTEGER                NOT NULL,\n\
      APP_ID     INTEGER                NOT NULL,\n\
      TYPE       VARCHAR(255)           NOT NULL,\n\
      CONTENT    BLOB    DEFAULT NULL,\n\
      IS_ENABLED CHAR(1) NOT NULL DEFAULT '0',\n\
      PRIMARY KEY (ID));\n\
    CREATE TABLE IF NOT EXISTS SP_TEMPLATE (\n\
      ID         INTEGER AUTO_INCREMENT NOT NULL,\n\
      TENANT_ID  INTEGER                NOT NULL,\n\
      NAME VARCHAR(255) NOT NULL,\n\
      DESCRIPTION VARCHAR(1023),\n\
      CONTENT BLOB DEFAULT NULL,\n\
      PRIMARY KEY (ID),\n\
      CONSTRAINT SP_TEMPLATE_CONSTRAINT UNIQUE (TENANT_ID, NAME));\n\
    CREATE INDEX IDX_SP_TEMPLATE ON SP_TEMPLATE (TENANT_ID, NAME);\n\
    CREATE TABLE IF NOT EXISTS IDN_AUTH_WAIT_STATUS (\n\
      ID              INTEGER AUTO_INCREMENT NOT NULL,\n\
      TENANT_ID       INTEGER                NOT NULL,\n\
      LONG_WAIT_KEY   VARCHAR(255)           NOT NULL,\n\
      WAIT_STATUS     CHAR(1) NOT NULL DEFAULT '1',\n\
      TIME_CREATED    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      EXPIRE_TIME     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      PRIMARY KEY (ID),\n\
      CONSTRAINT IDN_AUTH_WAIT_STATUS_KEY UNIQUE (LONG_WAIT_KEY));\n\
    CREATE TABLE IF NOT EXISTS IDP (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			TENANT_ID INTEGER,\n\
    			NAME VARCHAR(254) NOT NULL,\n\
    			IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',\n\
    			IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',\n\
    			HOME_REALM_ID VARCHAR(254),\n\
    			IMAGE MEDIUMBLOB,\n\
    			CERTIFICATE BLOB,\n\
    			ALIAS VARCHAR(254),\n\
    			INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',\n\
    			INBOUND_PROV_USER_STORE_ID VARCHAR(254),\n\
     			USER_CLAIM_URI VARCHAR(254),\n\
     			ROLE_CLAIM_URI VARCHAR(254),\n\
      			DESCRIPTION VARCHAR (1024),\n\
     			DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),\n\
     			DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),\n\
     			PROVISIONING_ROLE VARCHAR(128),\n\
     			IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',\n\
     			IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',\n\
                DISPLAY_NAME VARCHAR(255),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (TENANT_ID, NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_ROLE (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			IDP_ID INTEGER,\n\
    			TENANT_ID INTEGER,\n\
    			ROLE VARCHAR(254),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (IDP_ID, ROLE),\n\
    			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_ROLE_MAPPING (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			IDP_ROLE_ID INTEGER,\n\
    			TENANT_ID INTEGER,\n\
    			USER_STORE_ID VARCHAR (253),\n\
    			LOCAL_ROLE VARCHAR(253),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),\n\
    			FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_CLAIM (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			IDP_ID INTEGER,\n\
    			TENANT_ID INTEGER,\n\
    			CLAIM VARCHAR(254),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (IDP_ID, CLAIM),\n\
    			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_CLAIM_MAPPING (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                IDP_CLAIM_ID INTEGER,\n\
                TENANT_ID INTEGER,\n\
                LOCAL_CLAIM VARCHAR(253),\n\
                DEFAULT_VALUE VARCHAR(255),\n\
                IS_REQUESTED VARCHAR(128) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),\n\
                FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                IDP_ID INTEGER,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                IS_ENABLED CHAR (1) DEFAULT '1',\n\
                DISPLAY_NAME VARCHAR(255),\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, IDP_ID, NAME),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_METADATA (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                IDP_ID INTEGER,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                VALUE VARCHAR(255) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(255),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ID),\n\
                CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR_PROPERTY (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                AUTHENTICATOR_ID INTEGER,\n\
                PROPERTY_KEY VARCHAR(255) NOT NULL,\n\
                PROPERTY_VALUE VARCHAR(2047),\n\
                IS_SECRET CHAR (1) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),\n\
                FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_CONFIG (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                IDP_ID INTEGER,\n\
                PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,\n\
                IS_ENABLED CHAR (1) DEFAULT '0',\n\
                IS_BLOCKING CHAR (1) DEFAULT '0',\n\
                IS_RULES_ENABLED CHAR (1) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_PROV_CONFIG_PROPERTY (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                PROVISIONING_CONFIG_ID INTEGER,\n\
                PROPERTY_KEY VARCHAR(255) NOT NULL,\n\
                PROPERTY_VALUE VARCHAR(2048),\n\
                PROPERTY_BLOB_VALUE BLOB,\n\
                PROPERTY_TYPE CHAR(32) NOT NULL,\n\
                IS_SECRET CHAR (1) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),\n\
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_ENTITY (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                PROVISIONING_CONFIG_ID INTEGER,\n\
                ENTITY_TYPE VARCHAR(255) NOT NULL,\n\
                ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,\n\
                ENTITY_NAME VARCHAR(255) NOT NULL,\n\
                ENTITY_VALUE VARCHAR(255),\n\
                TENANT_ID INTEGER,\n\
                ENTITY_LOCAL_ID VARCHAR(255),\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),\n\
                UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),\n\
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_LOCAL_CLAIM (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                IDP_ID INTEGER,\n\
                CLAIM_URI VARCHAR(255) NOT NULL,\n\
                DEFAULT_VALUE VARCHAR(255),\n\
                IS_REQUESTED VARCHAR(128) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_ASSOCIATED_ID (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                IDP_USER_ID VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1234,\n\
                IDP_ID INTEGER NOT NULL,\n\
                DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                PRIMARY KEY (ID),\n\
                UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_USER_ACCOUNT_ASSOCIATION (\n\
                ASSOCIATION_KEY VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER,\n\
                DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS FIDO_DEVICE_STORE (\n\
                TENANT_ID INTEGER,\n\
                DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(45) NOT NULL,\n\
                TIME_REGISTERED TIMESTAMP,\n\
                KEY_HANDLE VARCHAR(200) NOT NULL,\n\
                DEVICE_DATA VARCHAR(2048) NOT NULL,\n\
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE)\n\
            )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_REQUEST (\n\
        UUID VARCHAR (45),\n\
        CREATED_BY VARCHAR (255),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        OPERATION_TYPE VARCHAR (50),\n\
        CREATED_AT TIMESTAMP,\n\
        UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        STATUS VARCHAR (30),\n\
        REQUEST BLOB,\n\
        PRIMARY KEY (UUID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_BPS_PROFILE (\n\
        PROFILE_NAME VARCHAR(45),\n\
        HOST_URL_MANAGER VARCHAR(255),\n\
        HOST_URL_WORKER VARCHAR(255),\n\
        USERNAME VARCHAR(45),\n\
        PASSWORD VARCHAR(1023),\n\
        CALLBACK_HOST VARCHAR (45),\n\
        CALLBACK_USERNAME VARCHAR (45),\n\
        CALLBACK_PASSWORD VARCHAR (255),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY (PROFILE_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW(\n\
        ID VARCHAR (45),\n\
        WF_NAME VARCHAR (45),\n\
        DESCRIPTION VARCHAR (255),\n\
        TEMPLATE_ID VARCHAR (45),\n\
        IMPL_ID VARCHAR (45),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_ASSOCIATION(\n\
        ID INTEGER NOT NULL AUTO_INCREMENT,\n\
        ASSOC_NAME VARCHAR (45),\n\
        EVENT_ID VARCHAR(45),\n\
        ASSOC_CONDITION VARCHAR (2000),\n\
        WORKFLOW_ID VARCHAR (45),\n\
        IS_ENABLED CHAR (1) DEFAULT '1',\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY(ID),\n\
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_CONFIG_PARAM(\n\
        WORKFLOW_ID VARCHAR (45),\n\
        PARAM_NAME VARCHAR (45),\n\
        PARAM_VALUE VARCHAR (1000),\n\
        PARAM_QNAME VARCHAR (45),\n\
        PARAM_HOLDER VARCHAR (45),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),\n\
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_REQUEST_ENTITY_RELATIONSHIP(\n\
      REQUEST_ID VARCHAR (45),\n\
      ENTITY_NAME VARCHAR (255),\n\
      ENTITY_TYPE VARCHAR (50),\n\
      TENANT_ID INTEGER DEFAULT -1,\n\
      PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),\n\
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_REQUEST_RELATION(\n\
      RELATIONSHIP_ID VARCHAR (45),\n\
      WORKFLOW_ID VARCHAR (45),\n\
      REQUEST_ID VARCHAR (45),\n\
      UPDATED_AT TIMESTAMP,\n\
      STATUS VARCHAR (30),\n\
      TENANT_ID INTEGER DEFAULT -1,\n\
      PRIMARY KEY (RELATIONSHIP_ID),\n\
      FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,\n\
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_RECOVERY_DATA (\n\
      USER_NAME VARCHAR(255) NOT NULL,\n\
      USER_DOMAIN VARCHAR(127) NOT NULL,\n\
      TENANT_ID INTEGER DEFAULT -1,\n\
      CODE VARCHAR(255) NOT NULL,\n\
      SCENARIO VARCHAR(255) NOT NULL,\n\
      STEP VARCHAR(127) NOT NULL,\n\
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      REMAINING_SETS VARCHAR(2500) DEFAULT NULL,\n\
      PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),\n\
      UNIQUE(CODE)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_PASSWORD_HISTORY_DATA (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      USER_NAME   VARCHAR(255) NOT NULL,\n\
      USER_DOMAIN VARCHAR(127) NOT NULL,\n\
      TENANT_ID   INTEGER DEFAULT -1,\n\
      SALT_VALUE  VARCHAR(255),\n\
      HASH        VARCHAR(255) NOT NULL,\n\
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      PRIMARY KEY(ID),\n\
      UNIQUE (USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_DIALECT (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      DIALECT_URI VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      DIALECT_ID INTEGER,\n\
      CLAIM_URI VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,\n\
      CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPED_ATTRIBUTE (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      LOCAL_CLAIM_ID INTEGER,\n\
      USER_STORE_DOMAIN_NAME VARCHAR (255) NOT NULL,\n\
      ATTRIBUTE_NAME VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_PROPERTY (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      LOCAL_CLAIM_ID INTEGER,\n\
      PROPERTY_NAME VARCHAR (255) NOT NULL,\n\
      PROPERTY_VALUE VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPING (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      EXT_CLAIM_ID INTEGER NOT NULL,\n\
      MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS  IDN_SAML2_ASSERTION_STORE (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      SAML2_ID  VARCHAR(255) ,\n\
      SAML2_ISSUER  VARCHAR(255) ,\n\
      SAML2_SUBJECT  VARCHAR(255) ,\n\
      SAML2_SESSION_INDEX  VARCHAR(255) ,\n\
      SAML2_AUTHN_CONTEXT_CLASS_REF  VARCHAR(255) ,\n\
      SAML2_ASSERTION  VARCHAR(4096) ,\n\
      PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IDN_SAML2_ARTIFACT_STORE (\n\
      ID INT(11) NOT NULL AUTO_INCREMENT,\n\
      SOURCE_ID VARCHAR(255) NOT NULL,\n\
      MESSAGE_HANDLER VARCHAR(255) NOT NULL,\n\
      AUTHN_REQ_DTO BLOB NOT NULL,\n\
      SESSION_ID VARCHAR(255) NOT NULL,\n\
      EXP_TIMESTAMP TIMESTAMP NOT NULL,\n\
      INIT_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      ASSERTION_ID VARCHAR(255),\n\
      PRIMARY KEY (\`ID\`)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_JTI (\n\
      JWT_ID VARCHAR(255) NOT NULL,\n\
      EXP_TIME TIMESTAMP NOT NULL ,\n\
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,\n\
      PRIMARY KEY (JWT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS  IDN_OIDC_PROPERTY (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      TENANT_ID  INTEGER,\n\
      CONSUMER_KEY  VARCHAR(255) ,\n\
      PROPERTY_KEY  VARCHAR(255) NOT NULL,\n\
      PROPERTY_VALUE  VARCHAR(2047) ,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_REFERENCE (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      CONSUMER_KEY_ID INTEGER ,\n\
      CODE_ID VARCHAR(255) ,\n\
      TOKEN_ID VARCHAR(255) ,\n\
      SESSION_DATA_KEY VARCHAR(255),\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,\n\
      FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE,\n\
      FOREIGN KEY (CODE_ID) REFERENCES IDN_OAUTH2_AUTHORIZATION_CODE(CODE_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_CLAIMS (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      REQ_OBJECT_ID INTEGER,\n\
      CLAIM_ATTRIBUTE VARCHAR(255) ,\n\
      ESSENTIAL CHAR(1) NOT NULL DEFAULT '0' ,\n\
      VALUE VARCHAR(255) ,\n\
      IS_USERINFO CHAR(1) NOT NULL DEFAULT '0',\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (REQ_OBJECT_ID) REFERENCES IDN_OIDC_REQ_OBJECT_REFERENCE (ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJ_CLAIM_VALUES (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      REQ_OBJECT_CLAIMS_ID INTEGER ,\n\
      CLAIM_VALUES VARCHAR(255) ,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (REQ_OBJECT_CLAIMS_ID) REFERENCES  IDN_OIDC_REQ_OBJECT_CLAIMS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CERTIFICATE (\n\
                 ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 NAME VARCHAR(100),\n\
                 CERTIFICATE_IN_PEM BLOB,\n\
                 TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY(ID),\n\
                 CONSTRAINT CERTIFICATE_UNIQUE_KEY UNIQUE (NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE_CLAIM_MAPPING (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                SCOPE_ID INTEGER,\n\
                EXTERNAL_CLAIM_ID INTEGER,\n\
                PRIMARY KEY (ID),\n\
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OIDC_SCOPE(ID) ON DELETE CASCADE,\n\
                FOREIGN KEY (EXTERNAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_AT_SI_ECI ON IDN_OIDC_SCOPE_CLAIM_MAPPING(SCOPE_ID, EXTERNAL_CLAIM_ID);\n\
    CREATE TABLE CM_PII_CATEGORY (\n\
      ID           INTEGER AUTO_INCREMENT,\n\
      NAME         VARCHAR(255) NOT NULL,\n\
      DESCRIPTION  VARCHAR(1023),\n\
      DISPLAY_NAME VARCHAR(255),\n\
      IS_SENSITIVE INTEGER      NOT NULL,\n\
      TENANT_ID    INTEGER DEFAULT '-1234',\n\
      UNIQUE KEY (NAME, TENANT_ID),\n\
      PRIMARY KEY (ID)\n\
    );\n\
    CREATE TABLE CM_RECEIPT (\n\
      CONSENT_RECEIPT_ID  VARCHAR(255) NOT NULL,\n\
      VERSION             VARCHAR(255) NOT NULL,\n\
      JURISDICTION        VARCHAR(255) NOT NULL,\n\
      CONSENT_TIMESTAMP   TIMESTAMP    NOT NULL,\n\
      COLLECTION_METHOD   VARCHAR(255) NOT NULL,\n\
      LANGUAGE            VARCHAR(255) NOT NULL,\n\
      PII_PRINCIPAL_ID    VARCHAR(255) NOT NULL,\n\
      PRINCIPAL_TENANT_ID INTEGER DEFAULT '-1234',\n\
      POLICY_URL          VARCHAR(255) NOT NULL,\n\
      STATE               VARCHAR(255) NOT NULL,\n\
      PII_CONTROLLER      VARCHAR(2048) NOT NULL,\n\
      PRIMARY KEY (CONSENT_RECEIPT_ID)\n\
    );\n\
    CREATE TABLE CM_PURPOSE (\n\
      ID            INTEGER AUTO_INCREMENT,\n\
      NAME          VARCHAR(255) NOT NULL,\n\
      DESCRIPTION   VARCHAR(1023),\n\
      PURPOSE_GROUP VARCHAR(255) NOT NULL,\n\
      GROUP_TYPE    VARCHAR(255) NOT NULL,\n\
      TENANT_ID     INTEGER DEFAULT '-1234',\n\
      UNIQUE KEY (NAME, TENANT_ID, PURPOSE_GROUP, GROUP_TYPE),\n\
      PRIMARY KEY (ID)\n\
    );\n\
    CREATE TABLE CM_PURPOSE_CATEGORY (\n\
      ID          INTEGER AUTO_INCREMENT,\n\
      NAME        VARCHAR(255) NOT NULL,\n\
      DESCRIPTION VARCHAR(1023),\n\
      TENANT_ID   INTEGER DEFAULT '-1234',\n\
      UNIQUE KEY (NAME, TENANT_ID),\n\
      PRIMARY KEY (ID)\n\
    );\n\
    CREATE TABLE CM_RECEIPT_SP_ASSOC (\n\
      ID                 INTEGER AUTO_INCREMENT,\n\
      CONSENT_RECEIPT_ID VARCHAR(255) NOT NULL,\n\
      SP_NAME            VARCHAR(255) NOT NULL,\n\
      SP_DISPLAY_NAME    VARCHAR(255),\n\
      SP_DESCRIPTION     VARCHAR(255),\n\
      SP_TENANT_ID       INTEGER DEFAULT '-1234',\n\
      UNIQUE KEY (CONSENT_RECEIPT_ID, SP_NAME, SP_TENANT_ID),\n\
      PRIMARY KEY (ID)\n\
    );\n\
    CREATE TABLE CM_SP_PURPOSE_ASSOC (\n\
      ID                     INTEGER AUTO_INCREMENT,\n\
      RECEIPT_SP_ASSOC       INTEGER      NOT NULL,\n\
      PURPOSE_ID             INTEGER      NOT NULL,\n\
      CONSENT_TYPE           VARCHAR(255) NOT NULL,\n\
      IS_PRIMARY_PURPOSE     INTEGER      NOT NULL,\n\
      TERMINATION            VARCHAR(255) NOT NULL,\n\
      THIRD_PARTY_DISCLOSURE INTEGER      NOT NULL,\n\
      THIRD_PARTY_NAME       VARCHAR(255),\n\
      UNIQUE KEY (RECEIPT_SP_ASSOC, PURPOSE_ID),\n\
      PRIMARY KEY (ID)\n\
    );\n\
    CREATE TABLE CM_SP_PURPOSE_PURPOSE_CAT_ASSC (\n\
      SP_PURPOSE_ASSOC_ID INTEGER NOT NULL,\n\
      PURPOSE_CATEGORY_ID INTEGER NOT NULL,\n\
      UNIQUE KEY (SP_PURPOSE_ASSOC_ID, PURPOSE_CATEGORY_ID)\n\
    );\n\
    CREATE TABLE CM_PURPOSE_PII_CAT_ASSOC (\n\
      PURPOSE_ID         INTEGER NOT NULL,\n\
      CM_PII_CATEGORY_ID INTEGER NOT NULL,\n\
      IS_MANDATORY       INTEGER NOT NULL,\n\
      UNIQUE KEY (PURPOSE_ID, CM_PII_CATEGORY_ID)\n\
    );\n\
    CREATE TABLE CM_SP_PURPOSE_PII_CAT_ASSOC (\n\
      SP_PURPOSE_ASSOC_ID INTEGER NOT NULL,\n\
      PII_CATEGORY_ID     INTEGER NOT NULL,\n\
      VALIDITY            VARCHAR(1023),\n\
      UNIQUE KEY (SP_PURPOSE_ASSOC_ID, PII_CATEGORY_ID)\n\
    );\n\
    CREATE TABLE CM_CONSENT_RECEIPT_PROPERTY (\n\
      CONSENT_RECEIPT_ID VARCHAR(255)  NOT NULL,\n\
      NAME               VARCHAR(255)  NOT NULL,\n\
      VALUE              VARCHAR(1023) NOT NULL,\n\
      UNIQUE KEY (CONSENT_RECEIPT_ID, NAME)\n\
    );\n\
    ALTER TABLE CM_RECEIPT_SP_ASSOC\n\
      ADD CONSTRAINT CM_RECEIPT_SP_ASSOC_fk0 FOREIGN KEY (CONSENT_RECEIPT_ID) REFERENCES CM_RECEIPT (CONSENT_RECEIPT_ID);\n\
    ALTER TABLE CM_SP_PURPOSE_ASSOC\n\
      ADD CONSTRAINT CM_SP_PURPOSE_ASSOC_fk0 FOREIGN KEY (RECEIPT_SP_ASSOC) REFERENCES CM_RECEIPT_SP_ASSOC (ID);\n\
    ALTER TABLE CM_SP_PURPOSE_ASSOC\n\
      ADD CONSTRAINT CM_SP_PURPOSE_ASSOC_fk1 FOREIGN KEY (PURPOSE_ID) REFERENCES CM_PURPOSE (ID);\n\
    ALTER TABLE CM_SP_PURPOSE_PURPOSE_CAT_ASSC\n\
      ADD CONSTRAINT CM_SP_P_P_CAT_ASSOC_fk0 FOREIGN KEY (SP_PURPOSE_ASSOC_ID) REFERENCES CM_SP_PURPOSE_ASSOC (ID);\n\
    ALTER TABLE CM_SP_PURPOSE_PURPOSE_CAT_ASSC\n\
      ADD CONSTRAINT CM_SP_P_P_CAT_ASSOC_fk1 FOREIGN KEY (PURPOSE_CATEGORY_ID) REFERENCES CM_PURPOSE_CATEGORY (ID);\n\
    ALTER TABLE CM_SP_PURPOSE_PII_CAT_ASSOC\n\
      ADD CONSTRAINT CM_SP_P_PII_CAT_ASSOC_fk0 FOREIGN KEY (SP_PURPOSE_ASSOC_ID) REFERENCES CM_SP_PURPOSE_ASSOC (ID);\n\
    ALTER TABLE CM_SP_PURPOSE_PII_CAT_ASSOC\n\
      ADD CONSTRAINT CM_SP_P_PII_CAT_ASSOC_fk1 FOREIGN KEY (PII_CATEGORY_ID) REFERENCES CM_PII_CATEGORY (ID);\n\
    ALTER TABLE CM_CONSENT_RECEIPT_PROPERTY\n\
      ADD CONSTRAINT CM_CONSENT_RECEIPT_PRT_fk0 FOREIGN KEY (CONSENT_RECEIPT_ID) REFERENCES CM_RECEIPT (CONSENT_RECEIPT_ID);\n\
    INSERT INTO CM_PURPOSE (NAME, DESCRIPTION, PURPOSE_GROUP, GROUP_TYPE, TENANT_ID) VALUES ('DEFAULT', 'For core functionalities of the product', 'DEFAULT', 'SP', '-1234');\n\
    INSERT INTO CM_PURPOSE_CATEGORY (NAME, DESCRIPTION, TENANT_ID) VALUES ('DEFAULT','For core functionalities of the product', '-1234');\n\
    CREATE TABLE IF NOT EXISTS AM_SUBSCRIBER (\n\
        SUBSCRIBER_ID INTEGER AUTO_INCREMENT,\n\
        USER_ID VARCHAR(255) NOT NULL,\n\
        TENANT_ID INTEGER NOT NULL,\n\
        EMAIL_ADDRESS VARCHAR(256) NULL,\n\
        DATE_SUBSCRIBED TIMESTAMP NOT NULL,\n\
        PRIMARY KEY (SUBSCRIBER_ID),\n\
        CREATED_BY VARCHAR(100),\n\
        CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        UPDATED_BY VARCHAR(100),\n\
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        UNIQUE (TENANT_ID,USER_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_APPLICATION (\n\
        APPLICATION_ID INTEGER AUTO_INCREMENT,\n\
        NAME VARCHAR(100),\n\
        SUBSCRIBER_ID INTEGER,\n\
        APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',\n\
        CALLBACK_URL VARCHAR(512),\n\
        DESCRIPTION VARCHAR(512),\n\
        APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',\n\
        GROUP_ID VARCHAR(100),\n\
        CREATED_BY VARCHAR(100),\n\
        CREATED_TIME TIMESTAMP,\n\
        UPDATED_BY VARCHAR(100),\n\
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        UUID VARCHAR(256),\n\
        TOKEN_TYPE VARCHAR(10),\n\
        FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY(APPLICATION_ID),\n\
        UNIQUE (NAME,SUBSCRIBER_ID),\n\
        UNIQUE (UUID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API (\n\
        API_ID INTEGER AUTO_INCREMENT,\n\
        API_PROVIDER VARCHAR(200),\n\
        API_NAME VARCHAR(200),\n\
        API_VERSION VARCHAR(30),\n\
        CONTEXT VARCHAR(256),\n\
        CONTEXT_TEMPLATE VARCHAR(256),\n\
        API_TIER VARCHAR(256),\n\
        CREATED_BY VARCHAR(100),\n\
        CREATED_TIME TIMESTAMP,\n\
        UPDATED_BY VARCHAR(100),\n\
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        PRIMARY KEY(API_ID),\n\
        UNIQUE (API_PROVIDER,API_NAME,API_VERSION)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_URL_MAPPING (\n\
        URL_MAPPING_ID INTEGER AUTO_INCREMENT,\n\
        API_ID INTEGER NOT NULL,\n\
        HTTP_METHOD VARCHAR(20) NULL,\n\
        AUTH_SCHEME VARCHAR(50) NULL,\n\
        URL_PATTERN VARCHAR(512) NULL,\n\
        THROTTLING_TIER varchar(512) DEFAULT NULL,\n\
        MEDIATION_SCRIPT BLOB,\n\
        PRIMARY KEY (URL_MAPPING_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION (\n\
        SUBSCRIPTION_ID INTEGER AUTO_INCREMENT,\n\
        TIER_ID VARCHAR(50),\n\
        API_ID INTEGER,\n\
        LAST_ACCESSED TIMESTAMP NULL,\n\
        APPLICATION_ID INTEGER,\n\
        SUB_STATUS VARCHAR(50),\n\
        SUBS_CREATE_STATE VARCHAR(50) DEFAULT 'SUBSCRIBE',\n\
        CREATED_BY VARCHAR(100),\n\
        CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        UPDATED_BY VARCHAR(100),\n\
        UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        UUID VARCHAR(256),\n\
        FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY (SUBSCRIPTION_ID),\n\
        UNIQUE (UUID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_SUBSCRIPTION_KEY_MAPPING (\n\
        SUBSCRIPTION_ID INTEGER,\n\
        ACCESS_TOKEN VARCHAR(512),\n\
        KEY_TYPE VARCHAR(512) NOT NULL,\n\
        FOREIGN KEY(SUBSCRIPTION_ID) REFERENCES AM_SUBSCRIPTION(SUBSCRIPTION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY(SUBSCRIPTION_ID,ACCESS_TOKEN)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_KEY_MAPPING (\n\
        APPLICATION_ID INTEGER,\n\
        CONSUMER_KEY VARCHAR(255),\n\
        KEY_TYPE VARCHAR(512) NOT NULL,\n\
        STATE VARCHAR(30) NOT NULL,\n\
        CREATE_MODE VARCHAR(30) DEFAULT 'CREATED',\n\
        FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY(APPLICATION_ID,KEY_TYPE)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_LC_EVENT (\n\
        EVENT_ID INTEGER AUTO_INCREMENT,\n\
        API_ID INTEGER NOT NULL,\n\
        PREVIOUS_STATE VARCHAR(50),\n\
        NEW_STATE VARCHAR(50) NOT NULL,\n\
        USER_ID VARCHAR(255) NOT NULL,\n\
        TENANT_ID INTEGER NOT NULL,\n\
        EVENT_DATE TIMESTAMP NOT NULL,\n\
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY (EVENT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE AM_APP_KEY_DOMAIN_MAPPING (\n\
        CONSUMER_KEY VARCHAR(255),\n\
        AUTHZ_DOMAIN VARCHAR(255) DEFAULT 'ALL',\n\
        PRIMARY KEY (CONSUMER_KEY,AUTHZ_DOMAIN)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_COMMENTS (\n\
        COMMENT_ID INTEGER AUTO_INCREMENT,\n\
        COMMENT_TEXT VARCHAR(512),\n\
        COMMENTED_USER VARCHAR(255),\n\
        DATE_COMMENTED TIMESTAMP NOT NULL,\n\
        API_ID INTEGER NOT NULL,\n\
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY (COMMENT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_RATINGS (\n\
        RATING_ID INTEGER AUTO_INCREMENT,\n\
        API_ID INTEGER,\n\
        RATING INTEGER,\n\
        SUBSCRIBER_ID INTEGER,\n\
        FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
    PRIMARY KEY (RATING_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_TIER_PERMISSIONS (\n\
        TIER_PERMISSIONS_ID INTEGER AUTO_INCREMENT,\n\
        TIER VARCHAR(50) NOT NULL,\n\
        PERMISSIONS_TYPE VARCHAR(50) NOT NULL,\n\
        ROLES VARCHAR(512) NOT NULL,\n\
        TENANT_ID INTEGER NOT NULL,\n\
        PRIMARY KEY(TIER_PERMISSIONS_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_EXTERNAL_STORES (\n\
        APISTORE_ID INTEGER AUTO_INCREMENT,\n\
        API_ID INTEGER,\n\
        STORE_ID VARCHAR(255) NOT NULL,\n\
        STORE_DISPLAY_NAME VARCHAR(255) NOT NULL,\n\
        STORE_ENDPOINT VARCHAR(255) NOT NULL,\n\
        STORE_TYPE VARCHAR(255) NOT NULL,\n\
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
    PRIMARY KEY (APISTORE_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_WORKFLOWS(\n\
        WF_ID INTEGER AUTO_INCREMENT,\n\
        WF_REFERENCE VARCHAR(255) NOT NULL,\n\
        WF_TYPE VARCHAR(255) NOT NULL,\n\
        WF_STATUS VARCHAR(255) NOT NULL,\n\
        WF_CREATED_TIME TIMESTAMP,\n\
        WF_UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,\n\
        WF_STATUS_DESC VARCHAR(1000),\n\
        TENANT_ID INTEGER,\n\
        TENANT_DOMAIN VARCHAR(255),\n\
        WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,\n\
        PRIMARY KEY (WF_ID),\n\
        UNIQUE (WF_EXTERNAL_REFERENCE)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_REGISTRATION (\n\
        REG_ID INT AUTO_INCREMENT,\n\
        SUBSCRIBER_ID INT,\n\
        WF_REF VARCHAR(255) NOT NULL,\n\
        APP_ID INT,\n\
        TOKEN_TYPE VARCHAR(30),\n\
        TOKEN_SCOPE VARCHAR(1500) DEFAULT 'default',\n\
        INPUTS VARCHAR(1000),\n\
        ALLOWED_DOMAINS VARCHAR(256),\n\
        VALIDITY_PERIOD BIGINT,\n\
        UNIQUE (SUBSCRIBER_ID,APP_ID,TOKEN_TYPE),\n\
        FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        FOREIGN KEY(APP_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,\n\
        PRIMARY KEY (REG_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_SCOPES (\n\
       API_ID  INTEGER NOT NULL,\n\
       SCOPE_ID  INTEGER NOT NULL,\n\
       FOREIGN KEY (API_ID) REFERENCES AM_API (API_ID) ON DELETE CASCADE ON UPDATE CASCADE,\n\
       FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE ON UPDATE CASCADE,\n\
       PRIMARY KEY (API_ID, SCOPE_ID)\n\
    )ENGINE = INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_DEFAULT_VERSION (\n\
                DEFAULT_VERSION_ID INT AUTO_INCREMENT,\n\
                API_NAME VARCHAR(256) NOT NULL ,\n\
                API_PROVIDER VARCHAR(256) NOT NULL ,\n\
                DEFAULT_API_VERSION VARCHAR(30) ,\n\
                PUBLISHED_DEFAULT_API_VERSION VARCHAR(30) ,\n\
                PRIMARY KEY (DEFAULT_VERSION_ID)\n\
    )ENGINE = INNODB;\n\
    CREATE INDEX IDX_SUB_APP_ID ON AM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID);\n\
    CREATE TABLE IF NOT EXISTS AM_ALERT_TYPES (\n\
                ALERT_TYPE_ID INTEGER AUTO_INCREMENT,\n\
                ALERT_TYPE_NAME VARCHAR(255) NOT NULL ,\n\
    	    STAKE_HOLDER VARCHAR(100) NOT NULL,\n\
                PRIMARY KEY (ALERT_TYPE_ID)\n\
    )ENGINE = INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_ALERT_TYPES_VALUES (\n\
                ALERT_TYPE_ID INTEGER,\n\
                USER_NAME VARCHAR(255) NOT NULL ,\n\
    	    STAKE_HOLDER VARCHAR(100) NOT NULL ,\n\
                PRIMARY KEY (ALERT_TYPE_ID,USER_NAME,STAKE_HOLDER)\n\
    )ENGINE = INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_ALERT_EMAILLIST (\n\
    	    EMAIL_LIST_ID INTEGER AUTO_INCREMENT,\n\
                USER_NAME VARCHAR(255) NOT NULL ,\n\
    	    STAKE_HOLDER VARCHAR(100) NOT NULL ,\n\
                PRIMARY KEY (EMAIL_LIST_ID,USER_NAME,STAKE_HOLDER)\n\
    )ENGINE = INNODB;\n\
    CREATE TABLE IF NOT EXISTS  AM_ALERT_EMAILLIST_DETAILS (\n\
                EMAIL_LIST_ID INTEGER,\n\
    	    EMAIL VARCHAR(255),\n\
                PRIMARY KEY (EMAIL_LIST_ID,EMAIL)\n\
    )ENGINE = INNODB;\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalResponseTime', 'publisher');\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalBackendTime', 'publisher');\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalRequestsPerMin', 'subscriber');\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalRequestPattern', 'subscriber');\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('UnusualIPAccess', 'subscriber');\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('FrequentTierLimitHitting', 'subscriber');\n\
    INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('ApiHealthMonitor', 'publisher');\n\
    CREATE TABLE IF NOT EXISTS AM_POLICY_SUBSCRIPTION (\n\
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(512) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,\n\
                TENANT_ID INT(11) NOT NULL,\n\
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,\n\
                QUOTA_TYPE VARCHAR(25) NOT NULL,\n\
                QUOTA INT(11) NOT NULL,\n\
                QUOTA_UNIT VARCHAR(10) NULL,\n\
                UNIT_TIME INT(11) NOT NULL,\n\
                TIME_UNIT VARCHAR(25) NOT NULL,\n\
                RATE_LIMIT_COUNT INT(11) NULL DEFAULT NULL,\n\
                RATE_LIMIT_TIME_UNIT VARCHAR(25) NULL DEFAULT NULL,\n\
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,\n\
    	    CUSTOM_ATTRIBUTES BLOB DEFAULT NULL,\n\
                STOP_ON_QUOTA_REACH BOOLEAN NOT NULL DEFAULT 0,\n\
                BILLING_PLAN VARCHAR(20) NOT NULL,\n\
                UUID VARCHAR(256),\n\
                PRIMARY KEY (POLICY_ID),\n\
                UNIQUE INDEX AM_POLICY_SUBSCRIPTION_NAME_TENANT (NAME, TENANT_ID),\n\
                UNIQUE (UUID)\n\
    )ENGINE = InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_POLICY_APPLICATION (\n\
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(512) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,\n\
                TENANT_ID INT(11) NOT NULL,\n\
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,\n\
                QUOTA_TYPE VARCHAR(25) NOT NULL,\n\
                QUOTA INT(11) NOT NULL,\n\
                QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,\n\
                UNIT_TIME INT(11) NOT NULL,\n\
                TIME_UNIT VARCHAR(25) NOT NULL,\n\
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,\n\
    	    CUSTOM_ATTRIBUTES BLOB DEFAULT NULL,\n\
    	          UUID VARCHAR(256),\n\
                PRIMARY KEY (POLICY_ID),\n\
                UNIQUE INDEX APP_NAME_TENANT (NAME, TENANT_ID),\n\
                UNIQUE (UUID)\n\
    )ENGINE = InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_POLICY_HARD_THROTTLING (\n\
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(512) NOT NULL,\n\
                TENANT_ID INT(11) NOT NULL,\n\
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,\n\
                QUOTA_TYPE VARCHAR(25) NOT NULL,\n\
                QUOTA INT(11) NOT NULL,\n\
                QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,\n\
                UNIT_TIME INT(11) NOT NULL,\n\
                TIME_UNIT VARCHAR(25) NOT NULL,\n\
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,\n\
                PRIMARY KEY (POLICY_ID),\n\
                UNIQUE INDEX POLICY_HARD_NAME_TENANT (NAME, TENANT_ID)\n\
    )ENGINE = InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_THROTTLE_POLICY (\n\
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(512) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(512) NULL DEFAULT NULL,\n\
                TENANT_ID INT(11) NOT NULL,\n\
                DESCRIPTION VARCHAR (1024),\n\
                DEFAULT_QUOTA_TYPE VARCHAR(25) NOT NULL,\n\
                DEFAULT_QUOTA INTEGER NOT NULL,\n\
                DEFAULT_QUOTA_UNIT VARCHAR(10) NULL,\n\
                DEFAULT_UNIT_TIME INTEGER NOT NULL,\n\
                DEFAULT_TIME_UNIT VARCHAR(25) NOT NULL,\n\
                APPLICABLE_LEVEL VARCHAR(25) NOT NULL,\n\
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,\n\
                UUID VARCHAR(256),\n\
                PRIMARY KEY (POLICY_ID),\n\
                UNIQUE INDEX API_NAME_TENANT (NAME, TENANT_ID),\n\
                UNIQUE (UUID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_CONDITION_GROUP (\n\
                CONDITION_GROUP_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                POLICY_ID INTEGER NOT NULL,\n\
                QUOTA_TYPE VARCHAR(25),\n\
                QUOTA INTEGER NOT NULL,\n\
                QUOTA_UNIT VARCHAR(10) NULL DEFAULT NULL,\n\
                UNIT_TIME INTEGER NOT NULL,\n\
                TIME_UNIT VARCHAR(25) NOT NULL,\n\
                DESCRIPTION VARCHAR (1024) NULL DEFAULT NULL,\n\
                PRIMARY KEY (CONDITION_GROUP_ID),\n\
                FOREIGN KEY (POLICY_ID) REFERENCES AM_API_THROTTLE_POLICY(POLICY_ID) ON DELETE CASCADE ON UPDATE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_QUERY_PARAMETER_CONDITION (\n\
                QUERY_PARAMETER_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                CONDITION_GROUP_ID INTEGER NOT NULL,\n\
                PARAMETER_NAME VARCHAR(255) DEFAULT NULL,\n\
                PARAMETER_VALUE VARCHAR(255) DEFAULT NULL,\n\
    	    	IS_PARAM_MAPPING BOOLEAN DEFAULT 1,\n\
                PRIMARY KEY (QUERY_PARAMETER_ID),\n\
                FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_HEADER_FIELD_CONDITION (\n\
                HEADER_FIELD_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                CONDITION_GROUP_ID INTEGER NOT NULL,\n\
                HEADER_FIELD_NAME VARCHAR(255) DEFAULT NULL,\n\
                HEADER_FIELD_VALUE VARCHAR(255) DEFAULT NULL,\n\
    	    	IS_HEADER_FIELD_MAPPING BOOLEAN DEFAULT 1,\n\
                PRIMARY KEY (HEADER_FIELD_ID),\n\
                FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_JWT_CLAIM_CONDITION (\n\
                JWT_CLAIM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                CONDITION_GROUP_ID INTEGER NOT NULL,\n\
                CLAIM_URI VARCHAR(512) DEFAULT NULL,\n\
                CLAIM_ATTRIB VARCHAR(1024) DEFAULT NULL,\n\
    	    IS_CLAIM_MAPPING BOOLEAN DEFAULT 1,\n\
                PRIMARY KEY (JWT_CLAIM_ID),\n\
                FOREIGN KEY (CONDITION_GROUP_ID) REFERENCES AM_CONDITION_GROUP(CONDITION_GROUP_ID) ON DELETE CASCADE ON UPDATE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_IP_CONDITION (\n\
      AM_IP_CONDITION_ID INT NOT NULL AUTO_INCREMENT,\n\
      STARTING_IP VARCHAR(45) NULL,\n\
      ENDING_IP VARCHAR(45) NULL,\n\
      SPECIFIC_IP VARCHAR(45) NULL,\n\
      WITHIN_IP_RANGE BOOLEAN DEFAULT 1,\n\
      CONDITION_GROUP_ID INT NULL,\n\
      PRIMARY KEY (AM_IP_CONDITION_ID),\n\
      INDEX fk_AM_IP_CONDITION_1_idx (CONDITION_GROUP_ID ASC),  CONSTRAINT fk_AM_IP_CONDITION_1    FOREIGN KEY (CONDITION_GROUP_ID)\n\
        REFERENCES AM_CONDITION_GROUP (CONDITION_GROUP_ID)   ON DELETE CASCADE ON UPDATE CASCADE)\n\
    ENGINE = InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_POLICY_GLOBAL (\n\
                POLICY_ID INT(11) NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(512) NOT NULL,\n\
                KEY_TEMPLATE VARCHAR(512) NOT NULL,\n\
                TENANT_ID INT(11) NOT NULL,\n\
                DESCRIPTION VARCHAR(1024) NULL DEFAULT NULL,\n\
                SIDDHI_QUERY BLOB DEFAULT NULL,\n\
                IS_DEPLOYED TINYINT(1) NOT NULL DEFAULT 0,\n\
                UUID VARCHAR(256),\n\
                PRIMARY KEY (POLICY_ID),\n\
                UNIQUE (UUID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS AM_THROTTLE_TIER_PERMISSIONS (\n\
      THROTTLE_TIER_PERMISSIONS_ID INT NOT NULL AUTO_INCREMENT,\n\
      TIER VARCHAR(50) NULL,\n\
      PERMISSIONS_TYPE VARCHAR(50) NULL,\n\
      ROLES VARCHAR(512) NULL,\n\
      TENANT_ID INT(11) NULL,\n\
      PRIMARY KEY (THROTTLE_TIER_PERMISSIONS_ID))\n\
    ENGINE = InnoDB;\n\
    CREATE TABLE \`AM_BLOCK_CONDITIONS\` (\n\
      \`CONDITION_ID\` int(11) NOT NULL AUTO_INCREMENT,\n\
      \`TYPE\` varchar(45) DEFAULT NULL,\n\
      \`VALUE\` varchar(512) DEFAULT NULL,\n\
      \`ENABLED\` varchar(45) DEFAULT NULL,\n\
      \`DOMAIN\` varchar(45) DEFAULT NULL,\n\
      \`UUID\` VARCHAR(256),\n\
      PRIMARY KEY (\`CONDITION_ID\`),\n\
      UNIQUE (\`UUID\`)\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS \`AM_CERTIFICATE_METADATA\` (\n\
      \`TENANT_ID\` INT(11) NOT NULL,\n\
      \`ALIAS\` VARCHAR(45) NOT NULL,\n\
      \`END_POINT\` VARCHAR(100) NOT NULL,\n\
      CONSTRAINT PK_ALIAS PRIMARY KEY (\`ALIAS\`)\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_GROUP_MAPPING (\n\
        APPLICATION_ID INTEGER NOT NULL,\n\
        GROUP_ID VARCHAR(512) NOT NULL,\n\
        TENANT VARCHAR(255),\n\
        PRIMARY KEY (APPLICATION_ID,GROUP_ID,TENANT),\n\
        FOREIGN KEY (APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON DELETE CASCADE ON UPDATE CASCADE\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_USAGE_UPLOADED_FILES (\n\
      TENANT_DOMAIN varchar(255) NOT NULL,\n\
      FILE_NAME varchar(255) NOT NULL,\n\
      FILE_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
      FILE_PROCESSED tinyint(1) DEFAULT FALSE,\n\
      FILE_CONTENT MEDIUMBLOB DEFAULT NULL,\n\
      PRIMARY KEY (TENANT_DOMAIN, FILE_NAME, FILE_TIMESTAMP)\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_API_LC_PUBLISH_EVENTS (\n\
        ID INTEGER(11) NOT NULL AUTO_INCREMENT,\n\
        TENANT_DOMAIN VARCHAR(500) NOT NULL,\n\
        API_ID VARCHAR(500) NOT NULL,\n\
        EVENT_TIME TIMESTAMP NOT NULL,\n\
        PRIMARY KEY (ID)\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_APPLICATION_ATTRIBUTES (\n\
      APPLICATION_ID int(11) NOT NULL,\n\
      NAME varchar(255) NOT NULL,\n\
      VALUE varchar(1024) NOT NULL,\n\
      TENANT_ID int(11) NOT NULL,\n\
      PRIMARY KEY (APPLICATION_ID,NAME),\n\
      FOREIGN KEY (APPLICATION_ID) REFERENCES AM_APPLICATION (APPLICATION_ID) ON DELETE CASCADE ON UPDATE CASCADE\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_LABELS (\n\
      LABEL_ID VARCHAR(50),\n\
      NAME VARCHAR(255),\n\
      DESCRIPTION VARCHAR(1024),\n\
      TENANT_DOMAIN VARCHAR(255),\n\
      UNIQUE (NAME,TENANT_DOMAIN),\n\
      PRIMARY KEY (LABEL_ID)\n\
    ) ENGINE=InnoDB;\n\
    CREATE TABLE IF NOT EXISTS AM_LABEL_URLS (\n\
      LABEL_ID VARCHAR(50),\n\
      ACCESS_URL VARCHAR(255),\n\
      PRIMARY KEY (LABEL_ID,ACCESS_URL),\n\
      FOREIGN KEY (LABEL_ID) REFERENCES AM_LABELS(LABEL_ID) ON UPDATE CASCADE ON DELETE CASCADE\n\
    ) ENGINE=InnoDB;\n\
    create index IDX_ITS_LMT on IDN_THRIFT_SESSION (LAST_MODIFIED_TIME);\n\
    create index IDX_IOAT_UT on IDN_OAUTH2_ACCESS_TOKEN (USER_TYPE);\n\
    create index IDX_AAI_CTX on AM_API (CONTEXT);\n\
    create index IDX_AAKM_CK on AM_APPLICATION_KEY_MAPPING (CONSUMER_KEY);\n\
    create index IDX_AAUM_AI on AM_API_URL_MAPPING (API_ID);\n\
    create index IDX_AAUM_TT on AM_API_URL_MAPPING (THROTTLING_TIER);\n\
    create index IDX_AATP_DQT on AM_API_THROTTLE_POLICY (DEFAULT_QUOTA_TYPE);\n\
    create index IDX_ACG_QT on AM_CONDITION_GROUP (QUOTA_TYPE);\n\
    create index IDX_APS_QT on AM_POLICY_SUBSCRIPTION (QUOTA_TYPE);\n\
    create index IDX_AS_AITIAI on AM_SUBSCRIPTION (API_ID,TIER_ID,APPLICATION_ID);\n\
    create index IDX_APA_QT on AM_POLICY_APPLICATION (QUOTA_TYPE);\n\
    create index IDX_AA_AT_CB on AM_APPLICATION (APPLICATION_TIER,CREATED_BY);\n\
kind: ConfigMap\n\
metadata:\n\
  name: mysql-dbscripts\n\
  namespace: wso2\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
kind: Service\n\
metadata:\n\
  name: wso2apim-with-analytics-rdbms-service\n\
  namespace: wso2\n\
spec:\n\
  type: ClusterIP\n\
  selector:\n\
    deployment: wso2apim-with-analytics-mysql\n\
  ports:\n\
    - name: mysql-port\n\
      port: 3306\n\
      targetPort: 3306\n\
      protocol: TCP\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
kind: Service\n\
metadata:\n\
  name: wso2apim-with-analytics-apim-analytics-service\n\
  namespace: wso2\n\
spec:\n\
  selector:\n\
    deployment: wso2apim-with-analytics-apim-analytics\n\
  ports:\n\
    -\n\
      name: 'thrift'\n\
      port: 7612\n\
      protocol: TCP\n\
    -\n\
      name: 'thrift-ssl'\n\
      port: 7712\n\
      protocol: TCP\n\
    -\n\
      name: 'rest-api-port-1'\n\
      protocol: TCP\n\
      port: 9444\n\
    -\n\
      name: 'rest-api-port-2'\n\
      protocol: TCP\n\
      port: 9091\n\
    -\n\
      name: 'rest-api-port-3'\n\
      protocol: TCP\n\
      port: 7071\n\
    -\n\
      name: 'rest-api-port-4'\n\
      protocol: TCP\n\
      port: 7444\n---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
kind: Service\n\
metadata:\n\
  name: wso2apim-with-analytics-apim-service\n\
  namespace: wso2\n\
  labels:\n\
    deployment: wso2apim-with-analytics-apim\n\
spec:\n\
  selector:\n\
    deployment: wso2apim-with-analytics-apim\n\
  type: NodePort\n\
  ports:\n\
    -\n\
      name: pass-through-http\n\
      protocol: TCP\n\
      port: 8280\n\
    -\n\
      name: pass-through-https\n\
      protocol: TCP\n\
      port: 8243\n\
    -\n\
      name: servlet-http\n\
      protocol: TCP\n\
      port: 9763\n\
    -\n\
      name: servlet-https\n\
      protocol: TCP\n\
      nodePort: 30956\n\
      port: 9443\n---\n" >> deployment.yaml

echo -e "apiVersion: apps/v1\n\
kind: Deployment\n\
metadata:\n\
  name: wso2apim-with-analytics-mysql-deployment\n\
  namespace: wso2\n\
spec:\n\
  replicas: 1\n\
  selector:\n\
    matchLabels:\n\
      deployment: wso2apim-with-analytics-mysql\n\
  template:\n\
    metadata:\n\
      labels:\n\
        deployment: wso2apim-with-analytics-mysql\n\
    spec:\n\
      containers:\n\
        - name: wso2apim-with-analytics-mysql\n\
          image: mysql:5.7\n\
          imagePullPolicy: IfNotPresent\n\
          securityContext:\n\
            runAsUser: 999\n\
          env:\n\
            - name: MYSQL_ROOT_PASSWORD\n\
              value: root\n\
            - name: MYSQL_USER\n\
              value: wso2carbon\n\
            - name: MYSQL_PASSWORD\n\
              value: wso2carbon\n\
          ports:\n\
            - containerPort: 3306\n\
              protocol: TCP\n\
          volumeMounts:\n\
            - name: mysql-dbscripts\n\
              mountPath: /docker-entrypoint-initdb.d\n\
          args: ['--max-connections', '10000']\n\
      volumes:\n\
        - name: mysql-dbscripts\n\
          configMap:\n\
            name: mysql-dbscripts\n\
      serviceAccountName: 'wso2svc-account'\n---\n" >> deployment.yaml

echo -e "apiVersion: apps/v1\n\
kind: Deployment\n\
metadata:\n\
  name: wso2apim-with-analytics-apim-analytics-deployment\n\
  namespace: wso2\n\
spec:\n\
  replicas: 1\n\
  minReadySeconds: 30\n\
  selector:\n\
    matchLabels:\n\
      deployment: wso2apim-with-analytics-apim-analytics\n\
  strategy:\n\
    rollingUpdate:\n\
      maxSurge: 1\n\
      maxUnavailable: 0\n\
    type: RollingUpdate\n\
  template:\n\
    metadata:\n\
      labels:\n\
        deployment: wso2apim-with-analytics-apim-analytics\n\
    spec:\n\
      containers:\n\
        - name: wso2apim-with-analytics-apim-analytics\n\
          image: docker.wso2.com/wso2am-analytics-worker:2.6.0\n\
          resources:\n\
            limits:\n\
              memory: '2Gi'\n\
            requests:\n\
              memory: '2Gi'\n\
          livenessProbe:\n\
            exec:\n\
              command:\n\
                - /bin/sh\n\
                - -c\n\
                - nc -z localhost 7712\n\
            initialDelaySeconds: 10\n\
            periodSeconds: 10\n\
          readinessProbe:\n\
            exec:\n\
              command:\n\
                - /bin/sh\n\
                - -c\n\
                - nc -z localhost 7712\n\
            initialDelaySeconds: 10\n\
            periodSeconds: 10\n\
          lifecycle:\n\
            preStop:\n\
              exec:\n\
                command:  ['sh', '-c', '${WSO2_SERVER_HOME}/bin/worker.sh stop']\n\
          imagePullPolicy: Always\n\
          securityContext:\n\
            runAsUser: 802\n\
          ports:\n\
            -\n\
              containerPort: 9764\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 9444\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 7612\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 7712\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 9091\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 7071\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 7444\n\
              protocol: 'TCP'\n\
          volumeMounts:\n\
            - name: apim-analytics-conf-worker\n\
              mountPath: /home/wso2carbon/wso2-config-volume/conf/worker\n\
      initContainers:\n\
        - name: init-apim-with-analytics\n\
          image: busybox\n\
          command: ['sh', '-c', 'echo -e \"checking for the availability of MySQL\"; while ! nc -z wso2apim-with-analytics-rdbms-service 3306; do sleep 1; printf \"-\"; done; echo -e \"  >> MySQL started\";']\n\
      serviceAccountName: 'wso2svc-account'\n\
      imagePullSecrets:\n\
        - name: wso2creds\n\
      volumes:\n\
        - name: apim-analytics-conf-worker\n\
          configMap:\n\
            name: apim-analytics-conf-worker\n---\n" >> deployment.yaml

echo -e "apiVersion: apps/v1\n\
kind: Deployment\n\
metadata:\n\
  name: wso2apim-with-analytics-apim\n\
  namespace: wso2\n\
spec:\n\
  replicas: 1\n\
  minReadySeconds: 30\n\
  selector:\n\
    matchLabels:\n\
      deployment: wso2apim-with-analytics-apim\n\
  strategy:\n\
    rollingUpdate:\n\
      maxSurge: 1\n\
      maxUnavailable: 0\n\
    type: RollingUpdate\n\
  template:\n\
    metadata:\n\
      labels:\n\
        deployment: wso2apim-with-analytics-apim\n\
    spec:\n\
      containers:\n\
        - name: wso2apim-with-analytics-apim-worker\n\
          image: docker.wso2.com/wso2am:2.6.0\n\
          livenessProbe:\n\
            exec:\n\
              command:\n\
                - /bin/bash\n\
                - -c\n\
                - nc -z localhost 9443\n\
            initialDelaySeconds: 60\n\
            periodSeconds: 10\n\
          readinessProbe:\n\
            exec:\n\
              command:\n\
                - /bin/bash\n\
                - -c\n\
                - nc -z localhost 9443\n\
            initialDelaySeconds: 60\n\
            periodSeconds: 10\n\
          imagePullPolicy: Always\n\
          ports:\n\
            -\n\
              containerPort: 8280\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 8243\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 9763\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 9443\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 5672\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 9711\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 9611\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 7711\n\
              protocol: 'TCP'\n\
            -\n\
              containerPort: 7611\n\
              protocol: 'TCP'\n\
          volumeMounts:\n\
            - name: apim-conf\n\
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf\n\
            - name: apim-conf-datasources\n\
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf/datasources\n\
      initContainers:\n\
        - name: init-apim\n\
          image: busybox\n\
          command: ['sh', '-c', 'echo -e \"checking for the availability of wso2apim-with-analytics-apim-analytics\"; while ! nc -z wso2apim-with-analytics-apim-analytics-service 7712; do sleep 1; printf \"-\"; done; echo -e \" >> wso2is-with-analytics-is-analytics started\";']\n\
      serviceAccountName: 'wso2svc-account'\n\
      imagePullSecrets:\n\
        - name: wso2creds\n\
      volumes:\n\
        - name: apim-conf\n\
          configMap:\n\
            name: apim-conf\n\
        - name: apim-conf-datasources\n\
          configMap:\n\
            name: apim-conf-datasources\n---\n" >> deployment.yaml

echoBold  "1. Run kubectl create -f deployment.yaml in your terminal"
echoBold "2. Try navigating to https://<NODE-IP>:30956/carbon/ from your favourite browser"
