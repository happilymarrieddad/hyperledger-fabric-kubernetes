import Vue from 'vue'
import Vuex from 'vuex'
import * as moment from 'moment';

const baseURL = `${process.env.VUE_APP_apiurl}/v1`

Vue.use(Vuex)

export default new Vuex.Store({
    state: {
        raw_resources: [],
        raw_resource_types: []
    },
    mutations: {

    },
    actions: {
        async fetchRawResourceTypes({ state }) {

            const response = await fetch(`${baseURL}/rawresourcetypes`)
            const rawResourceTypes = await response.json()

            state.raw_resource_types = [{ id: 0, name: "Please Select Type" }].concat(rawResourceTypes || [])

            return null;
        },
        async fetchRawResource({ state }) {

            const response = await fetch(`${baseURL}/rawresources`)
            let rawResources = await response.json()

            rawResources = rawResources.map(el => {
                el.arrival_time = moment(el.arrival_time || moment()).format('MM/DD/YYYY')
                el.timestamp = moment(el.timestamp || moment()).format('MM/DD/YYYY')

                return el;
            })

            state.raw_resources = rawResources || []

            return null;
        },
        async get({ state }, id) {

            const response = await fetch(`${baseURL}/rawresources/${id}`)
            let rawResource = await response.json()

            return rawResource;
        },
        async create({ state }, new_item) {

            new_item.weight = +new_item.weight

            const response = await fetch(`${baseURL}/rawresources`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(new_item)
            })

            let newRawResource = response.json()

            return newRawResource
        },

        async update({ state }, { id, data }) {

            data.weight = +data.weight

            const response = await fetch(`${baseURL}/rawresources/${id}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })

            let newRawResource = response.json()

            return newRawResource
        },
        async destroy({ state }, id) {

            const response = await fetch(`${baseURL}/rawresources/${id}`, {
                method: 'DELETE'
            })

            return Promise.resolve();
        }
    }
})
