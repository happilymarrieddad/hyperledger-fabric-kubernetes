import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import(/* webpackChunkName: "home" */ '@/views/Home.vue')
  },
  {
    path: '/resources',
    name: 'Resources',
    component: () => import(/* webpackChunkName: "resources" */ '@/views/resources/Index.vue')
  },
  {
    path: '/resources/create',
    name: 'ResourcesCreate',
    component: () => import(/* webpackChunkName: "resourcesCreate" */ '@/views/resources/Create.vue')
  },
  {
    path: '/resource_types',
    name: 'ResourceTypes',
    component: () => import(/* webpackChunkName: "resourcetypess" */ '@/views/resourcetypes/Index.vue')
  },
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
