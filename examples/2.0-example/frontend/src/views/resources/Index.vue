<template lang="pug">
    div
        v-data-table(
            :headers="headers"
            :items="resources"
            :items-per-page="10"
            class="elevation-1"
        )
        v-btn(to="/resources/create") Create
</template>

<script>
import { mapState } from 'vuex';

export default {
    data: () => ({
        headers: [
          { text: 'Name', value: 'name' },
          { text: 'Resource Type ID', value: 'resource_type_id' },
        ],
    }),
    computed: mapState({
        resources: state => state.resources.items,
    }),
    mounted() {
        this.$store.dispatch('resources/getAll')
    }
}
</script>