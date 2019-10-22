#!/bin/bash

# Allows for the file to be run anywhere
export SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ENROLLURL=ca-intermediate:7054
HOME_DIR=/etc/hyperledger/fabric-ca-server/fabric-ca-files
DOMAIN=default.svc.cluster.local

mkdir -p $HOME_DIR
rm -rf $HOME_DIR/*

export FABRIC_CA_CLIENT_HOME=$HOME_DIR/caAdmin
bash $SCRIPTDIR/helpers/ca-client-enroll.sh admin adminpw $ENROLLURL

# Register Orderers
ORDERER_ADMIN_ID=Admin@$DOMAIN
ORDERER_ADMIN_PW=Admin.${DOMAIN}pw

ORDERER_ID=orderer.$DOMAIN
ORDERER_PW=orderer.${DOMAIN}pw

bash $SCRIPTDIR/helpers/register-entity.sh $ORDERER_ID $ORDERER_PW

fabric-ca-client register --id.secret $ORDERER_ADMIN_PW --id.name $ORDERER_ADMIN_ID --id.type client --id.affiliation org1 --id.attrs admin=true:ecert
sleep 1

bash $SCRIPTDIR/helpers/get-ca-cert.sh $ENROLLURL "$HOME_DIR/$DOMAIN/msp"
bash $SCRIPTDIR/helpers/finish-msp-setup.sh "$HOME_DIR/$DOMAIN/msp"

export FABRIC_CA_CLIENT_HOME=$HOME_DIR/$DOMAIN/admin
bash $SCRIPTDIR/helpers/enroll-entity.sh $ORDERER_ADMIN_ID $ORDERER_ADMIN_PW $ENROLLURL
bash $SCRIPTDIR/helpers/copy-admin-cert.sh "$HOME_DIR/$DOMAIN/admin/msp" "$HOME_DIR/$DOMAIN/msp"
bash $SCRIPTDIR/helpers/copy-admin-cert.sh "$HOME_DIR/$DOMAIN/admin/msp" "$HOME_DIR/$DOMAIN/admin/msp"

ORDERER_DNS_LIST="orderer0-service,orderer1-service,orderer2-service"

for ((i = 0; i < 3; i++)); do
    NAME=orderer$i
    export FABRIC_CA_CLIENT_HOME=$HOME_DIR/$DOMAIN/$NAME
    bash $SCRIPTDIR/helpers/enroll-tls.sh $ORDERER_ID $ORDERER_PW $ENROLLURL "$HOME_DIR/$DOMAIN/$NAME/tls" $ORDERER_DNS_LIST

    bash $SCRIPTDIR/helpers/copy-tls.sh "$HOME_DIR/$DOMAIN/$NAME/tls"
    bash $SCRIPTDIR/helpers/copy-root-ca.sh "$HOME_DIR/$DOMAIN/$NAME/tls" /etc/hyperledger/fabric-ca-server

    bash $SCRIPTDIR/helpers/enroll-entity-msp.sh $ORDERER_ADMIN_ID $ORDERER_ADMIN_PW $ENROLLURL "$HOME_DIR/$DOMAIN/$NAME/msp"

    bash $SCRIPTDIR/helpers/finish-msp-setup.sh "$HOME_DIR/$DOMAIN/$NAME/msp"
    bash $SCRIPTDIR/helpers/copy-admin-cert.sh "$HOME_DIR/$DOMAIN/admin/msp" "$HOME_DIR/$DOMAIN/$NAME/msp"
done

for ((j = 1; j < 3; j++)); do

    export FABRIC_CA_CLIENT_HOME=$HOME_DIR/caAdmin
    ORG=org$j
    PEER_DNS_LIST="peer0-$ORG-service,peer1-$ORG-service"

    bash $SCRIPTDIR/helpers/register-entity.sh "peer0.$ORG.$DOMAIN" "peer0.$ORG.${DOMAIN}pw" peer $ORG
    bash $SCRIPTDIR/helpers/register-entity.sh "peer1.$ORG.$DOMAIN" "peer1.$ORG.${DOMAIN}pw" peer $ORG

    PEER_ADMIN_ID=Admin@$ORG.${DOMAIN}
    PEER_ADMIN_PW=Admin@$ORG.${DOMAIN}pw
    PEER_ID=user@$ORG.${DOMAIN}
    PEER_PW=user@$ORG.${DOMAIN}pw

    bash $SCRIPTDIR/helpers/register-entity.sh $PEER_ADMIN_ID $PEER_ADMIN_PW client $ORG
    bash $SCRIPTDIR/helpers/register-entity.sh $PEER_ID $PEER_PW client $ORG

    fabric-ca-client getcacert -u http://$ENROLLURL -M $HOME_DIR/$ORG.$DOMAIN/msp
    sleep 1

    bash $SCRIPTDIR/helpers/finish-msp-setup.sh "$HOME_DIR/$ORG.$DOMAIN/msp"

    export FABRIC_CA_CLIENT_HOME=$HOME_DIR/$ORG.$DOMAIN/admin
    bash $SCRIPTDIR/helpers/enroll-entity.sh $PEER_ADMIN_ID $PEER_ADMIN_PW $ENROLLURL $ORG

    bash $SCRIPTDIR/helpers/copy-admin-cert.sh "$HOME_DIR/$ORG.$DOMAIN/admin/msp" "$HOME_DIR/$ORG.$DOMAIN/admin/msp"
    bash $SCRIPTDIR/helpers/copy-admin-cert.sh "$HOME_DIR/$ORG.$DOMAIN/admin/msp" "$HOME_DIR/$ORG.$DOMAIN/msp"

    export FABRIC_CA_CLIENT_HOME=$HOME_DIR/$ORG.$DOMAIN/user
    bash $SCRIPTDIR/helpers/enroll-entity.sh $PEER_ID $PEER_PW $ENROLLURL $ORG

    for ((i = 0; i < 2; i++)); do

        peer=peer$i

        export FABRIC_CA_CLIENT_HOME=$HOME_DIR/$ORG.$DOMAIN/$peer
        LP_PEER_ID=$peer.$ORG.$DOMAIN
        LP_PEER_PW=$peer.$ORG.${DOMAIN}pw

        bash $SCRIPTDIR/helpers/enroll-tls.sh $LP_PEER_ID $LP_PEER_PW $ENROLLURL "$HOME_DIR/$ORG.$DOMAIN/$peer/tls" $PEER_DNS_LIST $ORG
        bash $SCRIPTDIR/helpers/copy-tls.sh "$HOME_DIR/$ORG.$DOMAIN/$peer/tls"
        bash $SCRIPTDIR/helpers/copy-root-ca.sh "$HOME_DIR/$ORG.$DOMAIN/$peer/tls"

        bash $SCRIPTDIR/helpers/enroll-entity-msp.sh $LP_PEER_ID $LP_PEER_PW $ENROLLURL "$HOME_DIR/$ORG.$DOMAIN/$peer/msp" $ORG
        bash $SCRIPTDIR/helpers/finish-msp-setup.sh "$HOME_DIR/$ORG.$DOMAIN/$peer/msp"
        bash $SCRIPTDIR/helpers/copy-admin-cert.sh "$HOME_DIR/$ORG.$DOMAIN/admin/msp" "$HOME_DIR/$ORG.$DOMAIN/$peer/msp"

    done

done

## Build the final paths
CONFIGPATH=/etc/hyperledger/fabric-ca-server/crypto-config
ORG=org1

mkdir -p $CONFIGPATH
rm -rf $CONFIGPATH/*

mkdir -p $CONFIGPATH/ordererOrganizations/$DOMAIN/users/Admin@$DOMAIN
mkdir -p $CONFIGPATH/ordererOrganizations/$DOMAIN/msp

cp -rf $HOME_DIR/$DOMAIN/admin/* $CONFIGPATH/ordererOrganizations/$DOMAIN/users/Admin@$DOMAIN
cp -rf $HOME_DIR/$DOMAIN/msp/* $CONFIGPATH/ordererOrganizations/$DOMAIN/msp

for ((i = 0; i < 3; i++)); do
    NAME=orderer$i

    mkdir -p $CONFIGPATH/ordererOrganizations/$DOMAIN/orderers/$NAME.$DOMAIN
    cp -rf $HOME_DIR/$DOMAIN/$NAME/* $CONFIGPATH/ordererOrganizations/$DOMAIN/orderers/$NAME.$DOMAIN
    cp $CONFIGPATH/ordererOrganizations/$DOMAIN/orderers/$NAME.$DOMAIN/msp/tlsintermediatecerts/ca-intermediate-7054.pem $CONFIGPATH/ordererOrganizations/$DOMAIN/orderers/$NAME.$DOMAIN/tls/ca.crt

done

for ((j = 1; j < 3; j++)); do

    ORG=org$j

    mkdir -p $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN
    mkdir -p $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/msp

    cp -rf $HOME_DIR/$ORG.$DOMAIN/admin/* $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/users/Admin@$ORG.$DOMAIN
    cp -rf $HOME_DIR/$ORG.$DOMAIN/msp/* $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/msp

    for ((i = 0; i < 2; i++)); do

        NAME=peer$i

        mkdir -p $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/peers/$NAME-$ORG.$DOMAIN

        cp -rf $HOME_DIR/$ORG.$DOMAIN/$NAME/* $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/peers/$NAME-$ORG.$DOMAIN
        cp $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/peers/$NAME-$ORG.$DOMAIN/msp/tlsintermediatecerts/ca-intermediate-7054.pem $CONFIGPATH/peerOrganizations/$ORG.$DOMAIN/peers/$NAME-$ORG.$DOMAIN/tls/ca.crt

    done

done

echo ""
echo "Finished!!!!!!!!"
echo ""
