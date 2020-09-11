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

                    v-select(
                        v-model="resource_type_id"
                        :rules="resourceTypeRules"
                        :items="resource_types"
                        label="Standard"
                    )
            v-btn(to="/resources") Back
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
      resource_type_id: 0,
      resourceTypeRules: [
        v => !!v || 'Resource Type is required',
      ],
    }),
    computed: mapState({
        resource_types: state => state.resource_types.items.map(el => {
            return {
                text: el.name,
                value: el.id,
            }
        }),
    }),
    methods: {
        async save() {
            const self = this;

            let [res, err] = await this.$store.dispatch('resources/createOne', {
                name: self.name,
                resource_type_id: self.resource_type_id,
            });

            // if (err) {
            //     alert(err);
            //     return
            // }
            console.log(res, err)

            self.$router.push('/resources');
        },
    },
    mounted() {
        this.$store.dispatch('resource_types/getAll')
    }
}
</script>