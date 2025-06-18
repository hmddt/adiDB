<template>
  <div id="cnvall">
    <div>
      <!-- mRNA 表达介绍 -->
      <div style="text-align: left; margin-left: 60px; margin-top: 20px">
        <br>
        <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Copy Number Variation</span>
          <el-tooltip content="Learn more about Copy Number Variation" placement="top">
            <i class="el-icon-question" style="color: #3a8ee6; cursor: pointer" @click="Showhelp = !Showhelp"></i>
          </el-tooltip>
        </p>
        <br>
        <div v-show="Showhelp" class="help-text">
          <p>
            <span style="color: #e6903a"> > </span>
            The function of this module is to analyse copy number variation of genes in pan-cancer.
          </p>
        </div>
      </div>
    </div>

    <hr style="width: 1300px" />

    <!-- 搜索区域 -->
    <div class="search-panel">
      <span class="label">Gene:</span>
      <el-select
        v-model="gene"
        filterable
        remote
        placeholder="please enter gene symbol"
        :remote-method="remoteMethod"
        style="width: 240px"
      >
        <el-option v-for="option in options" :label="option" :value="option" :key="option" />
      </el-select>
      <el-button type="primary" class="hover-blue-btn" @click="getCnvData">Click</el-button>
    </div>

    <!-- 图表展示区域 -->
    <div id="cnv" class="chart" v-loading="loading" />
  </div>
</template>

<script>
import * as echarts from "echarts";

export default {
  name: "CopyNumberVariation",
  data() {
    return {
      allGenes: [],
      options: [],
      gene: "LEP",
      cnvList: [],
      loading: false,
      Showhelp: false,
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
      this.$http.get(`http://47.97.192.100:83/dzx/cnv/${this.gene}`).then((res) => {
        this.cnvList = res.data;
        this.renderChart();
        this.loading = false;
      });
    },
    renderChart() {
      const cancers = [];
      const scatterData = [];

      this.cnvList.forEach((cnv, i) => {
        cancers.push(cnv.cancer);
        cnv.dataList.forEach((value) => {
          scatterData.push({
            name: cnv.cancer,
            value: [cnv.cancer, value],
          });
        });
      });

      const dom = document.getElementById("cnv");
      echarts.dispose(dom);
      const chart = echarts.init(dom);

      chart.setOption({
        title: {
          text: `Copy Number Variation - ${this.gene}`,
          left: "center",
        },
        tooltip: {
          trigger: "item",
          formatter: (params) => `Cancer: ${params.name}<br>CNV: ${params.value[1]}`,
        },
        grid: {
          left: "5%",
          right: "5%",
          bottom: "15%",
          containLabel: true,
        },
        xAxis: {
          type: "category",
          data: cancers,
          axisLabel: {
            rotate: 45,
            fontSize: 12,
            interval: 0,
          },
          axisTick: {
            alignWithLabel: true,
          },
        },
        yAxis: {
          type: "value",
          name: "CNV Value",
        },
        visualMap: {
          min: -2,
          max: 2,
          dimension: 1,
          calculable: true,
          orient: "horizontal",
          left: "center",
          bottom: 0,
          inRange: {
            color: ["#F44336", "#b78e41", "#4CAF50"], // 负 - 中性 - 正
          },
        },
        series: [
          {
            name: "CNV",
            type: "scatter",
            data: scatterData,
            symbolSize: 8,
            label: {
              show: false,
            },
          },
        ],
      });

      window.addEventListener("resize", () => chart.resize());
    },
  },
  mounted() {
    this.$http.get("http://47.97.192.100:8090/adi/gene").then((res) => {
      this.allGenes = res.data;
    });
    this.getCnvData();
  },
};
</script>

<style scoped>
#cnvall {
  position: relative;
  width: 1400px;
  margin: 0 auto;
  background-color: #fcfcfc;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.title-text {
  font-weight: bold;
  font-size: 24px;
  color: #3a8ee6;
}

.help-text {
  font-size: 13px;
  line-height: 1.5;
  color: #4d4d4d;
  margin-top: 10px;
}

.search-panel {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin: 30px 0;
}

.label {
  font-size: 16px;
}

.chart {
  width: auto;
  height: 600px;
  transition: opacity 0.5s ease;
}

.hover-blue-btn {
  background-color: #2a5eaa;
  border-color: #2a5eaa;
  color: #fff;
  font-weight: 600;
  padding: 10px 18px;
  border-radius: 6px;
  font-size: 15px;
}

.hover-blue-btn:hover {
  background-color: #1f4c90 !important;
  color: #ffffff;
  border-color: #1f4c90 !important;
}
</style>
