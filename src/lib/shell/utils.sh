#!/bin/sh
###############################################################################
# File         : utils.sh
# Description  : 
#
# Author       : mcarto
# Version      : 0.0.1
# Requires Env :
#                FUNCTIONAL_BLOCK_NAME
#                BUILDING_BLOCK_NAME
#                BUILDING_BLOCK_VERSION
#                SCRIPTS_TMP
#                
# Produces Env : 
#
###############################################################################


###############################################################################
#
#
#
###############################################################################

get_password() {
   key=${1^^}
   passwordFile=${SCRIPTS_TMP}/password.properties
   value=$(grep $key $passwordFile)
   
   if [ -z $value ]; then
      echo -n "$key password: " >&2; echo >&2
      read -s password
      echo "$key=$password" >> $passwordFile
   else
      password=$(echo $value | cut -f2 -d'=')
   fi
   
   FOUND_PASSWORD=$password
}


###############################################################################
#
#
#
###############################################################################

