import Vue from 'vue'
import Vuex from 'vuex'
import * as moment from 'moment';

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
        ]
    },
    mutations: {

    },
    actions: {

    }
})
