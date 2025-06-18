// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import axios from 'axios'
import api_  from './api'
import jsPDF from "jspdf";
import *as echarts from 'echarts'
import locale from 'element-ui/lib/locale/lang/en'
import store from './store/store';
import VueLazyload from 'vue-lazyload'




Vue.config.productionTip = false
Vue.use(ElementUI,{locale})
Vue.prototype.$http= axios
Vue.prototype.api=api_
axios.defaults.baseURL = api_.baseURL
Vue.prototype.$echarts =echarts
// 懒加载配置
Vue.use(VueLazyload,{
  preLoad: 1.3,
  error: 'http://tmliang.cn/pic/adi/homeimg/loading_error.webp',
  loading:'http://tmliang.cn/pic/adi/homeimg/loading_placeholder.webp',
  attempt:1 //每张图片最多加载一次
})


/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: { App },
  template: '<App/>'
})
