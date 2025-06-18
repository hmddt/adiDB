<template>
  <div id="immune-con1">
    <br>
    <div class="immune-title">
      <div
        class="immune-title1-con1"
        v-for="(item, index) in choiceModule"
        :key="index"
        @click="selectedComponent = item.component"
      >
        {{ item.label }}
      </div>
    </div>
    <div>
      <keep-alive>
      <component :is="selectedComponent" />
      </keep-alive>
    </div>
  </div>
</template>

<script>
import GSEA from "../GSEA.vue";
import checkpoint from "./checkpoint.vue";
import chemokine from "./chemokine.vue";
import receptor from "./receptor.vue";
import immustimulator from "./immustimulator.vue";
import immuinhibitor from "./immuinhibitor.vue";
import immunescore from "./immunescore.vue";
import immucell from "./immucell.vue";

export default {
  name: "immune-con1",
  components: {
    checkpoint,
    chemokine,
    receptor,
    GSEA,
    immustimulator,
    immuinhibitor,
    immunescore,
    immucell,
  },
  data() {
    return {
      choiceModule: [
        { label: "ssGSEA", component: GSEA , name:'ssGSEA' },
        { label: "Checkpoint", component: checkpoint },
        { label: "Chemokine", component: chemokine },
        { label: "Receptor", component: receptor },
        { label: "Immune Stimulator", component: immustimulator },
        { label: "Immune Inhibitor", component: immuinhibitor },
        // { label: "Immune Score", component: immunescore },
        // { label: "Immune Cell", component: immucell },
      ],
      selectedComponent: GSEA, // 默认选中第一个组件
    };
  },
};
</script>

<style scoped>
#immune-con1 {
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* 左对齐 */
  justify-content: flex-start; /* 顶部对齐 */
  margin: 0 auto; /* 上下外边距，水平居中 */
  gap: 20px; /* 内部元素间隔 */
  background: white;
  max-width: 1400px; /* 最大宽度，防止内容过宽 */
}

.immune-title {
  display: flex;
  flex-wrap: wrap; /* 支持多行显示 */
  gap: 15px; /* 模块之间的间距 */
  margin-bottom: 20px; /* 与下方内容分隔 */
}

.immune-title1-con1 {
  padding: 10px 15px;
  background-color: #e6f7ff;
  border-radius: 5px;
  transition: background-color 0.3s;
  cursor: pointer;
  box-shadow: #c5cee8 2px 2px 4px;
  font-weight: bold;
  color: #01488c;
  margin-left: 20px;
  text-align: center;
}

.immune-title1-con1:hover {
  background-color: #d1e9ff;
}


</style>
