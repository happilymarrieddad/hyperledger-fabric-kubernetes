Section 4
=======


# Generating Artifacts - use the GO package if the binary isn't working
1. go run $GOPATH/src/github.com/hyperledger/fabric/common/tools/configtxgen/main.go -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block
2. configtxgen -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block


# Generating Channel Artifacts
configtxgen -profile MainChannel -outputCreateChannelTx ./channels/mainchannel.tx -channelID mainchannel
configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org1-anchors.tx -channelID mainchannel -asOrg org1
configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org2-anchors.tx -channelID mainchannel -asOrg org2


docker exec cli-peer0-org1 bash -c 'peer channel create -c mainchannel -f ./channels/mainchannel.tx -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem'


docker exec cli-peer0-org1 bash -c 'peer channel join -b mainchannel.block'
docker exec cli-peer1-org1 bash -c 'peer channel join -b ./channels/mainchannel.block'
docker exec cli-peer0-org2 bash -c 'peer channel join -b ./channels/mainchannel.block'
docker exec cli-peer1-org2 bash -c 'peer channel join -b ./channels/mainchannel.block'

docker exec cli-peer0-org1 bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem -c mainchannel -f ./channels/org1-anchors.tx'
docker exec cli-peer0-org2 bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem -c mainchannel -f ./channels/org2-anchors.tx'

sleep 15

docker exec cli-peer0-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer1-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer0-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer1-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'

docker exec cli-peer0-org1 bash -c "peer chaincode instantiate -C mainchannel -n rawresources -v 0 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem"


docker exec -it cli-peer0-org1 bash
peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":1,\"name\":\"Iron Ore\",\"weight\":42000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem


docker exec cli-peer0-org1 bash -c "peer chaincode invoke -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"0\",\"1000000\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlsintermediatecerts/ca-intermediate-7054.pem"