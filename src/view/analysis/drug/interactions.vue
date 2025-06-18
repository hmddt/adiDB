<template>
<div class="Interactions">
  <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
    <br>
    <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Drug Interactions Analysis
          </span>
    </p>
  </div>
  <div style="margin: 20px;text-align: center">
    <el-form :inline="true" class="demo-form-inline">
      <span style="font-weight: bold;margin-right: 20px">Gene :</span>
      <el-select
        v-model="gene"
        filterable
        remote
        placeholder="please enter gene symbol"
        :remote-method="remoteMethod"
        :loading="loading">
        <!-- remote-method封装好的钩子函数。当用户在输入框中输入内容的时候，会触发这个函数的执行，
        把输入框对应的值作为参数带给回调函数，loading的意思就是远程搜索的时候等待的时间，即：加载中-->
        <el-option
          v-for="option in options"
          :label="option"
          :value="option"
          :key="option">
        </el-option>
      </el-select>
      <el-button type="primary" class="hover-blue-btn"  @click="GetGeneData">Click</el-button>
    </el-form>
  </div>

  <div class="Interactions-result">
    <div v-show="shouldShowChart" style="margin-left: 100px">
      <div ref="chartContainer" class="chart-container"></div>
    </div>
<!--    结果列-->
    <div style="margin-left: 100px">
      <div>
        <p>
          <span style="font-weight: bold;font-size: 20px">Interaction Results</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <span style="font-size: 14px">{{this.tablePageTotal}} total results</span>
        </p>
        <el-table
          :data="paginatedData"
          border
          style="width: 1200px;min-height: 530px"
          empty-text="No Data"
          :header-cell-style="{ backgroundColor: '#fff', color: '#245aa9' }"
        >
          <el-table-column
            prop="gene_name"
            label="Gene"

          >
          </el-table-column>
          <el-table-column
            prop="drug_name"
            label="Drug"
            width="230"
          >
          </el-table-column>
          <el-table-column
            prop="interaction_source_db_name"
            label="Source"
            width="180"
          >
          </el-table-column>
          <el-table-column
            prop="interactionScore"
            label="Interaction Score"
            width="200"
          >
          </el-table-column>
          <el-table-column
            prop="approved"
            label="Approved"
            width="150"
          >
            <template slot-scope="scope">
              <span v-if="scope.row.approved === 'TRUE'" >✔️</span>
            </template>
          </el-table-column>

          <el-table-column prop="immunotherapy" label="Immunotherapy" width="150">
            <template slot-scope="scope">
              <span v-if="scope.row.immunotherapy === 'TRUE'">✔️</span>
            </template>
          </el-table-column>

          <el-table-column prop="anti_neoplastic" label="Anti Neoplastic" width="150">
            <template slot-scope="scope">
              <span v-if="scope.row.anti_neoplastic === 'TRUE'">✔️</span>
            </template>
          </el-table-column>
        </el-table>

        <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="currentPage"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="tablePageTotal"
          style="margin-top: 20px; display: flex; justify-content: center;">
        </el-pagination>
      </div>


    </div>

  </div>

</div>
</template>

<script>
import * as echarts from "echarts";

