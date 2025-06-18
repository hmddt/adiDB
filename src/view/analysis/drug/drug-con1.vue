<template>
<div id="drug-con1">
  <br>
  <div class="drug-title">
    <div
      class="drug-title1-con1"
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
import drug from './drug.vue';
import pathway from "./pathway.vue";
import interactions from "./interactions.vue";
export default {
  name: "drug-con1",
  components:{
    drug,
    pathway,
    interactions
  },
  data(){
    return{
      choiceModule: [
        { label: "Drug Susceptibility Analysis" , component: drug},
        { label: "Drug Pathway Analysis" , component: pathway},
        { label: "Drug Interactions Analysis" , component:interactions }
      ],
      selectedComponent: drug, // 默认选中第一个组件
    }
  }
}
</script>

<style scoped>
#drug-con1 {
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* 左对齐 */
  justify-content: flex-start; /* 顶部对齐 */
  margin: 0 auto; /* 上下外边距，水平居中 */
  gap: 20px; /* 内部元素间隔 */
  max-width: 1400px; /* 最大宽度，防止内容过宽 */
  background: white;
}

.drug-title {
  display: flex;
  flex-wrap: wrap; /* 支持多行显示 */
  gap: 15px; /* 模块之间的间距 */
  margin-bottom: 20px; /* 与下方内容分隔 */
}

.drug-title1-con1 {
  padding: 10px 15px;
  background-color: #e6f7ff;
  border-radius: 5px;
  transition: background-color 0.3s;
  cursor: pointer;
  box-shadow: #c5cee8 2px 2px 4px;
  font-weight: bold;
  margin-left: 20px;
  color: #01488c;
  text-align: center;
}

.drug-title1-con1:hover {
  background-color: #d1e9ff;
}

</style>
