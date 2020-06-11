# Create the block ( /opt/gopath/src/github.com/hyperledger/fabric/peer )
echo "Updating cli.Org1 if debug is needed"
docker exec cli.Org1 bash -c 'apt-get update'
docker exec cli.Org1 bash -c 'apt-get install iputils-ping emacs -y'

# No need for jq. Just going to do it in node.
docker exec cli.Org1 bash -c 'apt-get -y -qq update'
docker exec cli.Org1 bash -c 'apt-get install -y -qq curl'
docker exec cli.Org1 bash -c 'apt-get clean'
docker exec cli.Org1 bash -c 'curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq'
docker exec cli.Org1 bash -c 'chmod +x /usr/local/bin/jq'

echo "Creating block"
#docker exec cli.Org1 bash -c "rm testchannel.block"
docker exec cli.Org1 bash -c '\
	peer channel create \
	-c testchannel \
	-f ./channels/Test.tx \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	'

# Join Channel using block
sleep 2
echo "Joining testchannel"
docker exec cli.Org1 bash -c 'peer channel join -b testchannel.block'
docker exec cli.Org2 bash -c 'peer channel join -b testchannel.block'


sleep 2
echo "Updating channel for anchors (required for starting a network)"
docker exec cli.Org1 bash -c '\
	peer channel update \
	-c testchannel \
	-f ./channels/org1anchor.tx \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	'
docker exec cli.Org2 bash -c '\
	peer channel update \
	-c testchannel \
	-f ./channels/org2anchor.tx \
	-o orderer0.segfault.com:7050 \
	--tls \
	--cafile /etc/hyperledger/orderers/tlsca/tlsca.segfault.com-cert.pem
	'






