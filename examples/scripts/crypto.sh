#!/bin/bash +x
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#set -e
ORGS="\
   $1:$2:$3:$4:$5 \
"

USE_TLS=false

# If true, uses both a root and intermediate CA
INTERMEDIATE_CA=false

# If true, recreate crypto if it already exists
RECREATE=true

# Path to fabric CA executables
FCAHOME=$GOPATH/src/github.com/hyperledger/fabric-ca
SERVER=$FCAHOME/bin/fabric-ca-server
CLIENT=$FCAHOME/bin/fabric-ca-client

# Crypto-config directory
CDIR="crypto-config"

# More verbose logging for fabric-ca-server & fabric-ca-client
DEBUG=-d

# Main fabric CA crypto config function
function main {
   if [ -d $CDIR -a "$RECREATE" = false ]; then
      echo "#################################################################"
      echo "#######    Crypto material already exists   #####################"
      echo "#################################################################"
      exit 0
   fi
   echo "#################################################################"
   echo "#######    Generating crypto material using Fabric CA  ##########"
   echo "#################################################################"
   echo "Checking executables ..."
   mydir=`pwd`
   checkExecutables
   cd $mydir
   if [ -d $CDIR ]; then
      echo "Cleaning up ..."
      stopAllCAs
      #rm -rf $CDIR
   fi
   echo "Setting up organizations ..."
   setupOrgs
   echo "Finishing ..."
   stopAllCAs
   echo "Complete"
}

# Check and build executables as needed
function checkExecutables {
   if [ ! -d $FCAHOME ]; then
      fatal "Directory does not exist: $FCAHOME"
   fi
   if [ ! -x $SERVER ]; then
      dir=`pwd`
      cd $FCAHOME
      make fabric-ca-server
      if [ $? -ne 0 ]; then
         fatal "Failed to build $SERVER"
      fi
   fi
   if [ ! -x $CLIENT ]; then
      dir=`pwd`
      cd $FCAHOME
      make fabric-ca-client
      if [ $? -ne 0 ]; then
         fatal "Failed to build $CLIENT"
      fi
   fi
}

# Setup orderer and peer organizations
function setupOrgs {
   for ORG in $ORGS
   do
      setupOrg $ORG
   done
}

