import sys

sys.path.append(os.getenv('WLST_LIB'))

from fmw import utils

# Read environment variables 
bbShortName = os.getenv('FUNCTIONAL_BLOCK_NAME') + '_' + os.getenv('BUILDING_BLOCK_NAME')

mwHome = os.getenv('MIDDLEWARE_HOME')
bbHome = os.getenv('BUILDING_BLOCK_HOME')

domainHome = bbHome + '/' + ADMIN_SERVER_HOME + '/domains/' + os.getenv('TARGET_ENVIRONMENT') + '_' + bbShortName
jdkHome = bbHome + '/jdk'
nodemanagerHome = bbHome + '/' + NM_HOME

domainName= os.getenv('TARGET_ENVIRONMENT') + '_' + bbShortName
adminServerName = bbShortName + '_' + WLS_ADM_SERVER_NAME
adminServerHost = WLS_ADM_SERVER_HOSTNAME
adminServerPort = WLS_ADM_SERVER_PORT
coherenceClusterName = bbShortName + '_coh'
clusterName = bbShortName  +'_' + WLS_CLUSTER_NAME
managedServerHost = WLS_MNG_SERVER_HOSTNAME
managedServerPort = WLS_MNG_SERVER_PORT

nodeManagerUsername = WLS_NM_USERNAME
nodeManagerMode = 'plain'
nodeManagerPort = WLS_NM_PORT
nodeManagerHost = WLS_NM_ADDR

managedServerAdminHost = WLS_MNG_ADMIN_HOSTNAME
managedServerClusterHost = WLS_MNG_CLUSTER_HOSTNAME
managedServerClusterPort = WLS_MNG_CLUSTER_PORT

# Read Default template
readTemplate(mwHome+'/wlserver/common/templates/wls/wls.jar')

# Apply Domain Settings
print "Creating domain " + domainName
setOption('DomainName',domainName)
setOption('OverwriteDomain','true')
setOption('ServerStartMode', 'prod');
setOption('NodeManagerType', 'CustomLocationNodeManager');
setOption('NodeManagerHome', nodemanagerHome);
setOption('JavaHome', jdkHome )

cd('/')
set('Name', domainName)

cd('Security/'+ domainName +'/User/weblogic')

weblogicPassword = utils.getpassword('weblogic')
cmo.setUserPassword(weblogicPassword)

nodeManagerHostList = nodeManagerHost.split(',')
nodeManagerPortList = nodeManagerPort.split(',')

# Admin Machine/Nodemanager
machineName = "mac_%s_00" % bbShortName
print 'Creating Admin Server Machine/Nodemanager ' + machineName
cd('/')
adminMachine = create(machineName,'UnixMachine');
cd('/Machine/' + adminMachine.getName());
nodemanager = create(adminMachine.getName(),'NodeManager');
nodemanager.setListenAddress(nodeManagerHostList[0]);
nodemanager.setListenPort(int(nodeManagerPortList[0]));
nodemanager.setNMType(nodeManagerMode);

# Set Admin Server
print 'Setup Admin Server ' + adminServerName
cd('/')
cd('Servers/AdminServer')
set('Name', adminServerName)
cd('/Servers/' + adminServerName)
set('ListenAddress', adminServerHost)
set ('ListenPort', int(adminServerPort))

cmo.setMachine(adminMachine);

print 'Writing domain...'
writeDomain(domainHome)
closeTemplate()

print 'Opening Domain ' + domainName
readDomain(domainHome)


# Create Cluster

# Add Servers
mServerHostList=managedServerHost.split(',')
mServerPortList=managedServerPort.split(',')
mServerAdminHostList=managedServerAdminHost.split(',')
mServerClusterHostList=managedServerClusterHost.split(',')
mServerClusterPortList=managedServerClusterPort.split(',')

clusterAddress=mServerHostList[0]+':'+mServerPortList[0]
clIndex=1
while clIndex < len(mServerHostList):
   clusterAddress += ','+ mServerHostList[clIndex]+':'+mServerPortList[clIndex]
   clIndex += 1
   
cd('/')
domainCluster = create(clusterName,'Cluster')
domainCluster.setClusterMessagingMode('unicast');
domainCluster.setClusterBroadcastChannel('Channel_' + bbShortName)
domainCluster.setClusterAddress(clusterAddress)

