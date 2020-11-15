Hyperledger Fabric on Kubernetes
===================================

## Issue fix for file watching
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p




## Kubernetes Production

# Install kops
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops


# Install AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/install-bundle.html

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws


aws configure

account ID = 
account Secret = 
region = us-west-1
output = json


# To test our AWS CLI use this command
aws ec2 describe-availability-zones --region us-west-1



export KOPS_STATE_STORE=s3://<name of your bucket>



# Commands to create network
ssh-keygen
(No passphrase)

kops create cluster hyperledger.k8s.local --zones us-west-1b,us-west-1c --node-count 3 --master-zones us-west-1b,us-west-1c --master-count 3 --authorization AlwaysAllow --yes

kops delete cluster hyperledger.k8s.local


# Commands to copy over files to kubernetes storage

kubectl cp ./s5-connecting-everything/scripts $(kubectl get pods -o=name | grep ca-client-deployment | sed "s/^.\{4\}//"):/
kubectl cp ./config.yaml $(kubectl get pods -o=name | grep ca-client-deployment | sed "s/^.\{4\}//"):/files
kubectl cp ./s5-connecting-everything/chaincode/rawresources $(kubectl get pods -o=name | grep ca-client-deployment | sed "s/^.\{4\}//"):/scripts/chaincode
kubectl cp ./configtx.yaml $(kubectl get pods -o=name | grep ca-client-deployment | sed "s/^.\{4\}//"):/scripts
kubectl cp ./bin $(kubectl get pods -o=name | grep ca-client-deployment | sed "s/^.\{4\}//"):/scripts


# Adding nginx to our network
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/ingress-nginx/v1.6.0.yaml


# Adding secrets
kubectl create secret generic couchdb --from-literal username=nick --from-literal password=1234



## Kubernetes Local

# Generating Channel Artifacts
./bin/nicks/configtxgen -profile OrdererGenesis -channelID syschannel -outputBlock ./orderer/genesis.block -configPath=/scripts
./bin/nicks/configtxgen -profile MainChannel -outputCreateChannelTx ./channels/mainchannel.tx -channelID mainchannel -configPath=/scripts
./bin/nicks/configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org1-anchors.tx -channelID mainchannel -asOrg org1 -configPath=/scripts
./bin/nicks/configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channels/org2-anchors.tx -channelID mainchannel -asOrg org2 -configPath=/scripts


# $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c


kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel create -c mainchannel -f ./channels/mainchannel.tx -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem'



kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel join -b mainchannel.block'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'cp mainchannel.block ./channels/mainchannel.block'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel join -b ./channels/mainchannel.block'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel join -b ./channels/mainchannel.block'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel join -b ./channels/mainchannel.block'

kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem -c mainchannel -f ./channels/org1-anchors.tx'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer channel update -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem -c mainchannel -f ./channels/org2-anchors.tx'

sleep 15

kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 0'

kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode instantiate -C mainchannel -n rawresources -v 0 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"


kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") bash
peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":\"1\",\"name\":\"Iron Ore\",\"weight\":42000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem


kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode query -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"\",\"\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode query -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"\",\"\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode query -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"\",\"\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode query -C mainchannel -n rawresources -c '{\"Args\":[\"index\",\"\",\"\"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"

# Updating Chaincode


kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'
kubectl exec -it $(kubectl get pods -o=name | grep cli-peer1-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 2'

kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode upgrade -C mainchannel -n rawresources -v 2 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"


kubectl exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") bash

peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":\"2\",\"name\":\"Iron Ore\",\"weight\":20000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem
peer chaincode invoke -C mainchannel -n rawresources -c '{"Args":["store", "{\"id\":\"3\",\"name\":\"Iron Ore\",\"weight\":10000}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem

peer chaincode query -C mainchannel -n rawresources -c '{"Args":["queryString", "{\"selector\":{ \"weight\": { \"$gt\":5000 } }}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem

https://docs.couchdb.org/en/2.2.0/api/database/find.html#find-expressions


# Creating indexes for our chaincode


docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'
docker exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'
docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'
docker exec -it $(kubectl get pods -o=name | grep cli-peer1-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 3'

docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode upgrade -C mainchannel -n rawresources -v 3 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"

docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") bash

peer chaincode query -C mainchannel -n rawresources -c '{"Args":["queryString", "{\"selector\":{ \"weight\": { \"$gt\":5000 } }}"]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem

# Adding an update func


docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 5'
docker exec -it $(kubectl get pods -o=name | grep cli-peer1-org1-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 5'
docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 5'
docker exec -it $(kubectl get pods -o=name | grep cli-peer1-org2-deployment | sed "s/^.\{4\}//") -- bash -c 'peer chaincode install -p rawresources -n rawresources -v 5'

docker exec -it $(kubectl get pods -o=name | grep cli-peer0-org1-deployment | sed "s/^.\{4\}//") -- bash -c "peer chaincode upgrade -C mainchannel -n rawresources -v 5 -c '{\"Args\":[]}' -o orderer0-service:7050 --tls --cafile=/etc/hyperledger/orderers/msp/tlscacerts/ca-root-7054.pem"



## Kubernetes Local END


## S2-L1 - BYFN Example
1) cd fabric-samples/first-network
NOTE - If you have a problem with the generation of the certs use the binaries provided in the repo
2) ./byfn.sh generate
3) ./byfn.sh up
4) ./byfn.sh down


## S1-L1 - Introduction
[Link to Hyperledgers Main Site](https://www.hyperledger.org/projects/fabric)
[Link to Hyperledgers Getting Started Page](https://hyperledger-fabric.readthedocs.io/en/release-1.4/getting_started.html)

## S1-L2 - 
[Link to install of Linux Mint on Windows 10](https://www.youtube.com/watch?v=qPdNFuDGnFA)

## S1-L6 -
[Link to github repo](https://github.com/happilymarrieddad/hyperledger-fabric-kubernetes)

This is for Ubuntu-like distro's
1) sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y
2) Install virtual box - https://www.virtualbox.org/wiki/Linux_Downloads
3) sudo apt install build-essential zsh curl make emacs htop -y
4) https://github.com/robbyrussell/oh-my-zsh
5) https://golang.org/dl/
    - tar -C /usr/local -xzf go1.15.linux-amd64.tar.gz
6) sudo apt install nodejs
    - curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && sudo apt-get install --yes nodejs
7) http://docs.docker.com/install/linux/docker-ce/ubuntu/
    - IF ON MINT!!!! Make sure you use this command instead
        - sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
8) https://kubernetes.io/docs/tasks/tools/install-kubectl/
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
9) https://kubernetes.io/docs/tasks/tools/install-minikube/
    - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
    - sudo install minikube /usr/local/bin
10) curl -sSL http://bit.ly/2ysbOFE | bash -s
    - export PATH=$HOME/bin:$PATH

OPTIONAL
11) https://docs.docker.com/compose/install/

## My Own Notes
[Link to Markup for README's](https://guides.github.com/features/mastering-markdown/)
[Link to Chaincode Stub](https://github.com/hyperledger/fabric-chaincode-go/blob/master/shim/interfaces.go)
[Link to Install Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/)