<template>
  <div id="cnvall">
    <div>
      <!--对mrna表达介绍-->
      <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
        <br>
        <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Copy Number Variation
          </span>
          <i class="el-icon-question" style="color: #3a8ee6;cursor: pointer; /* 添加指针样式，表明是可交互的 */" @click="Showhelp = !Showhelp" @mouseenter="showTooltip" @mouseleave="hideTooltip"></i>
        </p>
        <div v-if="isTooltipVisible" :style="{ top: tooltipTop + 'px', left: tooltipLeft + 'px' }" class="tooltip">
          learn more about Copy Number Variation
        </div>
        <br>
        <div v-show="Showhelp" style="font-size: 13px;line-height: 1.5;color: #4d4d4d">
          <p>
            <span style="color: #e6903a"> > </span>
            <span>
            The function of this module is to analyse copy number variation of genes in pan-cancer.
          </span>
          </p>
        </div>
      </div>
    </div>
    <hr style="width: 1300px">
    <!--搜索表单-->
    <div style="margin: 20px; text-align: center">
      <span style="font-size: 16px">Gene:&nbsp&nbsp</span>
      <el-select
        v-model="gene"
        filterable
        remote
        placeholder="please enter gene symbol"
        :remote-method="remoteMethod"
        @change="getCnvData"
      >
        <!-- remote-method封装好的钩子函数。当用户在输入框中输入内容的时候，会触发这个函数的执行，
        把输入框对应的值作为参数带给回调函数，loading的意思就是远程搜索的时候等待的时间，即：加载中-->
        <el-option
          v-for="option in options"
          :label="option"
          :value="option"
          :key="option">
        </el-option>
      </el-select>
      <el-button type="primary" style="background-color: #2f2c23;font-weight: bold" @click="getCnvData">Click</el-button>
    </div>
    <div style="width: auto;height: 600px" id="cnv" class="chart" v-loading="loading"></div>
  </div>
</template>

<script>
import analysisCon1 from "./analysis-con1.vue";
import * as echarts from "echarts";
export default {
  name: "Methy",
  components: {
    analysisCon1,
  },
  data() {
    return {
      allGenes: [],
      options: [],
      gene: "LEP",
      cnvList: [],
      loading: false,
      Showhelp: false,
      isTooltipVisible: false,
      tooltipTop: 0,
      tooltipLeft: 0,
      cnacers:[],//测试癌症名称
    };
  },
  methods: {
    remoteMethod(query) {
      if (query !== "") {
        this.options = this.allGenes.filter((item) =>
          item.toLowerCase().includes(query.toLowerCase())
        );
      } else {
        this.options = [];
      }
    },
    getCnvData() {
      this.loading = true;
      this.$http.get("http://47.97.192.100:83/dzx/cnv/" + this.gene).then((res) => {
        this.cnvList = res.data;
        this.cnvInit();
        this.loading = false;
      });
    },
    cnvInit() {
      let cancers = [];  // X 轴
      let cnvData = [];  // Y 轴 (瀑布图数据)

      this.cnvList.forEach((cnv, i) => {
        cancers.push(cnv.cancer);
        cnvData.push(cnv.dataList[0]);  // 只显示当前选中基因的数据
      });

      let chart = echarts.init(document.getElementById("cnv"));

      chart.setOption({
        title: {
          text: `Copy Number Variation - ${this.gene}`,
          left: "center",
        },
        tooltip: {
          trigger: "axis",
          axisPointer: { type: "shadow" },
        },
        grid: {
          left: "5%",
          right: "5%",
          bottom: "10%",
          containLabel: true,
        },
        xAxis: {
          type: "category",
          data: cancers,
          axisLabel: { rotate: 45 },
        },
        yAxis: {
          type: "value",
          name: "CNV Value",
        },
        series: [
          {
            name: "CNV",
            type: "bar",
            data: cnvData.map((val) => ({
              value: val,
              itemStyle: {
                color: val > 0 ? "#4CAF50" : "#F44336", // 正数绿色，负数红色
              },
            })),
            label: {
              show: true,
              position: "top",
              formatter: "{c}",
            },
          },
        ],
      });

      window.addEventListener("resize", () => chart.resize());
    },
    showTooltip(event) {
      this.isTooltipVisible = true;
      this.tooltipTop = event.clientY + 10;
      this.tooltipLeft = event.clientX + 10;
    },
    hideTooltip() {
      this.isTooltipVisible = false;
    },
  },
  mounted() {
    this.$http.get("http://47.97.192.100:8090/adi/gene").then((res) => {
      this.allGenes = res.data;
    });
  },
};
</script>

<style scoped>
#cnvall{
  position: relative;
  width: 1400px;
  margin: 0 auto;
  background-color: #fcfcfc; /* 背景色，柔和 */
  border-radius: 8px; /* 圆角边框 */
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); /* 添加阴影 */
}

.tooltip {
  position: fixed; /* 使用 fixed 定位，可以使提示框跟随鼠标位置 */
  background-color: #ffffff;
  font-size: 12px;
  color: #4d4d4d;
  border: 1px solid #4d4d4d;
  padding: 2px;
}


</style>

