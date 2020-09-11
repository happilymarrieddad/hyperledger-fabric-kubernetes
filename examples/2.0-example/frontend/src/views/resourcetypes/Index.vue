<template lang="pug">
    v-data-table(
        :headers="headers"
        :items="resource_types"
        :items-per-page="5"
        class="elevation-1"
    )
</template>

<script>
import { mapState } from 'vuex';

export default {
    data: () => ({
        headers: [
          { text: 'Name', value: 'name' },
        ],
    }),
    computed: mapState({
        resource_types: state => state.resource_types.items,
    }),
    mounted() {
        this.$store.dispatch('resource_types/getAll')
    }
}
</script>