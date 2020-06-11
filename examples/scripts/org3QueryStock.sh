#!/bin/sh



echo "Querying stock for Org 3"
docker exec cli.Org3 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"show\",\"7\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"

docker exec cli.Org3 bash -c "\
	peer chaincode invoke \
	-C testchannel \
	-n inventory \
	-c '{\"Args\":[\"showAll\"]}' \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"