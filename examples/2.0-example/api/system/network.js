const fabric = require('fabric-network');
const fs = require('fs');

const pvkKeyName = `aa904a17aec65456b486be7da7aada45cd28889efc1d79c71a2788d9b42b1dee_sk`
const walletDirectoryPath = './system/walletstore'
const connectionProfilePath = `./system/configs/${process.env.ENV == 'dev' ? 'network-local' : 'network'}.json`;
const admin1org1MSPPath = `${process.env.CRYPTO_PATH || '/tmp/crypto'}/peerOrganizations/org1/users/Admin@org1/msp`
const certPath = `${admin1org1MSPPath}/signcerts/Admin@org1-cert.pem`
const pvtKeyPath = `${admin1org1MSPPath}/keystore/${pvkKeyName}`
let mainNetwork = null;

async function setup() {
    if (mainNetwork) {
        return mainNetwork;
    }

    const cert = (await fs.promises.readFile(certPath)).toString();
    const pvkey = (await fs.promises.readFile(pvtKeyPath)).toString();

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

    return mainNetwork;
}

module.exports.setup = setup;