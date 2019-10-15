<template lang="pug">
  
    v-row
        v-col(md="8" offset-md="2")

            v-data-table(
                :headers="headers"
                :items="raw_resources"
            )
                template(v-slot:item.weight="{item}")
                    span {{ item.weight }} lbs.

                template(v-slot:item.id="{ item }")
                    router-link(:to="'/update/' + item.id") Update
                    a(@click="destroy(item.id)") Destroy

</template>

<script>
import { mapState } from "vuex";

export default {
  data() {
    return {
      headers: [
        { text: "Name", value: "name" },
        { text: "Weight", value: "weight" },
        { text: "Timestamp", value: "timestamp" },
        { text: "Actions", value: "id" }
      ]
    };
  },
  computed: {
    ...mapState({
      raw_resources: state => state.raw_resources
    })
  },
  methods: {
    async destroy(id) {
      const vm = this;

      await vm.$store.dispatch("destroy", id);
      await vm.$store.dispatch("fetchRawResource");
    }
  },
  mounted() {
    this.$store.dispatch("fetchRawResource");
  }
};
</script>