export default {
  name: "interactions",
  data(){
    return{
      gene:'LEP',
      tableData:'',
      options: [],
      allGenes:'',
      loading:false,
      tablePageTotal: '', // 分页组件
      currentPage: 1,
      pageSize: 10, // 分页组件
      testGeneData:{},//表内数据
    }
  },
  methods:{
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

    GetGeneData(){
      const searchGene = this.gene;
      this.testGeneData = '';
      this.tableData = '';
      this.currentPage = 1;
      this.$http.get("http://47.97.192.100:8090/DrugInteractions/Gene/"+searchGene).then(res=>{
        const sortedData = res.data.sort((a, b) => {
          return Number(b.interactionScore) - Number(a.interactionScore);
        });
        this.tableData = sortedData;
        this.tablePageTotal = sortedData.length; // 设置总数用于分页
        this.renderNetwork();

      })
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1; // Go back to first page when page size changes
      console.log(`Items per page: ${val}`);
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      console.log(`Current page: ${val}`);
    },
    renderNetwork() {
      try {
        // 1. 使用ref获取DOM容器
        const chartContainer = this.$refs.chartContainer;
        if (!chartContainer) {
          console.error('图表容器未找到');
          return;
        }

        // 2. 检查数据有效性
        if (!this.tableData || this.tableData.length === 0) {
          console.warn('没有可用的图表数据');
          return;
        }

        // 3. 销毁旧图表实例
        const existingChart = echarts.getInstanceByDom(chartContainer);
        if (existingChart) {
          existingChart.dispose();
        }

        // 4. 初始化新图表
        const myChart = echarts.init(chartContainer);

        // 5. 处理数据
        const sortedData = [...this.tableData].sort((a, b) =>
          parseFloat(b.interactionScore) - parseFloat(a.interactionScore)
        );

        const drugNames = sortedData.map(item => item.drug_name);
        const scores = sortedData.map(item => parseFloat(item.interactionScore));

        // 6. 配置项（适配容器尺寸）
        const option = {
          title: {
            text: `${this.geneName || 'Gene'} interaction score with drug`,
            left: 'center',
            top: 10
          },
          tooltip: {
            trigger: 'axis',
            confine: true,  // 防止tooltip超出容器
            formatter: params => {
              const item = sortedData[params[0].dataIndex];
              return `
            <div style="max-width: 300px">
              <strong>${item.drug_name}</strong><br/>
              Score: ${item.interactionScore}<br/>
              approved: ${item.approved === 'TRUE' ? '✓ approved' : '× Unapproved'}<br/>
              Data source: ${item.interaction_source_db_name}
            </div>
          `;
            }
          },
          grid: {
            top: 60,
            left: '3%',
            right: '4%',
            bottom: 80,  // 为缩放控件留空间
            containLabel: true
          },
          xAxis: {
            type: 'category',
            data: drugNames,
            axisLabel: {
              rotate: 45,
              interval: 0,
              fontSize: 10,
              formatter: value => {
                // 移动端显示更短的名称
                const isMobile = window.innerWidth < 768;
                return isMobile ? value.substring(0, 8) + '...' :
                  value.length > 20 ? value.substring(0, 15) + '...' : value;
              }
            }
          },
          yAxis: {
            type: 'value',
            name: 'Interaction Score',
            nameLocation: 'middle',
            nameGap: 30
          },
          series: [{
            type: 'line',
            data: scores,
            symbol: 'circle',
            symbolSize: 8,
            lineStyle: { width: 2 },
            itemStyle: { borderWidth: 1 },
            emphasis: { scale: 1.5 }  // 悬停时放大符号
          }],
          dataZoom: [{
            type: 'slider',
            height: 20,
            bottom: 30,
            start: 0,
            end: Math.min(20, drugNames.length) / drugNames.length * 100
          }, {
            type: 'inside'
          }]
        };

        // 7. 渲染图表
        myChart.setOption(option);

        // 8. 响应式处理
        const resizeChart = () => {
          myChart.resize({
            width: chartContainer.clientWidth,
            height: chartContainer.clientHeight
          });
        };

        // 初始调整尺寸
        resizeChart();

        // 监听容器尺寸变化（使用ResizeObserver）
        this.resizeObserver = new ResizeObserver(resizeChart);
        this.resizeObserver.observe(chartContainer);

        // 9. 返回清理函数
        return () => {
          if (this.resizeObserver) {
            this.resizeObserver.disconnect();
          }
          myChart.dispose();
        };

      } catch (error) {
        console.error('渲染图表时出错:', error);
        return null;
      }
    }
    },
  computed: {
    paginatedData() {
      const start = (this.currentPage - 1) * this.pageSize
      const end = start + this.pageSize
      return this.tableData.slice(start, end)
    },
    shouldShowChart() {
      // 根据实际数据类型调整判断逻辑
      return Array.isArray(this.paginatedData)
        ? this.paginatedData.length > 0
        : Boolean(this.paginatedData);
    }
  },

  mounted() {
    this.$http.get('http://47.97.192.100:8090/adi/gene').then(res => {
      this.allGenes = res.data;
    });
    this.chart = echarts.init(this.$refs.chartContainer);
    this.GetGeneData();

  }
}
</script>

<style scoped>
.Interactions{
  position: relative;
  width: 1400px;
  margin: 0 auto;
  border-radius: 8px; /* 圆角边框 */
  text-align: left;
}

.Interactions-result{

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

.chart-container {
  width: 1200px;
  height: 500px; /* 默认高度 */
  min-height: 300px;
}
</style>
