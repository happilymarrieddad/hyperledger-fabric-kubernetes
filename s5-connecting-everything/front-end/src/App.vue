<template lang="pug">
  
    div

        v-toolbar
            v-toolbar-title Welcome

            v-toolbar-items
                v-btn(text to="/") Home
                v-btn(text to="/create") Create

        
        v-app
            v-container(fluid)
                router-view

</template>

<script>
export default {
  name: "App",
  data: () => ({
    //
  })
};
</script>

<style scoped>
</style>
