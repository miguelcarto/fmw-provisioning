#!/bin/sh
###############################################################################
# File         : preCheck.sh
# Description  : Performs an initial valitation of the installation
#
# Author       : Oracle Consulting Services PT
# Version      : 0.0.1 
# Date         : 05-11-2015
# Depends      : env.sh
#
# Requires Env : 
#
# Produces Env :
# 
###############################################################################

echo
echo "*** Pre Validation ***"
echo

is_valid=true

if [ -z "$TARGET_ENVIRONMENT" ]; then
   echo "TARGET_ENVIRONMENT is not set"
   is_valid=false
else
   echo "TARGET_ENVIRONMENT is set to $TARGET_ENVIRONMENT"
fi

if [ -z "$FUNCTIONAL_BLOCK_NAME" ]; then
   echo "FUNCTIONAL_BLOCK_NAME is not set"
   is_valid=false
else
   echo "FUNCTIONAL_BLOCK_NAME is set to $FUNCTIONAL_BLOCK_NAME"
fi

if [ -z "$BUILDING_BLOCK_NAME" ]; then
   echo "BUILDING_BLOCK_NAME is not set"
   is_valid=false
else
   echo "BUILDING_BLOCK_NAME is set to $BUILDING_BLOCK_NAME"
fi

if [ -d "${BUILDING_BLOCK_HOME}" ]; then
    if [  "$(ls -A ${MIDDLEWARE_HOME} 2> /dev/null)" != ""  ]; then
        echo "Building Block FMW Home ${MIDDLEWARE_HOME} already exists. Skipping FMW installation."
        is_valid=false
    fi
else
   mkdir -p ${BUILDING_BLOCK_HOME}
   if [ $? -ne 0 ] ; then
      echo "Could not create Building Block home at ${BUILDING_BLOCK_HOME}, terminating."
      is_valid=false
   else
      echo "Created building home at ${BUILDING_BLOCK_HOME}"
   fi
fi

# If any of the validations failed exit with error
echo
if [ ! "$is_valid" = true ] ; then
   echo "Pre Validation has failed. Terminating."
   exit 1
else
   echo "Pre Validation has passed."
fi

###############################################################################
#
#
#
###############################################################################