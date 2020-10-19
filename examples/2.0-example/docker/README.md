Symbiosis
===========================
## Notes
MAKE SURE YOU VENDOR THE GO FILES (go mod vendor - inside the chaincode folders)

## Fabric-CA
1. docker-compose -f docker-compose-ca.yaml up
2. make gen_genesis_block
3. make gen_channel_artifacts

## SSL Decoder
https://www.sslshopper.com/certificate-decoder.html

## Upgrade to 2.0
https://hyperledger-fabric.readthedocs.io/en/release-2.0/upgrade_to_newest_version.html

## Commands
```sh
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

sleep 15
## How to upgrade chaincode - examples

docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_2'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_2'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_2'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_2'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 2.0 --sequence 2 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 2.0 --sequence 2 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 2.0 --sequence 2'







RESOURCE TYPES


sleep 15


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_2'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_2'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_2'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_2'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resource_types.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resource_types.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resource_types.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resource_types.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 2.0 --sequence 2 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 2.0 --sequence 2 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 2.0 --sequence 2'



RESOURCES


sleep 15


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_3'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_3'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_3'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_3'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 3.0 --sequence 3 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 3.0 --sequence 3 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 3.0 --sequence 3'


sleep 15


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_4'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_4'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_4'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_4'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 4.0 --sequence 4 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 4.0 --sequence 4 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 4.0 --sequence 4'


sleep 15


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_5'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_5'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_5'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_5'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 5.0 --sequence 5 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 5.0 --sequence 5 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 5.0 --sequence 5'


sleep 15


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_6'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_6'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_6'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resources.tar.gz --path /opt/gopath/src/resources --lang golang --label resources_6'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resources.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resources.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 6.0 --sequence 6 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 6.0 --sequence 6 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resources --version 6.0 --sequence 6'













docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_3'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_3'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_3'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode package resource_types.tar.gz --path /opt/gopath/src/resource_types --lang golang --label resource_types_3'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode install resource_types.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org1 bash -c 'peer lifecycle chaincode install resource_types.tar.gz'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode install resource_types.tar.gz &> pkg.txt'
docker exec -it cli-peer1-org2 bash -c 'peer lifecycle chaincode install resource_types.tar.gz'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 3.0 --sequence 3 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'
docker exec -it cli-peer0-org2 bash -c 'peer lifecycle chaincode approveformyorg -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 3.0 --sequence 3 --package-id $(tail -n 1 pkg.txt | awk '\''NF>1{print $NF}'\'')'


docker exec -it cli-peer0-org1 bash -c 'peer lifecycle chaincode commit -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem --channelID main --name resource_types --version 3.0 --sequence 3'




docker exec -it cli-peer1-org2 bash -c 'peer chaincode query -C main -n resources -c '\''{"Args":["Index"]}'\'' -o orderer1:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'


```




## Hyperledger Explorer

https://github.com/hyperledger/blockchain-explorer

```bash
wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/master/examples/net1/config.json
wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/master/examples/net1/connection-profile/first-network.json -P connection-profile
wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/master/docker-compose.yaml
```

```bash
cp -r ../crypto-config ./organizations
```

```bash
NOTE:
I would suggest that you create the network without the explorer first and then start it again after.
```

## Tests to ensure that an invalid resource_type_id can not be used in the chaincode.

```bash
docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resources -c '\''{"Args":["Create","3","Iron Ore 2","1"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resources -c '\''{"Args":["Create","4","Copper Ore 3","2"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
```

```bash
docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resources -c '\''{"Args":["Create","5","Iron Ore 4","1"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
docker exec -it cli-peer0-org1 bash -c 'peer chaincode invoke -C main -n resources -c '\''{"Args":["Create","6","Copper Ore 5","2"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
```






```bash
docker exec -it cli-peer0-org1 bash -c 'peer chaincode query -C main -n resources -c '\''{"Args":["Transactions"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'

docker exec -it cli-peer0-org1 bash -c 'peer chaincode query -C main -n resource_types -c '\''{"Args":["Update", "1", "Raw Resource 2"]}'\'' -o orderer0:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/orderers-ca-7054.pem'
```



