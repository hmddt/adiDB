<template>
  <div id="methylation">
    <div>
      <!--对mrna表达介绍-->
      <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
        <br>
        <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">DNA Methylation
          </span>
          <i class="el-icon-question" style="color: #3a8ee6;cursor: pointer; /* 添加指针样式，表明是可交互的 */" @click="Showhelp = !Showhelp" @mouseenter="showTooltip" @mouseleave="hideTooltip"></i>
        </p>
        <div v-if="isTooltipVisible" :style="{ top: tooltipTop + 'px', left: tooltipLeft + 'px' }" class="tooltip">
          learn more about DNA Methylation
        </div>
        <br>
        <div v-show="Showhelp" style="font-size: 13px;line-height: 1.5;color: #4d4d4d">
          <p>
            <span style="color: #e6903a"> > </span>
            <span>
            The function of this module is to analyse the methylation of genes in pan-cancer..
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
        @change="getMethyByGene"
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
      <el-button type="primary" class="hover-blue-btn" @click="getMethyByGene">Click</el-button>
    </div>
    <div v-loading="loading" style="width: auto;height: 600px" id="methy" class="chart"></div>
  </div>
</template>

<script>
import analysisCon1 from "./analysis-con1.vue";
  export default {
    name: "Methy",
    components:{
      analysisCon1
    },
    data() {
      return {
        methyList: [],
        allGenes: [],
        options: [],
        // gene and cancer
        gene: 'LEP',
        loading:false,
        Showhelp :false,//控制div块的显示和隐藏
        isTooltipVisible :false,//问号鼠标移入
        tooltipTop: 0, // 提示框距离顶部的距离
        tooltipLeft: 0 // 提示框距离左侧的距离
      }
    },
    methods: {
      // 模糊搜索
      remoteMethod(query) {
        // 如果用户输入内容了，就发请求拿数据，远程搜索模糊查询
        if (query !== "") {
          this.options = this.allGenes.filter((item) => {
            // 大于-1说明只要有就行，不论是不是开头也好，中间也好，或者结尾也好
            return item.toLowerCase().indexOf(query.toLowerCase()) > -1
          })
        } else {
          this.options = [];
        }
      },
      getMethyByGene() {
        this.loading = true;
        this.$http.get(this.api.dzxURL + '/methy/' + this.gene).then(res => {
          this.methyList = res.data;
          this.methyInit();
          this.show = true;
          this.loading=false;
        })
      },
      methyInit() {
        let data = [];
        let cancers = [];
        for (let i = 0; i < this.methyList.length; i++) {
          let methy = this.methyList[i];
          data.push(methy.dataList);
          cancers.push(methy.cancer);
        }
        this.$echarts.init(document.getElementById('methy')).setOption({
            dataset: [
              {
                source: data
              },
              {
                transform: {
                  type: 'boxplot',
                  config: {
                    itemNameFormatter: function (param) {
                      return cancers[param.value];
                    }
                  }
                }
              },
              {
                fromDatasetIndex: 1,
                fromTransformResult: 1
              }
            ],
            title: [
              {
                text: 'DNA Methylation',
                left: 'center'
              },
            ],
            tooltip: {
              trigger: 'item',
              axisPointer: {
                type: 'shadow'
              }
            },
            grid: {
              left: '10%',
              right: '10%',
              bottom: '10%'
            },
            xAxis: {
              type: 'category',
              name: 'Cancer Type',
              nameGap: 40,
              nameLocation: "middle",
              nameTextStyle: {
                color: '#000',
                fontSize: 16,
              },
              axisLabel: {
                interval: 0,
                rotate: 40
              }
            },
            yAxis: {
              type: 'value',
              name: 'Methylation Beta Value',
              nameRotate: 90,
              nameGap: 40,
              nameLocation: "middle",
              nameTextStyle: {
                color: '#000',
                fontSize: 16,
              },
              show: true,
              splitArea: {
                show: true
              }
            },
            series: [
              {
                symbolSize: 3,
                name: 'boxplot',
                type: 'boxplot',
                datasetIndex: 1,
              },
              {
                name: 'outlier',
                type: 'scatter',
                datasetIndex: 2
              }
            ]
          }
        )
      },
      showTooltip(event) {
        this.isTooltipVisible = true;
        this.tooltipTop = event.clientY + 10; // 将提示框放置在鼠标位置下方10像素
        this.tooltipLeft = event.clientX + 10; // 将提示框放置在鼠标位置右侧10像素
      },
      // 鼠标移出时隐藏提示框
      hideTooltip() {
        this.isTooltipVisible = false;
      },
    },
    mounted() {
      // 获取长寿基因列表
      this.$http.get('http://47.97.192.100:8090/adi/gene').then(res => {
        this.allGenes = res.data;
      });
      this.getMethyByGene();
    }
  }
</script>
<style scoped>
#methylation{
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
