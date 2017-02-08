#!/bin/bash
#
# Requires Installed FMW
#############################

TOOLS_PATH=$(dirname $0)
. $TOOLS_PATH/../config/env.sh

# In order to add you custom WLST scripts to the PATH
# just add them to the CLASSPATH
WLST_PATH=$TOOLS_PATH/../wlst
export WLST_LIB=$WLST_PATH

propertiesFile=$1
shift

export WLST_PROPERTIES="-Dweblogic.security.SSL.ignoreHostnameVerification=true -Dweblogic.security.TrustKeyStore=DemoTrust"
CLASSPATH=$WLST_PATH $MIDDLEWARE_HOME/oracle_common/common/bin/wlst.sh -skipWLSModuleScanning -loadProperties $propertiesFile $@
