<template>
<div id="maindrug">
  <div class="drug-body">
    <div class="component-name">
      <!--        放入组件名称-->
      <p>
          <span>
            {{activeTabName}}
          </span>
      </p>
    </div>
<!--    <div class="custom-tabs">-->
<!--      <div-->
<!--        v-for="(tab, index) in tabs"-->
<!--        :key="index"-->
<!--        @click="changeTab(index)"-->
<!--        :class="{ 'active-tab': activeTabIndex === index }"-->
<!--      >-->
<!--        <span>{{ tab.label }}</span>-->
<!--        <span class="tab-separator" v-if="index !== tabs.length - 1"></span> &lt;!&ndash; 添加竖线 &ndash;&gt;-->
<!--      </div>-->
<!--    </div>-->

    <!-- 标签页内容区域 -->
    <div class="tab-content">
      <component :is="activeTabComponent"></component>
    </div>
    <Footer></Footer>
  </div>
</div>
</template>

<script>
import Footer from "../footer.vue";
import Drug from "./drug.vue";
import Pathway from "./pathway.vue";

export default {
  name: "MainDrug",
  components: {
    Footer,
    Drug,
    Pathway
  },
  data() {
    return{
      tabs:[
        { label:"Drug Relevance",component:Drug},
        { label: "Drug Pathway",component: Pathway},
      ],
      //激活当前标签页索引
      activeTabIndex : 0
    }

  },
  mounted() {
    const analysisName = this.$route.query.name;
    if (analysisName) {
      const index = this.tabs.findIndex(tab => tab.label === analysisName);
      if (index !== -1) {
        this.activeTabIndex = index; // 设置为找到的索引
      }
    }
  },
  watch: {
    '$route.query.name'(newName) {
      const index = this.tabs.findIndex(tab => tab.label === newName);
      if (index !== -1) {
        this.activeTabIndex = index;
      }
    }
  },


  computed:{
    //计算属性，返回当前标签页组件
    activeTabComponent() {
      return this.tabs[this.activeTabIndex].component;
    },
    activeTabName(){
      return this.tabs[this.activeTabIndex].label;
    },
  },
  methods:{
    //切换标签页
    changeTab(index) {
      this.$router.push({ path: '/analysis/drug' }); // 路由跳转并传参
      this.activeTabIndex = index;
    }
  }
}
</script>

<style scoped>
#maindrug{
  width: 1100px;
  margin: 0 auto;
  border-color: #ffffff;
}
.drug-body{
  position: relative;

  background: #ffffff;
}
.custom-tabs {
  display: flex;
  background-color: #ffffff; /* 背景颜色 */
  padding: 10px; /* 内边距 */
  border-radius: 8px;
}
.custom-tabs div {
  cursor: pointer;
  padding: 10px;
  /*border: none; !* 移除边框 *!*/
  border-radius: 2px;
  margin-right: 10px;
  background: #ffffff; /* 使用渐变背景 */
  color: rgba(25, 53, 80, 0.7);
  /*box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); !* 添加阴影效果 *!*/
  transition: background 0.3s; /* 添加过渡效果 */
  font-size: 18px;
}
.custom-tabs div.active-tab {
  background: #ffffff; /* 使用渐变背景 */
  color: rgba(25, 53, 80, 0.7);
  font-weight: bold;
}

/*设置竖线的样式*/
.tab-separator {
  border-left: 1.5px solid rgba(25, 53, 80, 1);
  height: 20px;
  font-weight: bold;
  margin-left: 25px;
}

/*设置组件名称*/
.component-name{
  text-align: left;
  margin: 20px 0 20px 20px;
  font-weight: bold;
  font-size: 23px;
  color: #2c3e50;
  text-shadow: #e1e1e1 0 0 1px;
  cursor: default;
}
</style>
