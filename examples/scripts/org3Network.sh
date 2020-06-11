#!/bin/bash


echo "https://github.com/hyperledger/fabric/blob/master/examples/configtxupdate/README.md"
echo "https://hyperledger-fabric.readthedocs.io/en/release-1.1/config_update.html"
echo "https://www.ibm.com/developerworks/cloud/library/cl-add-an-organization-to-your-hyperledger-fabric-blockchain/index.html"
echo "http://hyperledger-fabric.readthedocs.io/en/release-1.1/channel_update_tutorial.html"

echo "Getting Org3's Config"
configtxgen -printOrg Org3MSP > ./channels/org3.json
sleep 1

docker exec cli.Org1 bash -c '\
	peer channel fetch config config_block.pb \
	-o orderer0.segfault.com:7050 \
	-c testchannel \
	--tls --cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	configtxlator proto_decode \
	--input config_block.pb \
	--type common.Block | jq .data.data[0].payload.data.config > config.json \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	. /opt/gopath/src/scripts/modifyConfigOrg3.sh
	'
sleep 1
docker exec cli.Org1 bash -c '\
	configtxlator proto_encode \
	--input config.json \
	--type common.Config \
	--output config.pb \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	configtxlator proto_encode \
	--input modified_config.json \
	--type common.Config \
	--output modified_config.pb \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	configtxlator compute_update \
	--channel_id testchannel \
	--original config.pb \
	--updated modified_config.pb \
	--output org3_update.pb \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	configtxlator proto_decode \
	--input org3_update.pb \
	--type common.ConfigUpdate | jq . > org3_update.json \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	. /opt/gopath/src/scripts/createOrg3Envelope.sh
	'
sleep 1
docker exec cli.Org1 bash -c '\
	configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb \
	'
sleep 1
docker exec cli.Org1 bash -c '\
	peer channel signconfigtx -f org3_update_in_envelope.pb \
	'
sleep 1

docker exec cli.Org2 bash -c '\
	peer channel update -f org3_update_in_envelope.pb -c testchannel -o orderer0.segfault.com:7050 --tls --cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem \
	'

sleep 10
docker exec cli.Org3 bash -c 'peer channel join -b testchannel.block'
sleep 3

docker exec cli.Org1 bash -c 'peer chaincode install -p inventory -n inventory -v 3'
docker exec cli.Org2 bash -c 'peer chaincode install -p inventory -n inventory -v 3'
docker exec cli.Org3 bash -c 'peer chaincode install -p inventory -n inventory -v 3'

echo "Upgrading chaincode v 3"
docker exec cli.Org1 bash -c "\
	peer chaincode upgrade -C testchannel -n inventory -v 3 -c '{\"Args\":[]}' -o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	"
sleep 3