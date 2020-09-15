<template lang="pug">
    v-form(v-model="valid")
        v-container
            v-row
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

            v-btn(to="/resource_types") Back
            v-btn(@click="save") Create
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
    }),
    methods: {
        async save() {
            const self = this;

            let [res, err] = await this.$store.dispatch('resource_types/createOne', {
                name: self.name,
            });
            if (err) {
                alert(err);
                return
            }

            self.$router.push('/resource_types');
        },
    },
    mounted() {
        this.$store.dispatch('resource_types/getAll')
    }
}
</script>