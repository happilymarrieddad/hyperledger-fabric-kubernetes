#!/bin/sh

echo "Querying stock for Org 1 (each orderer)"
docker exec cli.Org1 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"1\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org1 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"2\"]}' \
	-o orderer1.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org1 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"3\"]}' \
	-o orderer2.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"



echo "Querying stock for Org 2 (each orderer)"
docker exec cli.Org2 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"4\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org2 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"5\"]}' \
	-o orderer1.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
docker exec cli.Org2 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"6\"]}' \
	-o orderer2.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"

