import Vue from 'vue'
import Router from 'vue-router'
import Home from './views/Home.vue'

Vue.use(Router)

export default new Router({
    mode: 'history',
    base: process.env.BASE_URL,
    routes: [
        {
            path: '/',
            name: 'home',
            component: () => import(/* webpackChunkName: "home" */ './views/Home.vue')
        },
        {
            path: '/create',
            name: 'create',
            component: () => import(/* webpackChunkName: "create" */ './views/Create.vue')
        },
        {
            path: '/update/:id',
            name: 'update',
            component: () => import(/* webpackChunkName: "update" */ './views/Update.vue')
        }
    ]
})
