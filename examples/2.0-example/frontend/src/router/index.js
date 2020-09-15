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
    component: () => import(/* webpackChunkName: "resourcescreate" */ '@/views/resources/Create.vue')
  },
  {
    path: '/resources/:id',
    name: 'ResourcesUpdate',
    component: () => import(/* webpackChunkName: "resourcesedit" */ '@/views/resources/Edit.vue')
  },
  {
    path: '/resource_types',
    name: 'ResourceTypes',
    component: () => import(/* webpackChunkName: "resourcetypes" */ '@/views/resourcetypes/Index.vue')
  },
  {
    path: '/resource_types/create',
    name: 'ResourceTypesCreate',
    component: () => import(/* webpackChunkName: "resourcetypescreate" */ '@/views/resourcetypes/Create.vue')
  },
  {
    path: '/resource_types/:id',
    name: 'ResourceTypesUpdate',
    component: () => import(/* webpackChunkName: "resourcetypesedit" */ '@/views/resourcetypes/Edit.vue')
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
