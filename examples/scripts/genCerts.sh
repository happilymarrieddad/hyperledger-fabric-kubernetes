#!/bin/bash


echo "Getting certs for peers"
sleep 10
docker exec ca.client bash -c "fabric-ca-client register --id.name peer --id.type peer --id.affiliation org1.department1 --id.secret peerpw --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
sleep 1
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M orderer0.segfault.com --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M orderer0.segfault.com --enrollment.profile tls --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M orderer1.segfault.com --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M orderer1.segfault.com --enrollment.profile tls --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M orderer2.segfault.com --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M orderer2.segfault.com --enrollment.profile tls --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M peer0.Org1.com --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M peer0.Org1.com --enrollment.profile tls --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M peer0.Org2.com --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M peer0.Org2.com --enrollment.profile tls --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M peer0.Org3.com --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
docker exec ca.client bash -c "fabric-ca-client enroll -u https://peer:peerpw@ca.Segfault:7054 -M peer0.Org3.com --enrollment.profile tls --tls.certfiles /etc/hyperledger/fabric-ca-server/tls-cert.pem"
sleep 1

sudo chown $USER:$USER -R ./fabric-ca-client

make down
sleep 3
sudo rm -rf state

# Org1
# Admin certs
cp fabric-ca-client/msp/signcerts/cert.pem crypto-config/peerOrganizations/Org1.com/msp/admincerts/Admin@Org1.com-cert.pem
cp fabric-ca-client/msp/cacerts/ca-Segfault-7054.pem crypto-config/peerOrganizations/Org1.com/msp/cacerts/ca.Org1.com-cert.pem
cp fabric-ca-client/msp/signcerts/cert.pem "crypto-config/peerOrganizations/Org1.com/users/Admin@Org1.com/msp/admincerts/Admin@Org1.com-cert.pem"
cp fabric-ca-client/msp/signcerts/cert.pem "crypto-config/peerOrganizations/Org1.com/users/Admin@Org1.com/msp/signcerts/Admin@Org1.com-cert.pem"
cp fabric-ca-client/msp/cacerts/ca-Segfault-7054.pem "crypto-config/peerOrganizations/Org1.com/users/Admin@Org1.com/msp/cacerts/ca.Org1.com-cert.pem"
sudo rm crypto-config/peerOrganizations/Org1.com/users/Admin@Org1.com/msp/keystore/*
cp fabric-ca-client/msp/keystore/* "crypto-config/peerOrganizations/Org1.com/users/Admin@Org1.com/msp/keystore/"

# Org certs
cp fabric-ca-client/msp/signcerts/cert.pem crypto-config/peerOrganizations/Org1.com/peers/peer0.Org1.com/msp/admincerts/Admin@Org1.com-cert.pem
cp fabric-ca-client/peer0.Org1.com/cacerts/ca-Segfault-7054.pem crypto-config/peerOrganizations/Org1.com/peers/peer0.Org1.com/msp/cacerts/ca.Org1.com-cert.pem
sudo rm crypto-config/peerOrganizations/Org1.com/peers/peer0.Org1.com/msp/keystore/*
cp fabric-ca-client/peer0.Org1.com/keystore/* crypto-config/peerOrganizations/Org1.com/peers/peer0.Org1.com/msp/keystore/
cp fabric-ca-client/peer0.Org1.com/signcerts/cert.pem crypto-config/peerOrganizations/Org1.com/peers/peer0.Org1.com/msp/signcerts/peer0.Org1.com-cert.pem


# Org2
# Admin certs
cp fabric-ca-client/msp/signcerts/cert.pem crypto-config/peerOrganizations/Org2.com/msp/admincerts/Admin@Org2.com-cert.pem
cp fabric-ca-client/msp/cacerts/ca-Segfault-7054.pem crypto-config/peerOrganizations/Org2.com/msp/cacerts/ca.Org2.com-cert.pem
cp fabric-ca-client/msp/signcerts/cert.pem "crypto-config/peerOrganizations/Org2.com/users/Admin@Org2.com/msp/admincerts/Admin@Org2.com-cert.pem"
cp fabric-ca-client/msp/signcerts/cert.pem "crypto-config/peerOrganizations/Org2.com/users/Admin@Org2.com/msp/signcerts/Admin@Org2.com-cert.pem"
cp fabric-ca-client/msp/cacerts/ca-Segfault-7054.pem "crypto-config/peerOrganizations/Org2.com/users/Admin@Org2.com/msp/cacerts/ca.Org2.com-cert.pem"
sudo rm crypto-config/peerOrganizations/Org2.com/users/Admin@Org2.com/msp/keystore/*
cp fabric-ca-client/msp/keystore/* "crypto-config/peerOrganizations/Org2.com/users/Admin@Org2.com/msp/keystore/"

# Org certs
cp fabric-ca-client/msp/signcerts/cert.pem crypto-config/peerOrganizations/Org2.com/peers/peer0.Org2.com/msp/admincerts/Admin@Org2.com-cert.pem
cp fabric-ca-client/peer0.Org2.com/cacerts/ca-Segfault-7054.pem crypto-config/peerOrganizations/Org2.com/peers/peer0.Org2.com/msp/cacerts/ca.Org2.com-cert.pem
sudo rm crypto-config/peerOrganizations/Org2.com/peers/peer0.Org2.com/msp/keystore/*
cp fabric-ca-client/peer0.Org2.com/keystore/* crypto-config/peerOrganizations/Org2.com/peers/peer0.Org2.com/msp/keystore/
cp fabric-ca-client/peer0.Org2.com/signcerts/cert.pem crypto-config/peerOrganizations/Org2.com/peers/peer0.Org2.com/msp/signcerts/peer0.Org2.com-cert.pem


# Org3
# Admin certs
cp fabric-ca-client/msp/signcerts/cert.pem crypto-config/peerOrganizations/Org3.com/msp/admincerts/Admin@Org3.com-cert.pem
cp fabric-ca-client/msp/cacerts/ca-Segfault-7054.pem crypto-config/peerOrganizations/Org3.com/msp/cacerts/ca.Org3.com-cert.pem
cp fabric-ca-client/msp/signcerts/cert.pem "crypto-config/peerOrganizations/Org3.com/users/Admin@Org3.com/msp/admincerts/Admin@Org3.com-cert.pem"
cp fabric-ca-client/msp/signcerts/cert.pem "crypto-config/peerOrganizations/Org3.com/users/Admin@Org3.com/msp/signcerts/Admin@Org3.com-cert.pem"
cp fabric-ca-client/msp/cacerts/ca-Segfault-7054.pem "crypto-config/peerOrganizations/Org3.com/users/Admin@Org3.com/msp/cacerts/ca.Org3.com-cert.pem"
sudo rm crypto-config/peerOrganizations/Org3.com/users/Admin@Org3.com/msp/keystore/*
cp fabric-ca-client/msp/keystore/* "crypto-config/peerOrganizations/Org3.com/users/Admin@Org3.com/msp/keystore/"

# Org certs
cp fabric-ca-client/msp/signcerts/cert.pem crypto-config/peerOrganizations/Org3.com/peers/peer0.Org3.com/msp/admincerts/Admin@Org3.com-cert.pem
cp fabric-ca-client/peer0.Org3.com/cacerts/ca-Segfault-7054.pem crypto-config/peerOrganizations/Org3.com/peers/peer0.Org3.com/msp/cacerts/ca.Org3.com-cert.pem
sudo rm crypto-config/peerOrganizations/Org3.com/peers/peer0.Org3.com/msp/keystore/*
cp fabric-ca-client/peer0.Org3.com/keystore/* crypto-config/peerOrganizations/Org3.com/peers/peer0.Org3.com/msp/keystore/
cp fabric-ca-client/peer0.Org3.com/signcerts/cert.pem crypto-config/peerOrganizations/Org3.com/peers/peer0.Org3.com/msp/signcerts/peer0.Org3.com-cert.pem



rm -rf orderer
make setup
sleep 2
make start
sleep 10
make network
sleep 3
make chaincode

sleep 3
