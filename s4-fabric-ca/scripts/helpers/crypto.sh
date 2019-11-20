#!/bin/bash +x
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
export FABRIC_CFG_PATH=./

FCAHOME=/src/github.com/hyperledger/fabric-ca
CLIENT=fabric-ca-client
CDIR="./crypto-config"

# <type>:<orgname>:<network>:<number>
ORG="$1:$2:$3:$4"

function main {
    echo "#################################################################"
    echo "#######    Generating crypto material using Fabric CA  ##########"
    echo "#################################################################"

    mydir=`pwd`
    cd $mydir
    # if [ -d $CDIR ]; then
    #     echo "Cleaning up ..."
    #     rm -rf $CDIR
    # fi

    setupOrg $ORG
}

function setupOrg {
    IFSBU=$IFS
    IFS=: args=($1)
    # echo ${#args[@]}
    # if [ ${#args[@]} -ne 14 ]; then
    #     fatal "setupOrg: bad org spec: $1"
    # fi
    network=${args[2]}
    rootCAScheme=http
    roothost=ca-root
    rootport=7054
    rootCAURL=${roothost}:${rootport}
    rootCAUser=admin
    rootCAPass=adminpw
    rootCAFullURL=${rootCAScheme}://$rootCAUser:$rootCAPass@$rootCAURL
    type=${args[0]}
    orgName=${args[1]}
    numNodes=${args[3]}
    IFS=$IFSBU

    if [ "$type" == "orderer" ]; then
        orgDir=${CDIR}/${type}Organizations/${network}
    fi
    if [ "$type" == "peer" ]; then
        orgDir=${CDIR}/${type}Organizations/${orgName}
    fi

    # Enroll an admin user with the root CA
    usersDir=$orgDir/users
    adminHome=$usersDir/rootAdmin
    enroll $adminHome $rootCAFullURL $orgName

    # Enroll an admin user with the intermediate CA
   #  adminHome=$usersDir/intermediateAdmin
   #  enroll $adminHome $intermediateCAFullURL $orgName

    # Register and enroll admin with the root CA
    adminUserHome=$usersDir/Admin@${orgName}
    registerAndEnroll $adminHome $adminUserHome $orgName $rootCAScheme $rootCAURL ${orgName}NodeAdmin
    
    # Register and enroll user1 with the root CA
    user1UserHome=$usersDir/User1@${orgName}
    registerAndEnroll $adminHome $user1UserHome $orgName $rootCAScheme $rootCAURL
   nodeCount=0
   while [ $nodeCount -lt $numNodes ]; do

        if [ "$type" == "orderer" ]; then
            nodeDir=$orgDir/${type}s/${type}${nodeCount}.${network}
            csrhost="${type}${nodeCount}"
        fi
        if [ "$type" == "peer" ]; then
            nodeDir=$orgDir/${type}s/${orgName}-${type}${nodeCount}.${network}
            csrhost="${type}${nodeCount}-${orgName}"
        fi

        mkdir -p $nodeDir
        # Get TLS crypto for this node
        tlsEnroll $nodeDir $rootCAFullURL $orgName $csrhost
        # Register and enroll this node's identity
        registerAndEnroll $adminHome $nodeDir $orgName $rootCAScheme $rootCAURL
        normalizeMSP $nodeDir $orgName $adminUserHome
        nodeCount=$(expr $nodeCount + 1)
    done
   # Get CA certs from root CA
   getcacerts $orgDir $rootCAFullURL
   # Rename MSP files to names expected by end-to-end
   normalizeMSP $orgDir $orgName $adminUserHome
   normalizeMSP $adminHome $orgName
   normalizeMSP $adminUserHome $orgName
   normalizeMSP $user1UserHome $orgName
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

# Enroll to get TLS crypto material
#    tlsEnroll <homeDir> <serverPort> <orgName> <csrhost>
function tlsEnroll {
   homeDir=$1
   url=$2
   orgName=$3
   csrhost=$4
   host=$(basename $homeDir),$(basename $homeDir | cut -d'.' -f1)
   tlsDir=$homeDir/tls
   srcMSP=$tlsDir/msp
   dstMSP=$homeDir/msp

   enroll $tlsDir $url $orgName \
      --csr.hosts $csrhost \
      --csr.hosts $host-service \
      --csr.hosts $csrhost-service \
      --enrollment.profile tls

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

# Register and enroll a new user
# registerAndEnroll <registrarHomeDir> <registreeHomeDir> <orgname> <rootcascheme> <rooturl> <username> <password>
function registerAndEnroll {
    userName=$6
    if [ "$userName" = "" ]; then
        userName=$(basename $2)
    fi
    password=${7-secret}

    register $userName $password $1
    enroll $2 ${4}://${userName}:${password}@${5} $3
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