<template>
  <div class="sequence-con1">
    <br>
    <div class="sequence-title1">
      <div class="sequence-title1-con1"
           v-for="(item , index) in choiceModule"
           :key="index"
           @click = "selectedComponent = item.component"
      >
        {{ item.label}}
      </div>
      <div>
        <keep-alive>
          <component :is = "selectedComponent"/>
        </keep-alive>
      </div>
    </div>
  </div>
</template>

<script>
import Alignment from './SequenceAlignment.vue'
import logo from './SequenceLogo.vue'
export default {
  name: "sequencecon1",
  components:{
    Alignment,
    logo,
  },
  data(){
    return{
      choiceModule:[
        {label:"Sequence Alignment" , component:Alignment},
        {label: "Sequence Logo" , component: logo}
      ],
      selectedComponent:Alignment,
    }
  }

}
</script>

<style scoped>
.sequence-con1{
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* 左对齐 */
  justify-content: flex-start; /* 顶部对齐 */
  margin: 0 auto; /* 上下外边距，水平居中 */
  gap: 20px; /* 内部元素间隔 */
  width: 1400px; /* 最大宽度，防止内容过宽 */
  background: white;
}

.sequence-title1{
  display: flex;
  flex-wrap: wrap; /* 支持多行显示 */
  gap: 15px; /* 模块之间的间距 */
  margin-bottom: 20px; /* 与下方内容分隔 */
}

.sequence-title1-con1{
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

.sequence-title1-con1 :hover{
  background-color: #d1e9ff; /* 悬停颜色变化 */
  transform: scale(1.1);
  color: #172f5b;
}

.sequence-title1-con1 a{
  text-decoration: none;
  color: #3a8ee6; /* 链接颜色 */
  font-weight: bold;
}

.sequence-title1-con1 a:hover{
  text-decoration: underline;
}
</style>
