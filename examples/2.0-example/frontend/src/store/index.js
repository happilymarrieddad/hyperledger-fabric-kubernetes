import Vue from 'vue'
import Vuex from 'vuex'

import resources from '@/store/modules/resources';
import resource_types from '@/store/modules/resource_types';

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
  },
  mutations: {
  },
  actions: {
  },
  modules: {
    resources,
    resource_types,
  }
})
