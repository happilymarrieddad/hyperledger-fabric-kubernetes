Section 2 - BYFN from scratch

## Commands - crypto-config
cryptogen generate --config=./crypto-config.yaml

## Commands - channel artifacts
configtxgen -profile TwoOrgsOrdererGenesis -channelID syschannel -outputBlock channel-artifacts/genesis.block
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP




## Commands for the CLI

peer channel create \
    -o orderer.example.com:7050 \
    -c mychannel \
    -f ./channel-artifacts/channel.tx \
    --tls \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem


peer channel join -b mychannel.block


peer channel update \
    -o orderer.example.com:7050 \
    --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem \
    -f channel-artifacts/Org1MSPanchors.tx \
    -c mychannel

peer channel update \
    -o orderer.example.com:7050 \
    --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem \
    -f channel-artifacts/Org2MSPanchors.tx \
    -c mychannel





## Installing Chaincode

peer chaincode install -n mycc -v 0 -p github.com/chaincode/chaincode_example02/go

peer chaincode instantiate -o orderer.example.com:7050 \
    --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem \
    -C mychannel -n mycc -v 0 -c '{"Args":["init","a","100","b","100"]}'



## In order to grab an exising block if you lose it then use this command
peer channel fetch newest \
    -c mychannel \
    -o orderer.example.com \
    --tls  \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem




    -o orderer.example.com --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem