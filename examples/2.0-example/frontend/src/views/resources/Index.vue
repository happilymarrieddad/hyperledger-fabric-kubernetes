<template lang="pug">
    div
        v-data-table(
            :headers="headers"
            :items="resources"
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
        v-btn(to="/resources/create") Create
</template>

<script>
import { mapState } from 'vuex';

export default {
    data: () => ({
        loading: false,
        headers: [
          { text: 'Name', value: 'name' },
          { text: 'Resource Type ID', value: 'resource_type_id' },
          { text: 'Active', value: 'active' },
          { text: 'Actions', value: 'actions', sortable: false },
        ],
    }),
    computed: mapState({
        resources: state => state.resources.items,
    }),
    methods: {
        async remove(id) {
            await this.$store.dispatch('resources/deleteOne', id);
            await this.fetchData();
        },
        async fetchData() {
            this.loading = true;
            await this.$store.dispatch('resources/getAll');
            this.loading = false;
        },
        editItem(item) {
            return this.$router.push(`/resources/${item.id}`)
        }
    },
    mounted() {
        this.fetchData();
    }
}
</script>