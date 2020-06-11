#!/bin/sh

# https://hyperledger-fabric.readthedocs.io/en/release-1.1/commands/peerchaincode.html
docker exec cli.Org1 bash -c 'peer chaincode install -p inventory -n inventory -v 1'
docker exec cli.Org2 bash -c 'peer chaincode install -p inventory -n inventory -v 1'
docker exec cli.Org3 bash -c 'peer chaincode install -p inventory -n inventory -v 1'

echo "Upgrading chaincode v 1"
docker exec cli.Org1 bash -c "\
	peer chaincode upgrade -C testchannel -n inventory -v 1 -c '{\"Args\":[]}' -o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"

sleep 3
docker exec cli.Org1 bash -c 'peer chaincode install -p inventory -n inventory -v 2'
docker exec cli.Org2 bash -c 'peer chaincode install -p inventory -n inventory -v 2'
docker exec cli.Org3 bash -c 'peer chaincode install -p inventory -n inventory -v 2'

echo "Upgrading chaincode v 2"
docker exec cli.Org1 bash -c "\
	peer chaincode upgrade -C testchannel -n inventory -v 2 -c '{\"Args\":[]}' -o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"