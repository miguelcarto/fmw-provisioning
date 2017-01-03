#!/bin/sh
###############################################################################
# File         : utils.sh
# Description  : 
#
# Author       : BPI
# Version      : 0.0.1
# Date         : 11-11-2015
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

create_central_inventory(){
   echo
   echo "*** Create Central Inventory ***"
   echo
   if [[ ! $(ls /etc/oraInst.loc) ]]; then
      sudo -E "${SCRIPTS_HOME}/functions/createCentralInventory.sh"
      if [ $? -ne 0 ] ; then
         echo "${SCRIPTS_HOME}/functions/createCentralInventory.sh failed to execute. Terminating."
         exit 1
      fi
   else
      echo "Central Inventory already exists."
   fi
}


###############################################################################
#
#
#
###############################################################################

create_install_response_file () {

   installType=$1

   case "$installType" in
      "ohs")
         INSTALLATION="Standalone HTTP Server (Managed independently of WebLogic server)"
         ;;
      "soa")
         INSTALLATION="SOA Suite"
         ;;
      "osb")
         INSTALLATION="Service Bus"
         ;;
      "fmw")
         INSTALLATION="Fusion Middleware Infrastructure"
         ;;
      *) 
         echo "Invalid Installation Type";
         exit 1
         ;;
   esac 

   echo "[ENGINE]
Response File Version=1.0.0.0.0
[GENERIC]
ORACLE_HOME=/opt/oracle/${FUNCTIONAL_BLOCK_NAME}/${BUILDING_BLOCK_NAME}/${BUILDING_BLOCK_VERSION}/fmw
INSTALL_TYPE=${INSTALLATION}
DECLINE_SECURITY_UPDATES=true
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false" > ${TEMPORARY_DIRECTORY}/${installType}.rsp
}


###############################################################################
#
#
#
###############################################################################
