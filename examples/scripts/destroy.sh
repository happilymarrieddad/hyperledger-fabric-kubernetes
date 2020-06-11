sudo rm -rf channels
sudo rm -rf crypto-config
sudo rm -rf orderer
sudo rm -rf state
sudo rm -rf fabric-ca-client
sudo rm -rf fabric-ca-server
sudo rm -rf fabric-ca-client2
sudo rm -rf fabric-ca-server2
sudo rm -rf state
sudo rm -rf _crypto-config
sudo rm -rf chaincode/github.com
sudo rm /home/$USER/.hfc-key-store/*
sudo rm -rf client/certs

# stop all containers:
docker kill $(docker ps -q)

# remove all containers
docker rm $(docker ps -a -q)

# remove all docker images
# docker rmi $(docker images -q) --force

# docker system prune -a