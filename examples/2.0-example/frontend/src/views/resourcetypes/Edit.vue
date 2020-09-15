<template lang="pug">
    v-form(v-model="valid")
        v-container
            v-row
                v-col(
                    cols="12"
                    md="4"
                )
                    v-text-field(
                        v-model="$route.params.id"
                        label="ID"
                        disabled
                    )
                v-col(
                    cols="12"
                    md="4"
                )
                    v-text-field(
                        v-model="name"
                        :rules="nameRules"
                        :counter="50"
                        label="Name"
                        required
                    )
            v-row
                v-col(
                    cols="12"
                    md="12"
                )
                    v-data-table(
                        :headers="headers"
                        :items="transactions"
                        :items-per-page="10"
                        class="elevation-1"
                    )
                        template(v-slot:item.resource_type="{ item }")
                            span {{ item.resource_type | json }}

            v-btn(to="/resource_types") Back
            v-btn(@click="save") Save
</template>

<script>
import { mapState } from 'vuex';

export default {
    data: () => ({
      valid: false,
      name: '',
      nameRules: [
        v => !!v || 'Name is required',
        v => v.length <= 50 || 'Name must be less than 50 characters',
      ],
      transactions: [],
        headers: [
          { text: 'TXID', value: 'tx_id' },
          { text: 'Value', value: 'resource_type' },
          { text: 'Timestamp', value: 'timestamp' },
        ],
    }),
    methods: {
        async save() {
            const self = this;

            let [res, err] = await this.$store.dispatch('resource_types/updateOne', {
                id: self.$route.params.id,
                name: self.name,
            });
            if (err) {
                alert(err);
                return
            }

            self.$router.push('/resource_types');
        },
        async fetchData() {
            let [res, err] = await this.$store.dispatch('resource_types/getOne', this.$route.params.id)
            if (err) {
                alert(err);
                return
            }

            this.name = res.name;

            [res, err] = await this.$store.dispatch('resource_types/getTransactions', this.$route.params.id)
            if (err) {
                alert(err);
                return
            }
            if (err) {
                alert(err);
                return
            }

            this.transactions = res;
        }
    },
    mounted() {
        this.fetchData();
    }
}
</script>