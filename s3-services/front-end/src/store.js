import Vue from 'vue'
import Vuex from 'vuex'
import * as moment from 'moment';
import { get } from 'http';

Vue.use(Vuex)

export default new Vuex.Store({
    state: {
        raw_resources: [
            {
                id: 1,
                name: 'Iron Ore',
                type_id: 1,
                weight: 42000,
                arrival_time: moment().format('MM/DD/YYYY'),
                timestamp: moment().format('MM/DD/YYYY')
            },
            {
                id: 2,
                name: 'Copper Ore',
                type_id: 2,
                weight: 42000,
                arrival_time: moment().format('MM/DD/YYYY'),
                timestamp: moment().format('MM/DD/YYYY')
            }
        ],
        raw_resource_types: [
            { id: 1, name: 'Iron' },
            { id: 2, name: 'Copper' },
            { id: 3, name: 'Platinum' }
        ]
    },
    mutations: {

    },
    actions: {
        async create({ state }, new_item) {
            new_item.timestamp = moment().format('MM/DD/YYYY')
            new_item.id = +state.raw_resources[state.raw_resources.length - 1].id + 1

            state.raw_resources.push(new_item);

            return Promise.resolve();
        },
        async get({ state }, id) {
            return state.raw_resources.find(el => +el.id === +id);
        },
        async update({ state }, { id, data }) {
            const index = state.raw_resources.findIndex(el => +el.id === +id);
            Object.assign(state.raw_resources[index], data)

            return Promise.resolve()
        },
        async destroy({ state }, id) {
            state.raw_resources = state.raw_resources.filter(el => +el.id !== +id)

            return Promise.resolve();
        }
    }
})
