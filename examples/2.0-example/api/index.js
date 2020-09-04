const express = require('express')
const fabric = require('fabric-network');
const fs = require('fs');
const app = express();
const port = 4000;

const walletDirectoryPath = './walletstore'
const connectionProfilePath = './network.json';
let mainNetwork;

async function run() {

    const cert = (await fs.promises.readFile('../docker/crypto-config/peerOrganizations/org1/users/Admin@org1/msp/signcerts/Admin@org1-cert.pem')).toString();
    const pvkey = (await fs.promises.readFile('../docker/crypto-config/peerOrganizations/org1/users/Admin@org1/msp/keystore/513ed3472cb1bc642ad1287a6121a88d4cc8d63fd25923b55aa35a2c2771d9ed_sk')).toString();

    // Connect to a gateway peer
    const wallet = await fabric.Wallets.newFileSystemWallet(walletDirectoryPath);
    const identity = {
        credentials: {
            certificate: cert,
            privateKey: pvkey,
        },
        mspId: 'org1',
        type: 'X.509',
    };
    await wallet.put('admin', identity);
    const gatewayOptions = {
        identity: 'admin', // Previously imported identity
        wallet,
        discovery: {
            asLocalhost: true,
            enabled: false
        }
    };
    // read a common connection profile in json format
    const data = fs.readFileSync(connectionProfilePath);
    const connectionProfile = JSON.parse(data);

    // use the loaded connection profile
    const gateway = new fabric.Gateway();
    await gateway.connect(connectionProfile, gatewayOptions);

    // Obtain the smart contract with which our application wants to interact
    mainNetwork = await gateway.getNetwork('main');
}

app.get('/resources', async (req, res) => {
    const contract = mainNetwork.getContract('resources');

    // Submit transactions for the smart contract
    const submitResult = await contract.submitTransaction('index');

    res.json(JSON.parse(submitResult));
})

app.listen(port, async () => {
    await run();

    console.log('Server running on port', port);
})