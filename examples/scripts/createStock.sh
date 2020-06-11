#!/bin/sh

sleep 3
echo "Creating stock for Org 1"
docker exec cli.Org1 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"1\",\"Zinc\",\"25lb Zinc Bin\",\"840\",\"21000\",\"Org1\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org1 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"2\",\"Zinc\",\"25lb Zinc Bin\",\"840\",\"21000\",\"Org1\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org1 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"3\",\"Iron\",\"100lb Iron Bin\",\"420\",\"42000\",\"Org1\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"


sleep 3
echo "Creating stock for Org 2"
docker exec cli.Org2 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"4\",\"Copper\",\"50lb Copper Bin\",\"200\",\"10000\",\"Org2\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org2 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"5\",\"Copper\",\"50lb Copper Bin\",\"50\",\"2500\",\"Org2\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org2 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"6\",\"Copper\",\"50lb Copper Bin\",\"420\",\"21000\",\"Org2\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"

