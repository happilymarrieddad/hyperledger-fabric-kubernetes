#!/bin/sh

# https://hyperledger-fabric.readthedocs.io/en/release-1.1/commands/peerchaincode.html
echo "Installing chaincode"
docker exec cli.Org1 bash -c 'peer chaincode install -p inventory -n inventory -v 0'
docker exec cli.Org2 bash -c 'peer chaincode install -p inventory -n inventory -v 0'
docker exec cli.Org3 bash -c 'peer chaincode install -p inventory -n inventory -v 0'

sleep 2
echo "Instantiating chaincode"
docker exec cli.Org1 bash -c "\
	peer chaincode instantiate -C testchannel -n inventory -v 0 -c '{\"Args\":[]}' -o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
