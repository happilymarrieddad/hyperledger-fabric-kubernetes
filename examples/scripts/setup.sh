export FABRIC_CFG_PATH=./

mkdir -p ./orderer
mkdir -p ./channels
mkdir -p /home/$USER/.hfc-key-store

echo
echo "Creating the genesis.block. This block is used as a \"settings\" block for the whole network. Take a look at configs/configtx.yaml for more information."
configtxgen -profile SEGFAULTOrdererGenesis -outputBlock ./orderer/genesis.block

echo
echo "Creating the testchannel channel configuration transation."
configtxgen -profile TestChannel -outputCreateChannelTx ./channels/Test.tx -channelID testchannel

echo
echo "Creating Org1 anchor peer update. Sets the anchor peer for Org1 based on the profile."
configtxgen -profile TestChannel -outputAnchorPeersUpdate ./channels/org1anchor.tx -channelID testchannel -asOrg Org1MSP

echo
echo "Creating Org2 anchor peer update. Read above..."
configtxgen -profile TestChannel -outputAnchorPeersUpdate ./channels/org2anchor.tx -channelID testchannel -asOrg Org2MSP
echo

