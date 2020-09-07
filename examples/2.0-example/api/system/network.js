const fabric = require('fabric-network');
const fs = require('fs');

const pvkKeyName = `27b8e781f7ceab9083c23794f7b89f4cbf8b532366c27c6e6c16d4fb3b6fb83e_sk`
const walletDirectoryPath = './system/walletstore'
const connectionProfilePath = './system/configs/network-local.json';
const admin1org1MSPPath = `../docker/crypto-config/peerOrganizations/org1/users/Admin@org1/msp`
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