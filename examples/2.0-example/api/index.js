const express = require('express');
const app = express();
const port = 4001;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.use('/resources', require('./routes/resources'));
app.use('/resource_types', require('./routes/resource_types'));

app.listen(port, async () => {
    console.log('Server running on port', port);
})