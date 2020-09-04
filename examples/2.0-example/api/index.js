const express = require('express')
const fabric = require('fabric-network');
const fs = require('fs');
const app = express();
const port = 4000; 
const uuid = require('uuid');

const walletDirectoryPath = './walletstore'
const connectionProfilePath = './network.json';
let mainNetwork;

async function run() {

    const cert = (await fs.promises.readFile('/tmp/crypto/peerOrganizations/org1/users/Admin@org1/msp/signcerts/Admin@org1-cert.pem')).toString();
    const pvkey = (await fs.promises.readFile('/tmp/crypto/peerOrganizations/org1/users/Admin@org1/msp/keystore/7f281db4a80dbef513609a1d6515a1d22e016dba453ce4a3a85288a5d9c1d965_sk')).toString();

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

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/resources', async (req, res) => {
    const contract = mainNetwork.getContract('resources');

    // Submit transactions for the smart contract
    const submitResult = await contract.submitTransaction('index');

    res.json(JSON.parse(submitResult));
})

app.post('/resources', async (req, res) => {
    console.log(req)
    console.log(req.body)

    if (!req || !req.body) {
        res.status(400).send('resource required in body');
        return;
    } 

    const newResource = {
        id: uuid.v4(), // TODO: actually generate new id
        name: req.body.name,
        resource_type_id: req.body.resource_type_id,
    }

    if (newResource.name.length == 0 || newResource.resource_type_id < 1) {
        res.status(400).send('resource requires name and resource_type_id');
        return;
    }

    const contract = mainNetwork.getContract('resources');

    await contract.submitTransaction('create', newResource.id, JSON.stringify(newResource));

    res.json(newResource);
})

app.get('/resources/:id', async (req, res) => {
    if (!req || !req.params) {
        res.status(400).send('resource id required in url parameters');
        return;
    }

    const contract = mainNetwork.getContract('resources');

    // Submit transactions for the smart contract
    const submitResult = await contract.submitTransaction('read', [req.params.id]).catch(err => res.status(400).send(err));

    res.json(submitResult);
})

app.put('/resources/:id', async (req, res) => {
    if (!req || !req.params) {
        res.status(400).send('resource id required in url parameters');
        return;
    }

    if (!req || !req.body) {
        res.status(400).send('resource required in body');
        return;
    }

    const newResource = {}

    if (req.body.name) {
        newResource.name = req.body.name
    }

    if (req.body.resource_type_id) {
        newResource.resource_type_id = req.body.resource_type_id
    }

    if (newResource.name.length == 0 || newResource.resource_type_id < 1) {
        res.status(400).send('resource requires name and resource_type_id');
        return;
    }

    const contract = mainNetwork.getContract('resources');

    await contract.submitTransaction('update', req.params.id, JSON.stringify(newResource)).catch(err => res.status(400).send(err));;

    res.json(newResource);
})

app.listen(port, async () => {
    await run();

    console.log('Server running on port', port);
})