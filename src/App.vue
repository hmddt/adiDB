<template>
  <div id="app">

    <div>
      <!-- 顶部导航栏 -->
      <div v-if="$route.path ==='/home'" class="header-nav">
        <div class="nav-container">
          <!-- 左侧字母 Logo -->
          <div class="logo" >
            AdipokineDis
          </div>
          <div
            v-for="(item, index) in menuItems"
            :key="index"
            class="nav-item"
            :class="{'active': isActiveRoute(item)}"
            @mouseenter="showDropdown(index)"
            @mouseleave="hideDropdown"
          >
            <span
              v-if="item.action === 'email'"
              class="nav-link"
              @click="sendEmail"
            >
              <i class="el-icon-message "></i> Contact us
            </span>

            <!-- 普通链接 -->
            <router-link v-if="item.path" :to="item.path" class="nav-link">
              {{ item.name }}
            </router-link>
            <!-- 下拉菜单 -->
            <div v-else class="dropdown-wrapper">
              <span class="nav-link">{{ item.name }}</span>
              <div class="dropdown-menu" v-show="visibleDropdown === index">
                <div
                  v-for="(dropdown, idx) in item.dropdown"
                  :key="idx"
                  class="dropdown-item"
                  @click="loadComponent(dropdown.component)"
                >
                  {{ dropdown.name }}
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
      <div v-else class="header-nav" >
        <div class="nav-container">
          <div
            v-for="(item, index) in menuItems"
            :key="index"
            class="nav-item"
            :class="{'active': isActiveRoute(item)}"
            @mouseenter="showDropdown(index)"
            @mouseleave="hideDropdown"
          >
<!--            发送邮件-->

            <span
              v-if="item.action === 'email'"
              class="nav-link"
              @click="sendEmail"
            >
              <i class="el-icon-message "></i> Contact us
            </span>

            <!-- 普通链接 -->
            <router-link v-if="item.path" :to="item.path" class="nav-link">
              {{ item.name }}
            </router-link>
            <!-- 下拉菜单 -->
            <div v-else class="dropdown-wrapper">
              <span class="nav-link">{{ item.name }}</span>
              <div class="dropdown-menu" v-show="visibleDropdown === index">
                <div
                  v-for="(dropdown, idx) in item.dropdown"
                  :key="idx"
                  class="dropdown-item"
                  @click="loadComponent(dropdown.component)"
                >
                  {{ dropdown.name }}
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>

      <!-- 主内容区 -->
      <router-view  />

      <!-- 页脚 -->

      <guofoot style="width: 1400px;margin: 0 auto"></guofoot>
    </div>

  </div>
</template>

<script>

import guofoot from './view/footer.vue'


export default {
  name: 'App',
  data() {
    return {
      isAppReady: false, // 标识资源是否加载完毕
      menuItems: [
        { name: 'Home', path: '/home' },
        { name: 'Browse', dropdown: [
            { name: 'Gene', component: 'browser' },
            { name: 'ncRNA', component: 'NCRNAgene'},
            { name: 'Gene-Disease', component: 'disease' },
            // { name: 'Gene-Drug', component: 'drug' },
            { name: 'Dataset' , component: 'dataset'},

          ] },
        { name: 'Analysis', dropdown: [
            { name: 'Multiomics Analysis', component: 'analysis' },
            { name: 'Immune Analysis' , component: 'immune'},
            { name: 'Drug Analysis' , component: 'maind'},
            { name: 'Sequence Tools' , component: 'sequence'}

          ] },
        { name: 'Network', dropdown: [
            { name: 'TF-gene', component: 'TF' },
            { name: 'ncRNA-gene', component: 'ncRNA' },
            { name: 'Synthetic Lethality', component: 'sl' },
          ] },
        { name: 'Evolution', path: '/evolution1' },
        { name: 'Help', path: '/help' },
        { name: '',action: 'email'  },//contact
      ],
      geneDiseaseData:[],
      geneDrugData:[],
      datasetData:[],
      visibleDropdown: null,
    };
  },
  components:{
    guofoot
  },
  async mounted() {
    try {
      const [geneDisease, geneDrug, dataset] = await Promise.all([
        import('../datajs/gene-disData.json'),
        import('../datajs/gene-drugData.json'),
        import('../datajs/Obesity_dataset.json'),
      ]);
      this.geneDiseaseData = geneDisease.default;
      this.geneDrugData = geneDrug.default;
      this.datasetData = dataset.default;
      console.log("所有资源加载完成 ");
    } catch (error){
      console.error("资源加载失败:", error);
    }
    // this.loadAllResources();
  },
  methods: {
    // async loadAllResources() {
    //   try {
    //     // 模拟所有模块资源的异步加载
    //     await Promise.all([
    //       this.loadModule('browser'),
    //       this.loadModule('disease'),
    //       this.loadModule('drug'),
    //       this.loadModule('dataset'),
    //       this.loadModule('analysis'),
    //       this.loadModule('TF'),
    //       this.loadModule('ncRNA'),
    //       this.loadModule('sl'),
    //     ]);
    //     this.isAppReady = true; // 所有资源加载完成
    //   } catch (error) {
    //     console.error('资源加载失败:', error);
    //   }
    // },
    // loadModule(moduleName) {
    //   return new Promise((resolve) => {
    //     // 模拟异步模块加载，实际场景可以是 API 请求或者动态 import()
    //     setTimeout(() => {
    //       console.log(`${moduleName} 模块已加载`);
    //       resolve();
    //     }, 500); // 模拟每个模块耗时 500ms
    //   });
    // },
    loadComponent(componentName) {
      this.$router.push('/' + componentName);
    },
    showDropdown(index) {
      this.visibleDropdown = index;
    },
    hideDropdown() {
      this.visibleDropdown = null;
    },
    isActiveRoute(item) {
      if (item.path) {
        // 如果有 path，检查是否是当前路由
        return this.$route.path.startsWith(item.path);
      } else if (item.dropdown) {
        // 如果是下拉菜单，检查下拉菜单的任何子项是否匹配当前路由
        return item.dropdown.some(dropdown => this.$route.path.includes(dropdown.component));
      }
      return false;
    },
    sendEmail() {
      // 定义邮件的基本信息
      const email = "tmliang@njnu.edu.cn"; // 收件人邮箱
      const subject = "About AdipokineDis"; // 邮件主题
      // const body = ""; // 邮件正文

      // 构建mailto链接
      // 跳转到邮件客户端
      window.location.href = `mailto:${email}?subject=${encodeURIComponent(subject)}`;
    },

  },
};
</script>

