<template>
  <ThreeDMolViewer :pdbFileName = "this.pdbname+ '.pdb'"></ThreeDMolViewer>
</template>

<script>
import ThreeDMolViewer from "./tool/3DmolDetail.vue";

export default {
  name: "test",
  data(){
    return{
      pdbname:"Peroxisome_PPAGR",
    }
  },
  components: {ThreeDMolViewer},

}
</script>

<style scoped>

</style>
