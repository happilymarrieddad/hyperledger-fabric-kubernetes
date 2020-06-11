#!/bin/bash



echo "Creating stock for Org 3"
docker exec cli.Org3 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"7\",\"Iron\",\"100lb Iron Bin\",\"240\",\"24000\",\"Org3\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org3 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"8\",\"Iron\",\"100lb Iron Bin\",\"420\",\"42000\",\"Org3\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org3 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"createItem\",\"9\",\"Iron\",\"100lb Iron Bin\",\"420\",\"42000\",\"Org3\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"