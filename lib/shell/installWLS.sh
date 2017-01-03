#!/bin/sh
###############################################################################
# File         : installWLS.sh
# Description  : Installs the Weblogic (WLS) on the Building Block Home
#
# Author       : 
# Version      : 0.0.1
# Date         : 05-11-2015
# Requires Env :
#                JDK_HOME - Building Block's JDK Home
#                STAGING_DIRECTORY - Directory holding installation files
#                FMW_FILE_NAME - Installer
#                
#
###############################################################################

FMW_FILE_NAME="fmw_12.2.1.0.0_wls.jar"
export FMW_FILE_NAME

echo
echo "*** WLS Installation ***"
echo

create_install_response_file "wls"
${BUILDING_BLOCK_JDK_HOME}/bin/java -Xms1024m -Xmx1024m -jar ${STAGING_DIRECTORY}/${FMW_FILE_NAME} -silent -responseFile ${TEMPORARY_DIRECTORY}/wls.rsp

