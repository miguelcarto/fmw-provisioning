#!/bin/sh
###############################################################################
# File         : installJDK.sh
# Description  : Configures the JDK for a FMW installation
#
# Author       : mcarto
# Version      : 0.0.1
# Requires Env : SOFTWARE_DIRECTORY - Location of the JDK binary
#                
# Produces Env : JDK_HOME
#
###############################################################################


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

   JDK_FILE_NAME=$(ls ${SOFTWARE_DIRECTORY}/jdk*)
   echo "Extracting ${JDK_FILE_NAME} into ${BUILDING_BLOCK_HOME}"
   tar xzf ${JDK_FILE_NAME} -C ${BUILDING_BLOCK_HOME}
   if [ $? -ne 0 ] ; then
      echo "Could not extract JDK. Terminating."
      exit 1
   fi

   echo "Renaming ${BUILDING_BLOCK_HOME}/jdk* to ${BUILDING_BLOCK_HOME}/jdk"
   mv ${BUILDING_BLOCK_HOME}/jdk* ${BUILDING_BLOCK_HOME}/jdk
   if [ $? -ne 0 ] ; then
      echo "Could not perform rename operation. Terminating."
      exit 1
   fi
fi

JDK_HOME="${BUILDING_BLOCK_HOME}/jdk"
export JDK_HOME

