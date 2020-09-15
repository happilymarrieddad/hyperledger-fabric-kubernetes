const axios = require('axios');

export default {
    get(url) {
        return new Promise((resolve) => {
            axios.get(url).then(val => resolve([val.data])).catch(err => resolve([null, err]));
        })
    },
    post(url, data) {
        return new Promise((resolve) => {
            axios.post(url,data).then(val => resolve([val.data])).catch(err => resolve([null, err]));
        })
    },
    put(url, id, data) {
        return new Promise((resolve) => {
            axios.put(`${url}/${id}`,data).then(val => resolve([val.data])).catch(err => resolve([null, err]));
        })
    },
    delete(url, id) {
        return new Promise((resolve) => {
            axios.delete(`${url}/${id}`).then(val => resolve([val.data])).catch(err => resolve([null, err]));
        })
    }
}
