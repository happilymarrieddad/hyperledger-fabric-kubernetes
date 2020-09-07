const express = require('express');
const router = express.Router();
const uuid = require('uuid');
const network = require('../system/network');

// Querying
router.get('/', async (req, res) => {
    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resources');

    // Submit transactions for the smart contract
    const submitResult = await contract.evaluateTransaction('index');

    res.json(JSON.parse(submitResult.toString()));
})

router.get('/:id', async (req, res) => {
    if (!req || !req.params) {
        res.status(400).send('resource id required in url parameters');
        return;
    }

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resources');

    // Submit transactions for the smart contract
    const submitResult = await contract.evaluateTransaction('read', [req.params.id]);
    
    res.json(JSON.parse(submitResult.toString()));
})

// Commiting Transactions
router.post('/', async (req, res) => {
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

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resources');

    await contract.submitTransaction('create', newResource.id, JSON.stringify(newResource));

    res.json(newResource);
})

router.put('/:id', async (req, res) => {
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

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resources');

    await contract.submitTransaction('update', req.params.id, JSON.stringify(newResource)).catch(err => res.status(400).send(err));;

    res.json(newResource);
})

module.exports = router;