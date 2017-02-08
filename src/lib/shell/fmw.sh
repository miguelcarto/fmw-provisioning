#!/bin/sh
###############################################################################
# File         : fmw.sh
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

setup_custom_environment() {
    echo 'Building setUserOverrides.sh'
    sed -i -e '/DERBY_FLAG="true"/ s:DERBY_FLAG="true":DERBY_FLAG="false":' ${DOMAIN_CONFIGURATION_HOME}/bin/setDomainEnv.sh    
    ADMIN_SERVER_HEAP_SIZE=1024m
    ADMIN_SERVER_PERM_SIZE=512m
    MANAGED_SERVER_HEAP_SIZE=1024m
    MANAGED_SERVER_PERM_SIZE=512m
    COHERENCE_SERVER_HEAP_SIZE=512m
    COHERENCE_SERVER_PERM_SIZE=256m

    touch ${DOMAIN_CONFIGURATION_HOME}/bin/setUserOverrides.sh
    chmod u+x ${DOMAIN_CONFIGURATION_HOME}/bin/setUserOverrides.sh

    echo '#!/bin/sh

ADMIN_SERVER_MEM_ARGS="-Xms'${ADMIN_SERVER_HEAP_SIZE}' -Xmx'${ADMIN_SERVER_HEAP_SIZE}'"
SERVER_MEM_ARGS="-Xms'${MANAGED_SERVER_HEAP_SIZE}' -Xmx'${MANAGED_SERVER_HEAP_SIZE}'"
COHERENCE_SERVER_MEM_ARGS="-Xms'${COHERENCE_SERVER_HEAP_SIZE}' -Xmx'${COHERENCE_SERVER_HEAP_SIZE}'"
MONITORING_ARGS="-XX:+UnlockCommercialFeatures -XX:+FlightRecorder"
COHERENCE_MONITORING_ARGS="-Dtangosol.coherence.management=all -Dtangosol.coherence.management.remote=true"
SSL_IGNORE="-Dweblogic.security.SSL.ignoreHostnameVerification=true"
EXTRA_JAVA_PROPERTIES="$SSL_IGNORE $EXTRA_JAVA_PROPERTIES"

if [ "${ADMIN_URL}" = "" ] ; then
   USER_MEM_ARGS="${ADMIN_SERVER_MEM_ARGS}"
else
   USER_MEM_ARGS="${SERVER_MEM_ARGS} ${MONITORING_ARGS}"
   EXTRA_JAVA_PROPERTIES="${COHERENCE_MONITORING_ARGS} ${EXTRA_JAVA_PROPERTIES}"

fi

export EXTRA_JAVA_PROPERTIES
export USER_MEM_ARGS' > ${DOMAIN_CONFIGURATION_HOME}/bin/setUserOverrides.sh


}

###############################################################################
#
#
#
###############################################################################

validate_environment() {

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
   if [[ ! $(ls ${ORACLE_INVENTORY_PTR}) ]]; then
      sudo -E "${SCRIPTS_HOME}/lib/shell/createCentralInventory.sh"
      if [ $? -ne 0 ] ; then
         echo "create Central Repository failed to execute. Terminating."
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
      "wls")
         INSTALLATION="WebLogic Server"
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
