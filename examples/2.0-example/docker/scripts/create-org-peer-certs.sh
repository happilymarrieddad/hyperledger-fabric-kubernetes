#!/bin/bash

# ensure directory exists
CLIENT=fabric-ca-client
CDIR=/etc/hyperledger/fabric-ca/crypto-config
mkdir -p $CDIR

orgName=${1-org1}
CA_SCHEME=${2-https}
CA_USERNAME=${3-admin}
CA_PASSWORD=${4-adminpw}
CA_URL=${5}
CA_CERT_PATH=$6
CA_FULL_URL=${CA_SCHEME}://${CA_USERNAME}:${CA_PASSWORD}@${CA_URL}
NUM_NODES=${7-3}

function main {
    
    orgDir=${CDIR}/peerOrganizations/${orgName}
    # Remove folder if is already exists
    rm -rf $orgDir
    usersDir=$orgDir/users
    adminHome=$orgDir/users/rootAdmin
    mkdir -p $adminHome

    # Enroll org admin
    export FABRIC_CA_HOME=$adminHome
    $CLIENT enroll -u ${CA_FULL_URL} --tls.certfiles ${CA_CERT_PATH}

    # Register and enroll admin
    adminUserHome=$usersDir/Admin@${orgName}
    export FABRIC_CA_CLIENT_HOME=${adminHome}
    $CLIENT register --id.name Admin --id.secret secret --id.type admin --id.affiliation org1 -u ${CA_FULL_URL} --tls.certfiles ${CA_CERT_PATH}
    export FABRIC_CA_CLIENT_HOME=${adminUserHome}
    $CLIENT enroll -u ${CA_SCHEME}://Admin:secret@${CA_URL} --tls.certfiles ${CA_CERT_PATH}

    # Register and enroll user1
    user1UserHome=$usersDir/User1@${orgName}
    export FABRIC_CA_CLIENT_HOME=${adminHome}
    $CLIENT register --id.name User1 --id.secret secret --id.type admin --id.affiliation org1 -u ${CA_FULL_URL} --tls.certfiles ${CA_CERT_PATH}
    export FABRIC_CA_CLIENT_HOME=${user1UserHome}
    $CLIENT enroll -u ${CA_SCHEME}://User1:secret@${CA_URL} --tls.certfiles ${CA_CERT_PATH}

    nodeCount=0
    while [ $nodeCount -lt $NUM_NODES ]; do
        nodeDir=$orgDir/peers/peer${nodeCount}-${orgName}
        mkdir -p $nodeDir

        # Get TLS crypto for this node
        host=peer${nodeCount}-${orgName}
        tlsDir=$nodeDir/tls
        srcMSP=$tlsDir/msp
        dstMSP=$nodeDir/msp
        export FABRIC_CA_CLIENT_HOME=$tlsDir
        mkdir -p $tlsDir
        $CLIENT enroll -u ${CA_FULL_URL} --tls.certfiles ${CA_CERT_PATH} --csr.hosts $host --enrollment.profile tls
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
        rm -rf $srcMSP $nodeDir/enroll.log $nodeDir/fabric-ca-client-config.yaml

        # Register and enroll peer
        export FABRIC_CA_CLIENT_HOME=${adminHome}
        $CLIENT register --id.name peer${nodeCount}-${orgName} --id.secret secret --id.type admin --id.affiliation org1 -u ${CA_FULL_URL} --tls.certfiles ${CA_CERT_PATH}
        export FABRIC_CA_CLIENT_HOME=${nodeDir}
        $CLIENT enroll -u ${CA_SCHEME}://peer${nodeCount}-${orgName}:secret@${CA_URL} --tls.certfiles ${CA_CERT_PATH}

        # Normalize MSP
        normalizeMSP $nodeDir $orgName $adminUserHome

        nodeCount=$(expr $nodeCount + 1)
    done

    # Get CA Certs from CA
    export FABRIC_CA_CLIENT_HOME=$orgDir
    $CLIENT getcacert -u ${CA_FULL_URL} --tls.certfiles ${CA_CERT_PATH}
    mkdir -p $orgDir/msp/tlscacerts
    cp $orgDir/msp/cacerts/* $orgDir/msp/tlscacerts

    normalizeMSP $orgDir $orgName $adminUserHome
    normalizeMSP $adminHome $orgName
    normalizeMSP $adminUserHome $orgName
    normalizeMSP $user1UserHome $orgName
}

#   normalizeMSP <home> <orgName> <adminHome>
function normalizeMSP {
   userName=$(basename $1)
   mspDir=$1/msp
   orgName=$2
   admincerts=$mspDir/admincerts
   cacerts=$mspDir/cacerts
   intcerts=$mspDir/intermediatecerts
   signcerts=$mspDir/signcerts
   keystorecerts=$mspDir/keystore
   mv $keystorecerts/* $keystorecerts/pvt-cert.pem
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
   # Copy the admin cert
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
}

main
