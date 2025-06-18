<template>
  <div class="analysis-con1">
    <br>
    <div class="analysis-title1">
      <div class="analysis-title1-con1"
           v-for="(item, index) in choiceModule"
           :key="index"
           @click="selectedComponent = item.component"
      >
        {{ item.label }}
      </div>
      <div>
<!--        <component :is="selectedComponent" />-->
        <keep-alive>
          <component :is="selectedComponent" />
        </keep-alive>

      </div>
    </div>
  </div>
</template>

<script>
import analysis from "./analysis.vue"
import survival from './Surv.vue'
import cnv from './Cnv-pheatmap1.vue'
import mut from './Mut.vue'
import methy from './Methy.vue'
import HCCPlot from "./HCCPlot.vue";
import HCCHeatmap from "./HCCHeatmap.vue";
export default {
  name: "analysis-con1",
  components:{
    analysis,
    survival,
    cnv,
    mut,
    methy,
    HCCPlot,
    // HCCHeatmap,
  },
  data(){
    return{
      choiceModule:[
        {label: "mRNA Expression", component: analysis ,name :'analysis' },
        {label: 'Survival' , component: survival ,name :'Surv'},
        {label: 'Copy Number Variation(CNV)' , component: cnv},
        // {label: 'Mutation' , component: mut},
        {label: 'DNA Methylation' , component: methy},
        {label: 'Plot Gene Analysis' , component: HCCPlot},
      ], //可以通过上方选择框选择内容
      selectedComponent: analysis, //默认选中第一个组件
    }
  }
}
</script>

<style scoped>

.analysis-con1 {
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* 左对齐 */
  justify-content: flex-start; /* 顶部对齐 */
  margin: 0 auto; /* 上下外边距，水平居中 */
  gap: 20px; /* 内部元素间隔 */
  width: 1400px; /* 最大宽度，防止内容过宽 */
  background: white;

}

.analysis-title1 {
  display: flex;
  flex-wrap: wrap; /* 支持多行显示 */
  gap: 15px; /* 模块之间的间距 */
  margin-bottom: 20px; /* 与下方内容分隔 */

}

.analysis-title1-con1 {
  padding: 10px 15px;
  background-color: #e6f7ff;
  border-radius: 5px;
  transition: background-color 0.3s;
  cursor: pointer;
  box-shadow: #c5cee8 2px 2px 4px;
  font-weight: bold;
  color: #274477;
  margin-left: 20px;
  text-align: center;
}

.analysis-title1-con1:hover {
  background-color: #d1e9ff; /* 悬停颜色变化 */
  transform: scale(1.1);
  color: #172f5b;

}

.analysis-title1-con1 a {
  text-decoration: none;
  color: #3a8ee6; /* 链接颜色 */
  font-weight: bold;
}

.analysis-title1-con1 a:hover {
  text-decoration: underline;
}

</style>
