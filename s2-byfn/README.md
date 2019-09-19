Section 2 - BYFN from scratch

## Commands - crypto-config
cryptogen generate --config=./crypto-config.yaml

## Commands - channel artifacts
configtxgen -profile TwoOrgsOrdererGenesis -channelID syschannel -outputBlock channel-artifacts/genesis.block
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP








## Commands to start a network
docker exec cli-peer0.org1 bash -c 'peer channel create -c mychannel -f ./channels/channel.tx -o orderer.example.com:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/tlsca.example.com-cert.pem'



docker exec cli-peer0.org1 bash -c 'peer channel join -b mychannel.block'
docker exec cli-peer1.org1 bash -c 'peer channel join -b mychannel.block'
docker exec cli-peer0.org2 bash -c 'peer channel join -b mychannel.block'
docker exec cli-peer1.org2 bash -c 'peer channel join -b mychannel.block'


docker exec cli-peer0.org1 bash -c 'peer channel update -o orderer.example.com:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/tlsca.example.com-cert.pem -c mychannel -f ./channels/Org1MSPanchors.tx'
docker exec cli-peer0.org2 bash -c 'peer channel update -o orderer.example.com:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/tlsca.example.com-cert.pem -c mychannel -f ./channels/Org2MSPanchors.tx'























## In order to grab an exising block if you lose it then use this command
peer channel fetch newest \
    -c mychannel \
    -o orderer.example.com \
    --tls  \
    --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