iter=0
while iter < len(mServerHostList):
   cd ('/')
   
   # Create Server
   mServerName = "%s_0%d" % ( bbShortName, iter + 1 )
   print 'Creating Server ' + mServerName
   create(mServerName,'Server')

   # Create Machine/Nodemanager
   machineName = "mac_%s_0%d" % ( bbShortName, iter +1 )
   machine = create(machineName,'UnixMachine');
   cd('/Machine/' + machine.getName());
   nodemanager = create(machineName,'NodeManager');
   nodemanager.setListenAddress(nodeManagerHostList[iter+1]);
   nodemanager.setListenPort(int(nodeManagerPortList[iter+1]));
   nodemanager.setNMType(nodeManagerMode);
   
   currentServerListenAddress = mServerHostList[iter]
   currentServerAdminListenAddress = mServerAdminHostList[iter]
   hasAdminAddress = False
   if currentServerListenAddress != currentServerAdminListenAddress :
      hasAdminAddress = True
      currentServerListenAddress = currentServerAdminListenAddress
      
   
   cd('/Server/' + mServerName)
   set('ListenPort', int(mServerPortList[iter]))
   set('ListenAddress', currentServerListenAddress)
   set('Cluster', domainCluster)
   set('WeblogicPluginEnabled', true)
   set('AdministrationPort',int(mServerPortList[iter])+1)
   cmo.setMachine(machine)
   
   # Setup Cluster Channel Protocol
   clusterChannel = create('Channel_'+bbShortName,'NetworkAccessPoint');
   clusterChannel.setProtocol('cluster-broadcast')
   clusterChannel.setListenAddress(mServerClusterHostList[iter])
   clusterChannel.setListenPort(int(mServerClusterPortList[iter]))
   clusterChannel.setHttpEnabledForThisProtocol(false)
   clusterChannel.setTunnelingEnabled(false)
   clusterChannel.setOutboundEnabled(true)
   clusterChannel.setEnabled(true)
   
   if hasAdminAddress :
      # Setup service Channel if admin address is not equal to service address
      serviceChannel = create('Channel_srv_'+bbShortName,'NetworkAccessPoint');
      serviceChannel.setProtocol('http')
      serviceChannel.setListenAddress( mServerHostList[iter] )
      serviceChannel.setListenPort( int(mServerPortList[iter]) )
      serviceChannel.setHttpEnabledForThisProtocol(true)
      serviceChannel.setTunnelingEnabled(false)
      serviceChannel.setOutboundEnabled(true)
      serviceChannel.setEnabled(true)
   
   # Setup Loggers
   serverLog = create(mServerName,'Log')
   serverLog.setRotationType('byTime')
   serverLog.setLogFileSeverity('Info')
   serverLog.setStdoutSeverity('Notice')
   serverLog.setDomainLogBroadcastSeverity('Error')
   
   webServer = create(mServerName,'WebServer')
   cd('WebServer/' + mServerName)
   create(mServerName,'WebServerLog')
   webServer.getWebServerLog().setLoggingEnabled(java.lang.Boolean('true'))
   webServer.getWebServerLog().setRotationType('byTime')

   # Setup Server Start Args

   # Assign to Cluster
   cd('/')
   assign('Server', mServerName, 'Cluster', clusterName)
      
   iter+=1

   
# Nodemanager Credentials   
print "Set NodeManager Credentials (username: nm_admin)"
cd("/SecurityConfiguration/" + domainName);
cmo.setNodeManagerUsername(nodeManagerUsername);

nodeManagerPassword = utils.getpassword('NM_ADMIN')
cmo.setNodeManagerPasswordEncrypted(nodeManagerPassword)


# Enable Admin Port
print "Setup Admin Port"
cd('/');
set('AdministrationPort',int(adminServerPort)+1)
set('AdministrationPortEnabled', true)

print 'Creating nodemanager properties'

cfgNodemanager = nodemanagerHome
nodemanagerHome = nodemanagerHome+ '/' + adminMachine.getName();

fileName = 'nodemanager.properties';
content='DomainsFile=' + nodemanagerHome + '/nodemanager.domains\nLogLimit=0\nPropertiesVersion=12.2.1\nAuthenticationEnabled=true\nNodeManagerHome=' + nodemanagerHome + '\nJavaHome=' + jdkHome +'\nLogLevel=INFO\nDomainsFileEnabled=true\nStartScriptName=startWebLogic.sh\nListenAddress=' + nodeManagerHostList[0] + '\nNativeVersionEnabled=true\nListenPort=' + nodeManagerPortList[0] + '\nLogToStderr=true\nSecureListener=false\nLogCount=1\nStopScriptEnabled=false\nQuitEnabled=false\nLogAppend=true\nStateCheckInterval=500\nCrashRecoveryEnabled=true\nStartScriptEnabled=true\nLogFile=' + nodemanagerHome + '/nodemanager.log\nLogFormatter=weblogic.nodemanager.server.LogFormatter\nListenBacklog=50';
utils.create_file(nodemanagerHome, fileName, content);

os.rename(cfgNodemanager +'/nodemanager.domains', nodemanagerHome +'/nodemanager.domains')
os.remove(cfgNodemanager +'/nodemanager.properties')


print "Finishing, this may take a while...."
updateDomain()
closeDomain()

print 'Creating boot.properties';
adminServerDirectoryName = domainHome + '/servers/'+ adminServerName +'/security';
fileName = 'boot.properties';
content = 'username=weblogic\npassword=' + weblogicPassword;
utils.create_file(adminServerDirectoryName, fileName, content);
