import axios from '@/utils/axios';

export default {
    namespaced: true,
    state: () => ({
        items: [],
    }),
    mutations: {},
    actions: {
        async getAll({ state }) {
            let [res, err] = await axios.get('http://localhost:4000/resource_types')
            if (err) {
                return [null,err];
            }

            state.items = res;

            return [res];
        },
        async getOne({}, id = 0) {
            let [res, err] = await axios.get(`http://localhost:4000/resource_types/${id}`)
            if (err) {
                return [null,err];
            }

            return [res];
        },
        async createOne({}, newObj) {
            let [res, err] = await axios.post(`http://localhost:4000/resource_types`, newObj)
            if (err) {
                return [null,err];
            }

            return [res];
        },
        async updateOne({}, existingObj) {
            let [res, err] = await axios.put(`http://localhost:4000/resource_types`, existingObj.id, existingObj)
            if (err) {
                return [null,err];
            }

            return [res];
        },
        async deleteOne({}, id = 0) {
            let [res, err] = await axios.delete(`http://localhost:4000/resource_types/${id}`)
            if (err) {
                return [null,err];
            }

            return [res];
        },
        async getTransactions({}, id = 0) {
            let [res, err] = await axios.get(`http://localhost:4000/resource_types/${id}/transactions`)
            if (err) {
                return [null,err];
            }

            return [res];
        }
    },
    getters: {}
}
