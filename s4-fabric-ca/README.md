Section 4
=======
# https://jira.hyperledger.org/browse/FABC-832


# Generating Artifacts - use the GO package if the binary isn't working
1. go run $GOPATH/src/github.com/hyperledger/fabric/common/tools/configtxgen/main.go -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block
2. ../bin/nicks/configtxgen -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block


# Generating Channel Artifacts
../bin/nicks/configtxgen -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block
../bin/nicks/configtxgen -profile MainChannel -outputCreateChannelTx ./channels/mainchannel.tx -channelID mainchannel
../bin/nicks/configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org1-anchors.tx -channelID mainchannel -asOrg org1
../bin/nicks/configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org2-anchors.tx -channelID mainchannel -asOrg org2


docker exec cli-peer0-org1 bash -c 'peer channel create -c mainchannel -f ./channels/mainchannel.tx -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem'


docker exec cli-peer0-org1 bash -c 'peer channel join -b mainchannel.block'
docker exec cli-peer0-org1 bash -c 'cp mainchannel.block ./channels/mainchannel.block'

docker exec cli-peer1-org1 bash -c 'peer channel join -b ./channels/mainchannel.block'
docker exec cli-peer0-org2 bash -c 'peer channel join -b ./channels/mainchannel.block'
docker exec cli-peer1-org2 bash -c 'peer channel join -b ./channels/mainchannel.block'

docker exec cli-peer0-org1 bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem -c mainchannel -f ./channels/org1-anchors.tx'
docker exec cli-peer0-org2 bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem -c mainchannel -f ./channels/org2-anchors.tx'

sleep 15

docker exec cli-peer0-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer1-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer0-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
docker exec cli-peer1-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'

docker exec cli-peer0-org1 bash -c "peer chaincode instantiate -C mainchannel -n rawresources -v 0 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"


docker exec -it cli-peer0-org1 bash
peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":1,\"name\":\"Iron Ore\",\"weight\":42000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem


docker exec cli-peer0-org1 bash -c "peer chaincode query -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"\",\"\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"

# Updating Chaincode


docker exec cli-peer0-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'
docker exec cli-peer1-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'
docker exec cli-peer0-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'
docker exec cli-peer1-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'

docker exec cli-peer0-org1 bash -c "peer chaincode upgrade -C mainchannel -n rawresources -v 2 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"


docker exec -it cli-peer0-org1 bash

peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":2,\"name\":\"Iron Ore\",\"weight\":20000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem
peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":3,\"name\":\"Iron Ore\",\"weight\":10000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem

peer chaincode query -C mainchannel -n rawresources -c '{"Args":["queryString", "{\"selector\":{ \"weight\": { \"$gt\":5000 } }}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem

https://docs.couchdb.org/en/2.2.0/api/database/find.html#find-expressions


# Creating indexes for our chaincode


docker exec cli-peer0-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'
docker exec cli-peer1-org1 bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'
docker exec cli-peer0-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'
docker exec cli-peer1-org2 bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'

docker exec cli-peer0-org1 bash -c "peer chaincode upgrade -C mainchannel -n rawresources -v 3 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"

docker exec -it cli-peer0-org1 bash

peer chaincode query -C mainchannel -n rawresources -c '{"Args":["queryString", "{\"selector\":{ \"weight\": { \"$gt\":5000 } }}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem
