<template>
  <div id="wordCloud2">

    <div ref="keywords" style="height: 500px;width: 1400px"></div>
<!--    <pre>{{ wordCloudData }}</pre>-->
  </div>
</template>

<script>
import { calculateKeywordFrequencies } from '../../../datajs/wordclouddata.js';
require("echarts-wordcloud"); // 引入 wordCloud 插件


export default {
  name: "wordCloud2",
  props: {
    // 数据源由父组件传入
    sourceData: {
      type: Array,
      required: true,
    },
    // 处理好后的数据源传入
    resultData:{
      type: Array,
      required: true,
    },
    // 可选标题由父组件传入
    title: {
      type: String,
      default: "Word Cloud Data",
    }
  },
  data() {
    return {
      wordCloudData: {}, // 处理后的词云数据
      wordCloud:{}, //筛选后的词云数据，筛选条件 vlaue>5
    };
  },
  watch: {
    // 监听 sourceData 的变化
    sourceData: {
      handler(newData) {
        this.processData(newData, 'sourceData');
      },
      immediate: true, // 初始化时立即调用
    },
    // 监听 resultData 的变化
    resultData: {
      handler(newData) {
        this.processData(newData, 'resultData');
      },
      immediate: true, // 初始化时立即调用
    },
  },
  mounted() {
    this.$nextTick(()=>{
      this.initEchart()
    })
  },
  methods: {
    processData(originalData, dataType) {
      let processedData = [];

      if (dataType === 'sourceData') {
        // 处理原始数据
        processedData = calculateKeywordFrequencies(originalData);
      } else if (dataType === 'resultData') {
        // 直接使用 resultData
        processedData = originalData;
      }

      // 过滤掉 value <= 10 的数据
      this.wordCloud = processedData.filter(item => item.value > 10);

      // 如果 ECharts 已初始化，则更新图表数据
      if (this.myChart) {
        this.updateChart();
      }
    },
    initEchart() {
      const el = this.$refs.keywords;
      if (!el) {
        console.error("Echart container not found!");
        return;
      }

      const echarts = require("echarts");
      this.myChart = echarts.init(el);

      this.updateChart(); // 初始数据加载
    },

    updateChart() {
      const colorList = [
        '#2a5eaa', '#3a8ee6', '#66b1ff', '#5b9bd5', '#3498db',
        '#9b59b6', '#af7ac5', '#2980b9', '#16a085', '#2ecc71',
        '#e67e22', '#f39c12', '#e74c3c', '#f56c6c', '#fece5b',
        '#34495e', '#1abc9c', '#c0392b', '#8e44ad', '#7f8c8d'
      ];



      const option = {
        tooltip: {
          show: true,
        },
        series: [
          {
            type: "wordCloud",  //指定图标类型
            gridSize: 30,   //控制单词之间最小间隔，数值越大间隔越大
            sizeRange: [20, 50],  //字体大小设置 最小范围到最大范围
            rotationRange: [0, 0],   //旋转角度 ， 0,0 代表全部水平排列，无旋转
            width: "1400", //词云图的宽度
            height: "95%",  //词云图的高度
            textStyle: {
              color: () => colorList[Math.floor(Math.random() * colorList.length)],
            }, // 每个单词的颜色 随机旋转
            data: this.wordCloud, // 更新的数据
          },
        ],
      };

      // 更新图表
      this.myChart.setOption(option);
      this.myChart.off('click'); // 防止多次绑定
      this.myChart.on('click', (params) => {
        const keyword = params.name;
        this.$emit('word-clicked', keyword);
      });
    }
  },
};
</script>

<style scoped>
/* 样式根据需求优化 */
</style>
