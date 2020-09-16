#!/bin/bash

docker exec -it cli-peer0-org1 bash -c 'peer channel create -c main -f ./channels/main.tx -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'

docker exec -it cli-peer0-org1 bash -c 'cp main.block ./channels/'
docker exec -it cli-peer0-org1 bash -c 'peer channel join -b channels/main.block'
docker exec -it cli-peer1-org1 bash -c 'peer channel join -b channels/main.block'
docker exec -it cli-peer0-org2 bash -c 'peer channel join -b channels/main.block'
docker exec -it cli-peer1-org2 bash -c 'peer channel join -b channels/main.block'

docker exec -it cli-peer0-org1 bash -c 'peer channel update -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem -c main -f channels/org1anchor.tx'
docker exec -it cli-peer0-org2 bash -c 'peer channel update -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem -c main -f channels/org2anchor.tx'

sleep 15


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_1'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_1'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_1'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_1'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resource_types.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resource_types.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resource_types.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resource_types.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 1.0 --sequence 1 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 1.0 --sequence 1 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 1.0 --sequence 1'


docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resource_types -c '\''{"Args":["Create","1","Raw Resource"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
sleep 5
docker exec -it cli-peer0-org1 bash -c 'peer chaincode query -C main -n resource_types -c '\''{"Args":["Index"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'





docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_1'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_1'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_1'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_1'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz'

docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 1.0 --sequence 1 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 1.0 --sequence 1 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'

docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 1.0 --sequence 1'


docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resources -c '\''{"Args":["Create","1","Iron Ore","1"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resources -c '\''{"Args":["Create","2","Copper Ore","1"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
sleep 5
docker exec -it cli-peer0-org1 bash -c 'peer chaincode query -C main -n resources -c '\''{"Args":["Index"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
docker exec -it cli-peer1-org1 bash -c 'peer chaincode query -C main -n resources -c '\''{"Args":["Index"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
docker exec -it cli-peer0-org2 bash -c 'peer chaincode query -C main -n resources -c '\''{"Args":["Index"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
docker exec -it cli-peer1-org2 bash -c 'peer chaincode query -C main -n resources -c '\''{"Args":["Index"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'