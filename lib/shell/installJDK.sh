#!/bin/sh
###############################################################################
# File         : installJDK.sh
# Description  : Configures the JDK for a Building Block installation
#
# Author       : Oracle Consulting Services PT
# Version      : 0.0.1
# Date         : 05-11-2015
# Requires Env :
#                STAGING_DIRECTORY - Location of the JDK binary
#                JDK_FILE - JDK binary file name
#                
# Produces Env : BUILDING_BLOCK_JDK_HOME
#
###############################################################################
# JDK Variables
JDK_FILE_NAME="jdk-8u66-linux-x64.tar.gz"
export JDK_FILE_NAME

echo
echo "*** JDK Installation ***"
echo

skip_installation=false
if [ -d "${BUILDING_BLOCK_HOME}/jdk" ]; then
   echo "Building Block JDK Home ${BUILDING_BLOCK_HOME}/jdk already exists. Skipping JDK installation."
   skip_installation=true
fi

if [ "$skip_installation" = false ] ; then
   if [ $? -ne 0 ] ; then
      echo "Could not create Building Block home at ${BUILDING_BLOCK_HOME}, terminating."
      exit 1
   else
      echo "Created building home at ${BUILDING_BLOCK_HOME}"
   fi

   echo "Extracting ${STAGING_DIRECTORY}/${JDK_FILE_NAME} into ${BUILDING_BLOCK_HOME}"
   tar xzf ${STAGING_DIRECTORY}/${JDK_FILE_NAME} -C ${BUILDING_BLOCK_HOME}
   if [ $? -ne 0 ] ; then
      echo "Could not extract JDK. Terminating."
      exit 1
   else
      echo "Done"
   fi

   echo "Renaming ${BUILDING_BLOCK_HOME}/jdk* to ${BUILDING_BLOCK_HOME}/jdk"
   mv ${BUILDING_BLOCK_HOME}/jdk* ${BUILDING_BLOCK_HOME}/jdk
   if [ $? -ne 0 ] ; then
      echo "Could not perform rename operation. Terminating."
      exit 1
   else
      echo "Done"
   fi
fi

BUILDING_BLOCK_JDK_HOME="${BUILDING_BLOCK_HOME}/jdk"
export BUILDING_BLOCK_JDK_HOME

