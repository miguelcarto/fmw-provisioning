"""
Creates a Managed Server.
The script must be executed after a domain creation issued by createDomain operation.

This script should not be issue by himself. it is used by the external util createServer.sh

Please refer to documentation about the command and the expected results.

"""
import sys
sys.path.append( os.getenv('WLST_LIB'))


import os.path
from geos import utils

# Read environment variables 
bbShortName = os.getenv('FUNCTIONAL_BLOCK_NAME') + '_' + os.getenv('BUILDING_BLOCK_NAME')
bbHome = os.getenv('BUILDING_BLOCK_HOME')
mwHome = os.getenv('MIDDLEWARE_HOME')
mServerHome = bbHome + '/' + MNG_SERVER_HOME + '/domains/' + os.getenv('TARGET_ENVIRONMENT') + '_' + bbShortName
nodemanagerHome = bbHome + '/' + NM_HOME
jdkHome = bbHome + '/jdk'

domainName= os.getenv('TARGET_ENVIRONMENT') + '_' + bbShortName
adminServerName = bbShortName + '_' + WLS_ADM_SERVER_NAME
adminServerHost = WLS_ADM_SERVER_HOSTNAME
adminServerPort = WLS_ADM_SERVER_PORT

nodeManagerUsername = WLS_NM_USERNAME
nodeManagerMode = 'plain'
nodeManagerPort = WLS_NM_PORT
nodeManagerHost = WLS_NM_ADDR

myServerName = sys.argv[1]

# Prompt weblogic Password
weblogicPassword = utils.getpassword('WEBLOGIC')
adminAddress = 't3s://' + adminServerHost + ':' + str(int(adminServerPort) + 1)
connect('weblogic', weblogicPassword, adminAddress)

# check for managed server name

serverList = cmo.getServers()
currentServer = None

print 'Searching for ' + myServerName
for aServer in serverList:
   if myServerName == aServer.getName():
      currentServer = aServer


if currentServer is None:
   disconnect()
   
   print 'Server ' + myServerName + ' doesn\'t exist. Aborting'
   sys.exit(1)

machine = currentServer.getMachine()
machineName = machine.getName() 

cd('/Servers/' + myServerName + '/Machine/'+ machineName +'/NodeManager/' + machineName)
machineAddress = cmo.getListenAddress()
machinePort = cmo.getListenPort()


cfgNodemanager = nodemanagerHome
nodemanagerHome = nodemanagerHome+ '/' + machineName;

print nodemanagerHome + ' exists ?'
if not os.path.exists(nodemanagerHome +'/nodemanager.domains'):
   print 'Creating nodemanager properties'
   fileName = 'nodemanager.properties';
   content='DomainsFile=' + nodemanagerHome + '/nodemanager.domains\nLogLimit=0\nPropertiesVersion=12.2.1\nAuthenticationEnabled=true\nNodeManagerHome=' + nodemanagerHome + '\nJavaHome=' + jdkHome +'\nLogLevel=INFO\nDomainsFileEnabled=true\nStartScriptName=startWebLogic.sh\nListenAddress=' + machineAddress + '\nNativeVersionEnabled=true\nListenPort=' + str(machinePort) + '\nLogToStderr=true\nSecureListener=false\nLogCount=1\nStopScriptEnabled=false\nQuitEnabled=false\nLogAppend=true\nStateCheckInterval=500\nCrashRecoveryEnabled=true\nStartScriptEnabled=true\nLogFile=' + nodemanagerHome + '/nodemanager.log\nLogFormatter=weblogic.nodemanager.server.LogFormatter\nListenBacklog=50';
   utils.create_file(nodemanagerHome, fileName, content);
   os.rename(cfgNodemanager +'/nodemanager.domains', nodemanagerHome +'/nodemanager.domains')
   os.remove(cfgNodemanager +'/nodemanager.properties')

print 'Creating boot.properties';
mServerDirectoryName = mServerHome + '/servers/'+ myServerName +'/security';
fileName = 'boot.properties';
content = 'username=weblogic\npassword=' + weblogicPassword;
utils.create_file(mServerDirectoryName, fileName, content);

disconnect()
