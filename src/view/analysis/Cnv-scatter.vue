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
      let data = [];
      let cancers = [];
      let genes = [];

      this.cnvList.forEach((cnv, i) => {
        cnv.dataList.forEach((value, j) => {
          data.push([j, i, value]);
        });
        cancers.push(cnv.cancer);
      });
      genes = [this.gene];  // 直接使用当前选中的基因


      this.$echarts.init(document.getElementById("cnv")).setOption({
        tooltip: { trigger: "item" },
        xAxis: {
          type: "category",
          data: cancers,  // 20 种疾病
        },
        yAxis: {
          type: "value",
        },
        series: [{
          name: this.gene,
          type: "scatter",
          data: this.cnvList.map(cnv => {
            // 每种疾病的 dataList 数据，转为小提琴图格式
            return cnv.dataList.map(value => [this.cnvList.indexOf(cnv), value]); // 数据点
          }).flat(),
          symbolSize: 4,
          itemStyle: {
            color: "rgba(0, 255, 255, 0.6)", // 点的颜色
          },
          tooltip: {
            formatter: function (params) {
              return `Value: ${params.value[1]}`;
            },
          },
        }, {
          name: this.gene,
          type: "violin",
          data: this.cnvList.map(cnv => {
            // 这里生成小提琴图的数据格式
            return {
              name: cnv.cancer,
              data: cnv.dataList,
            };
          }),
          itemStyle: {
            color: "rgba(0, 255, 255, 0.3)",
          },
          // 如果需要，你也可以自定义小提琴图的宽度和其他样式
        }],
      });

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

