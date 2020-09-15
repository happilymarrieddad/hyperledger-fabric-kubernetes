const express = require('express');
const router = express.Router();
const uuid = require('uuid');
const network = require('../system/network');

// Querying
router.get('/', async (req, res) => {
    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resource_types');

    // Submit transactions for the smart contract
    const submitResult = await contract.evaluateTransaction('index').catch(err => res.status(400).send(err));

    // Remove the unnecessary quotes
    res.json(JSON.parse(submitResult.toString()));
})

router.get('/:id/transactions', async (req, res) => {
    if (!req || !req.params) {
        res.status(400).send('resource id required in url parameters');
        return;
    }

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resource_types');

    // Submit transactions for the smart contract
    const submitResult = await contract.evaluateTransaction('transactions', req.params.id).catch(err => res.status(400).send(err));

    // Remove the unnecessary quotes
    res.json(JSON.parse(submitResult.toString()));
})

router.get('/:id', async (req, res) => {
    if (!req || !req.params) {
        res.status(400).send('resource_type id required in url parameters');
        return;
    }

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resource_types');

    // Submit transactions for the smart contract
    const submitResult = await contract.evaluateTransaction('read', req.params.id).catch(err => res.status(400).send(err));

    // Remove the unnecessary quotes
    res.json(JSON.parse(submitResult.toString()));
})

// Commiting Transactions
router.post('/', async (req, res) => {
    if (!req || !req.body) {
        res.status(400).send('resource_type required in body');
        return;
    }

    const newResourceType = {
        id: uuid.v4(), // TODO: actually generate new id
        name: req.body.name,
    }

    if (newResourceType.name.length == 0 || newResourceType.resource_type_type_id < 1) {
        res.status(400).send('resource_type requires name and resource_type_type_id');
        return;
    }

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resource_types');

    await contract.submitTransaction('create', newResourceType.id, newResourceType.name).catch(err => res.status(400).send(err));;

    res.json(newResourceType);
})

router.put('/:id', async (req, res) => {
    const newResourceType = {
        id: req.params.id,
        name: req.body.name
    }

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resource_types');

    await contract.submitTransaction('update', req.params.id, req.body.name).catch(err => res.status(400).send(err));;

    res.json(newResourceType);
})

router.delete('/:id', async (req, res) => {
    if (!req || !req.params) {
        res.status(400).send('resource id required in url parameters');
        return;
    }

    mainNetwork = await network.setup();

    const contract = mainNetwork.getContract('resource_types');

    // Submit transactions for the smart contract
    const submitResult = await contract.evaluateTransaction('delete', req.params.id).catch(err => res.status(400).send(err));
    console.log(submitResult)

    // Remove the unnecessary quotes
    res.send("success");
})

module.exports = router;