# Start an organization's root and intermediate CA servers
#   setupOrg <type>:<orgName>:<rootCAPort>:<intermediateCAPort>:<numNodes>
function setupOrg {
   IFSBU=$IFS
   IFS=: args=($1)
   if [ ${#args[@]} -ne 5 ]; then
      fatal "setupOrg: bad org spec: $1"
   fi
   type=${args[0]}
   orgName=${args[1]}
   orgDir=${CDIR}/${type}Organizations/${args[1]}
   rootCAPort=${args[2]}
   intermediateCAPort=${args[3]}
   numNodes=${args[4]}
   IFS=$IFSBU
   # Start the root CA server
   startCA $orgDir/ca/root $rootCAPort $orgName
   # Enroll an admin user with the root CA
   usersDir=$orgDir/users
   adminHome=$usersDir/rootAdmin
   enroll $adminHome http://admin:adminpw@localhost:$rootCAPort $orgName
   if [ "$INTERMEDIATE_CA" == "true" ]; then
      # Start the intermediate CA server
      startCA $orgDir/ca/intermediate $intermediateCAPort $orgName http://admin:adminpw@localhost:$rootCAPort
      # Enroll an admin user with the intermediate CA
      adminHome=$usersDir/intermediateAdmin
      intermediateCAURL=http://admin:adminpw@localhost:$intermediateCAPort
      enroll $adminHome $intermediateCAURL $orgName
   else
      intermediateCAPort=$rootCAPort
      intermediateCAURL=http://admin:adminpw@localhost:$rootCAPort
   fi
   # Register and enroll admin with the intermediate CA
   adminUserHome=$usersDir/Admin@${orgName}
   registerAndEnroll $adminHome $adminUserHome $intermediateCAPort $orgName nodeAdmin
   # Register and enroll user1 with the intermediate CA
   user1UserHome=$usersDir/User1@${orgName}
   registerAndEnroll $adminHome $user1UserHome $intermediateCAPort $orgName
   # Create nodes (orderers or peers)
   nodeCount=0
   while [ $nodeCount -lt $numNodes ]; do
      if [ $numNodes -gt 1 ]; then
         nodeDir=$orgDir/${type}s/${type}${nodeCount}.${orgName}
      else
         nodeDir=$orgDir/${type}s/${type}.${orgName}
      fi
      mkdir -p $nodeDir
      # Get TLS crypto for this node
      tlsEnroll $nodeDir $rootCAPort $orgName
      # Register and enroll this node's identity
      registerAndEnroll $adminHome $nodeDir $intermediateCAPort $orgName
      normalizeMSP $nodeDir $orgName $adminUserHome
      nodeCount=$(expr $nodeCount + 1)
   done
   # Get CA certs from intermediate CA
   getcacerts $orgDir $intermediateCAURL
   # Rename MSP files to names expected by end-to-end
   normalizeMSP $orgDir $orgName $adminUserHome
   normalizeMSP $adminHome $orgName
   normalizeMSP $adminUserHome $orgName
   normalizeMSP $user1UserHome $orgName
}

# Start a root CA server:
#    startCA <homeDirectory> <listeningPort> <orgName>
# Start an intermediate CA server:
#    startCA <homeDirectory> <listeningPort> <orgName> <parentURL>
function startCA {
   homeDir=$1; shift
   port=$1; shift
   orgName=$1; shift
   mkdir -p $homeDir
   export FABRIC_CA_SERVER_HOME=$homeDir
   if [ $# -gt 0 ]; then
      $SERVER start -p $port -b admin:adminpw -u $1 $DEBUG > $homeDir/server.log 2>&1&
   else
      $SERVER start -p $port -b admin:adminpw $DEBUG > $homeDir/server.log 2>&1&
   fi
   echo $! > $homeDir/server.pid
   if [ $? -ne 0 ]; then
      fatal "Failed to start server in $homeDir"
   fi
   debug "Starting CA server in $homeDir on port $port ..."
   sleep 1
   checkCA $homeDir $port
   # Get the TLS crypto for this CA
   tlsEnroll $homeDir $port $orgName
}

# Make sure a CA server is running
#    checkCA <homeDirectory>
function checkCA {
   pidFile=$1/server.pid
   if [ ! -f $pidFile ]; then
      fatal  "No PID file for CA server at $1"
   fi
   pid=`cat $pidFile`
   if ps -p $pid > /dev/null
   then
      debug "CA server is started in $1 and listening on port $2"
   else
      fatal "CA server is not running at $1; see logs at $1/server.log"
   fi
}

# Stop all CA servers
function stopAllCAs {
   for pidFile in `find $CDIR -name server.pid`
   do
      if [ ! -f $pidFile ]; then
         fatal "\"$pidFile\" is not a file"
      fi
      pid=`cat $pidFile`
      dir=$(dirname $pidFile)
      debug "Stopping CA server in $dir with PID $pid ..."
      if ps -p $pid > /dev/null
      then
         kill -9 $pid
         wait $pid 2>/dev/null
         rm -f $pidFile
         debug "Stopped CA server in $dir with PID $pid"
      fi
   done
}

# Register a new user
#    register <user> <password> <registrarHomeDir>
function register {
   export FABRIC_CA_CLIENT_HOME=$3
   mkdir -p $3
   logFile=$3/register.log
   $CLIENT register --id.name $1 --id.secret $2 --id.type user --id.affiliation org1 $DEBUG > $logFile 2>&1
   if [ $? -ne 0 ]; then
      fatal "Failed to register $1 with CA as $3; see $logFile"
   fi
   debug "Registered user $1 with intermediate CA as $3"
}

# Enroll an identity
#    enroll <homeDir> <serverURL> <orgName> [<args>]
function enroll {
   homeDir=$1; shift
   url=$1; shift
   orgName=$1; shift
   mkdir -p $homeDir
   export FABRIC_CA_CLIENT_HOME=$homeDir
   logFile=$homeDir/enroll.log
   # Get an enrollment certificate
   $CLIENT enroll -u $url $DEBUG $* > $logFile 2>&1
   if [ $? -ne 0 ]; then
      fatal "Failed to enroll $homeDir with CA at $url; see $logFile"
   fi
   # Get a TLS certificate
   debug "Enrolled $homeDir with CA at $url"
}

# Register and enroll a new user
#    registerAndEnroll <registrarHomeDir> <registreeHomeDir> <serverPort> <orgName> [<userName>]
function registerAndEnroll {
   userName=$5
   if [ "$userName" = "" ]; then
      userName=$(basename $2)
   fi
   register $userName "secret" $1
   enroll $2 http://${userName}:secret@localhost:$3 $4
}

# Enroll to get TLS crypto material
#    tlsEnroll <homeDir> <serverPort> <orgName>
function tlsEnroll {
   homeDir=$1
   port=$2
   orgName=$3
   host=$(basename $homeDir),$(basename $homeDir | cut -d'.' -f1)
   tlsDir=$homeDir/tls
   srcMSP=$tlsDir/msp
   dstMSP=$homeDir/msp
   enroll $tlsDir http://admin:adminpw@localhost:$port $orgName --csr.hosts $host --enrollment.profile tls
   cp $srcMSP/signcerts/* $tlsDir/server.crt
   cp $srcMSP/keystore/* $tlsDir/server.key
   mkdir -p $dstMSP/keystore
   cp $srcMSP/keystore/* $dstMSP/keystore
   mkdir -p $dstMSP/tlscacerts
   cp $srcMSP/tlscacerts/* $dstMSP/tlscacerts/tlsca.${orgName}-cert.pem
   if [ -d $srcMSP/tlsintermediatecerts ]; then
      cp $srcMSP/tlsintermediatecerts/* $tlsDir/ca.crt
      mkdir -p $dstMSP/tlsintermediatecerts
      cp $srcMSP/tlsintermediatecerts/* $dstMSP/tlsintermediatecerts
   else
      cp $srcMSP/tlscacerts/* $tlsDir/ca.crt
   fi
   rm -rf $srcMSP $homeDir/enroll.log $homeDir/fabric-ca-client-config.yaml
}

# Rename MSP files as is expected by the e2e example
#    normalizeMSP <home> <orgName> <adminHome>
function normalizeMSP {
   userName=$(basename $1)
   mspDir=$1/msp
   orgName=$2
   admincerts=$mspDir/admincerts
   cacerts=$mspDir/cacerts
   intcerts=$mspDir/intermediatecerts
   signcerts=$mspDir/signcerts
   cacertsfname=$cacerts/ca.${orgName}-cert.pem
   if [ ! -f $cacertsfname ]; then
      mv $cacerts/* $cacertsfname
   fi
   intcertsfname=$intcerts/ca.${orgName}-cert.pem
   if [ ! -f $intcertsfname ]; then
      if [ -d $intcerts ]; then
         mv $intcerts/* $intcertsfname
      fi
   fi
   signcertsfname=$signcerts/${userName}-cert.pem
   if [ ! -f $signcertsfname ]; then
      fname=`ls $signcerts 2> /dev/null`
      if [ "$fname" = "" ]; then
         mkdir -p $signcerts
         cp $cacertsfname $signcertsfname
      else
         mv $signcerts/* $signcertsfname
      fi
   fi
   # Copy the admin cert, which would need to be done out-of-band in the real world
   mkdir -p $admincerts
   if [ $# -gt 2 ]; then
      src=`ls $3/msp/signcerts/*`
      dst=$admincerts/Admin@${orgName}-cert.pem
   else
      src=`ls $signcerts/*`
      dst=$admincerts
   fi
   if [ ! -f $src ]; then
      fatal "admin certificate file not found at $src"
   fi
   cp $src $dst

   if [ "$INTERMEDIATE_CA" == "false" ]; then
      rm -rf $intcerts
   fi
}
# Get the CA certificates and place in MSP directory in <dir>
#    getcacerts <dir> <serverURL>
function getcacerts {
   mkdir -p $1
   export FABRIC_CA_CLIENT_HOME=$1
   $CLIENT getcacert -u $2 > $1/getcacert.out 2>&1
   if [ $? -ne 0 ]; then
      fatal "Failed to get CA certificates $1 with CA at $2; see $logFile"
   fi
   mkdir $1/msp/tlscacerts
   cp $1/msp/cacerts/* $1/msp/tlscacerts
   debug "Loaded CA certificates into $1 from CA at $2"
}

# Print a fatal error message and exit
function fatal {
   echo "FATAL: $*"
   exit 1
}

# Print a debug message
function debug {
   echo "    $*"
}

main