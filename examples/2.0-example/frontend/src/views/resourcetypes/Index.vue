<template lang="pug">
    div
        v-data-table(
            :headers="headers"
            :items="resource_types"
            :items-per-page="10"
            class="elevation-1"
            :loading="loading"
        )
            template(v-slot:item.actions="{ item }")
                v-icon(
                    small
                    class="mr-2"
                    @click="editItem(item)"
                ) mdi-pencil
        v-btn(to="/resource_types/create") Create
</template>

<script>
import { mapState } from 'vuex';

export default {
    data: () => ({
        loading: false,
        headers: [
          { text: 'Name', value: 'name' },
          { text: 'Actions', value: 'actions', sortable: false },
        ],
    }),
    computed: mapState({
        resource_types: state => state.resource_types.items,
    }),
    methods: {
        async fetchData() {
            this.loading = true;
            await this.$store.dispatch('resource_types/getAll');
            this.loading = false;
        },
        editItem(item) {
            return this.$router.push(`/resource_types/${item.id}`)
        }
    },
    mounted() {
        this.fetchData()
    }
}
</script>