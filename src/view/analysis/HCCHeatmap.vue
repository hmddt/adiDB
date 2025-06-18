<template>
  <div>
    <p>PDF Base64: {{ pdf64 }}</p>
    <!-- 你可以用 <embed> 显示pdf -->
    <embed
      v-if="pdf64"
      :src="'data:application/pdf;base64,' + pdf64"
      type="application/pdf"
      width="100%"
      height="600px"
    />
  </div>
</template>

<script>
export default {
  name: "HCCHeatmap",
  data() {
    return {
      pdf64: "",
      gene: ["LEP", "RBP4"],
    };
  },
  mounted() {
    // 把数组转成逗号分隔字符串
    const genesParam = this.gene.join(",");
    this.$http
      .get("/trendapi/plot_adipose_heatmap?genes=" + genesParam)
      .then((res) => {
        this.pdf64 = res.data; // 注意是 res.data
      })
      .catch((err) => {
        console.error(err);
      });
  },
};
</script>

<style scoped>


</style>
