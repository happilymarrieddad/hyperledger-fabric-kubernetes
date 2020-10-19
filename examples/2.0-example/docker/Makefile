
set_crypto_perms:
	sudo chmod 777 -R crypto-config/
	sudo chown $$USER:$$USER -R crypto-config

gen_genesis_block: set_crypto_perms
	rm -rf orderer
	mkdir -p orderer
	configtxgen -profile OrdererGenesis -outputBlock ./orderer/genesis.block -channelID system-channel

gen_channel_artifacts: set_crypto_perms
	rm -rf channels
	mkdir -p channels
	configtxgen -profile MainChannel -outputCreateChannelTx ./channels/main.tx -channelID main
	configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org1anchor.tx -channelID main -asOrg org1
	configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org2anchor.tx -channelID main -asOrg org2

gen_osx_artifacts:
	mkdir -p orderer
	mkdir -p channels
	~/bin/configtxgen -profile OrdererGenesis -outputBlock ./orderer/genesis.block -channelID system-channel
	~/bin/configtxgen -profile MainChannel -outputCreateChannelTx ./channels/main.tx -channelID main
	~/bin/configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org1anchor.tx -channelID main -asOrg org1
	~/bin/configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org2anchor.tx -channelID main -asOrg org2

clean:
	sudo rm -rf state orderer channels
	mkdir -p state orderer channels

full_clean: clean
	sudo rm -rf crypto-config

fix_watchers:
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