<style>
/* 全局样式 */
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  min-height: 100vh;
  color: #2c3e50;
  margin-top: -10px;
  text-align: center;
  background-image: url("assets/backimg6.png");
  background-size: cover;      /* 关键：图片拉伸至完全覆盖容器 */
  background-position: center; /* 图片居中 */
  background-repeat: no-repeat; /* 不重复 */
  background-attachment: fixed; /* 可选：固定背景不随滚动移动 */
}

::-webkit-scrollbar {
  display: none;}

/* 禁用插入符（光标）显示 */
body, #app, div, span, p {
  caret-color: transparent;
}

/* 排除输入元素 */
input, textarea, [contenteditable] {
  caret-color: auto !important;
}


/* 顶部导航栏样式 */
.header-nav {
  position: relative;
  width: 1400px;
  height: 60px;
  align-items: center;
  margin:  0 auto;
  border-bottom-left-radius: 5px;
  border-bottom-right-radius: 5px;
  background: linear-gradient(to top, #172f5b, #112446, #172f5b);
  /*background-image: url("./assets/backimg1.png");*/
  /*background: linear-gradient(to right, #f5faff, #f9f5ff); !* 非常浅的淡蓝到淡紫 *!  padding: 10px 0;*/
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
  z-index: 999;
}

.header-nav::after{
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 60px;
  background-image: url("./assets/backimg51.png");
  border-bottom-left-radius: 5px;
  border-bottom-right-radius: 5px;
  background-size: cover;
  background-position: center;
  opacity: 0.6; /* 设置透明度 */
  z-index: -1; /* 让背景层在内容后面 */
}

.nav-container {
  display: flex;
  height: 66px;
  justify-content: center;
}

.logo {
  font-size: 24px;
  margin-right: 360px;
  margin-top: 27px;
  font-weight: bold;
  font-style: oblique;
  color: white;
  cursor: pointer;
  /*font-family: 'STHupo', cursive; !* 应用艺术字体 *!*/
}
.nav-item {
  position: relative;
  cursor: pointer;
  margin-top: 26px;
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
}

.nav-link {
  font-size: 21px;
  font-weight: bold;
  text-decoration: none;
  color: #ffffff;
  padding: 10px 15px;
  transition: color 0.3s, border-bottom 0.3s;
}

.nav-link:hover {
color: #f6f6f6;
  height: 66px;

}

/* 下拉菜单样式 */
.dropdown-wrapper {
  position: relative;
}

.dropdown-menu {
  position: absolute;
  top: 35px;
  left: 0;
  background: #ffffff;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  z-index: 999;
}

.dropdown-item {
  padding: 10px 15px;
  cursor: pointer;
  text-align: left;
  white-space: nowrap;
  font-size: 16px;
  color: #2c3e50;
  transition: background 0.3s, color 0.3s;
}

.dropdown-item:hover {
  background: #c1d8ef;
  color: #2738e8;

}

/* 激活的导航栏项 */
.nav-item.active .nav-link {
  color: #363636;
  background-color: #ffffff;
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;

}

</style>
