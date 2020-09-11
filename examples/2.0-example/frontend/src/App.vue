<template lang="pug">

    v-app
      v-app-bar(app color="primary" dark)
      v-navigation-drawer(app floating)
          v-list-item
            v-list-item-content
              v-list-item-title(class="title") Application

          v-divider

          v-list(
            dense
            nav
          )
            v-list-item(link to="/")
              v-list-item-content Home
            v-list-item(link to="/resources")
              v-list-item-content Resources
            v-list-item(link to='/resource_types')
              v-list-item-content Resource Type

      v-content
        v-container(fluid)
          v-row(class="fill-height")
            v-col
              transition(name="fade")
                router-view

</template>

<script>
export default {
  name: 'App',
    data () {
      return {
        items: [
          { title: 'Dashboard', icon: 'mdi-view-dashboard' },
          { title: 'Photos', icon: 'mdi-image' },
          { title: 'About', icon: 'mdi-help-box' },
        ],
        right: null,
      }
    },
};
</script>
