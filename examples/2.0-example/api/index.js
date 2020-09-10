const express = require('express');
const app = express();
const port = 4001;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/resources', require('./routes/resources'));
app.use('/resource_types', require('./routes/resource_types'));

app.listen(port, async () => {
    console.log('Server running on port', port);
})