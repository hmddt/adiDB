<template>
  <div id="TF-gene">
    <div class="input-container">
      <!-- el-card1 and el-card2 placed side by side -->
<!--      <el-card class="el-card1">-->
<!--        <p class="TF-title1">TF-gene Network</p>-->
<!--        <p>Please enter the gene you are interested in below</p>-->
<!--        <label for="geneInput" class="input-label">Gene: </label>-->
<!--        <input-->
<!--          type="text"-->
<!--          id="geneInput"-->
<!--          v-model="gene"-->
<!--          placeholder="Enter Gene value"-->
<!--          class="input-field"/>-->
<!--        <el-button class="input-button" @click="networkinput">Input</el-button>-->
<!--      </el-card>-->

<!--      <el-card class="el-card2">-->
<!--        <p><strong>Function:</strong> This section generates related transcription factors and target gene regulatory networks based on the gene you input.</p>-->
<!--        <p><strong>Dataset:</strong> The dataset comes from the TRRUST database and currently only includes human species data.</p>-->
<!--      </el-card>-->
      <el-card class="tf-card">
        <div class="tf-header">
          <p class="tf-title">TF-gene Network</p>
          <p class="tf-subtitle">Please enter the gene you are interested in:</p>
        </div>

        <div class="tf-input-group">
          <label for="geneInput" class="tf-label">Gene: </label>
          <input
            type="text"
            id="geneInput"
            v-model="gene"
            placeholder="Enter Gene symbol"
            class="tf-input" />
          <el-button type="primary" class="hover-blue-btn" @click="networkinput">Input</el-button>
        </div>

        <div class="tf-hint">
          <p><strong>Function:</strong> This section generates transcription factor and target gene regulatory networks based on the gene you input.</p>
          <p><strong>Dataset:</strong> Based on the TRRUST database (Human data only).</p>
        </div>
      </el-card>

    </div>


    <div ref="chartContainer" class="chart-container"></div>
    <div v-show="testGeneData.allRelatedTFs && this.gene" class="el-table-tf">

      <div class="table-title-bar">
        <span class="info-text">Interaction Table of {{ this.gene }} Gene</span>
        <span class="download-link" @click="downloadTableData">Download</span>
      </div>

      <el-table
        :data="paginatedData"
        style="  width: 1600px;font-size: 16px; margin: -25px auto; border-radius: 5px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);"
        :header-cell-style="{ backgroundColor: '#245aa9', color: 'white' }"
      >
        <el-table-column type="expand"
        style="font-size: 16px;"
        >
          <template slot-scope="props">
            <el-form label-position="left" inline class="table-expand">
              <el-form-item label="TF">
                <span>{{ props.row.TF }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Target gene">
                <span>{{ props.row.Target_gene }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Function">
                <span>{{ props.row.Function }}</span>
              </el-form-item>
              <br>
              <el-form-item label="PMID">
                <span>{{ props.row.PMID }}</span>
              </el-form-item>
              <br>
              <el-form-item label="TF EntrezID">
                <span>{{ props.row.TF_Entrez }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Target gene EntrezID">
                <span>{{ props.row.Target_gene_Entrez }}</span>
              </el-form-item>
              <br>
            </el-form>
          </template>
        </el-table-column>
        <el-table-column label="TF" prop="TF"></el-table-column>
        <el-table-column label="Target_gene" prop="Target_gene"></el-table-column>
        <el-table-column label="Function" prop="Function"></el-table-column>
        <el-table-column label="PMID" prop="PMID"></el-table-column>
      </el-table>

      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        :page-sizes="[10, 20, 50, 100]"
        :page-size="pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="tablePageTotal"
        style="margin-top: 40px; display: flex; justify-content: center;">
      </el-pagination>
    </div>

    <!-- Network graph -->

  </div>
</template>

<script>
import * as XLSX from 'xlsx'
import * as echarts from 'echarts'; // Import ECharts
import { testByGene, filterDataByTF, transformData } from '../../../datajs/les-miserablestg';
import mountedAdiData from '../../../datajs/tfnetwork/mountedAdiNetwork.json';

export default {
  name: "TF-gene",
  data() {
    return {
      gene: '', // User input gene value
      result: [], // Filtered data
      testGeneData: {}, // Data fetched from testByGene function
      network: {}, // Data required for the network graph
      chart: null, // ECharts instance
      tablePageTotal: '', // Total number of entries for testGeneData
      currentPage: 1,
      pageSize: 10, // Number of entries per page
      paginatedData: [] // Data for current page
    };
  },
  mounted() {
    this.chart = echarts.init(this.$refs.chartContainer);
    this.network = mountedAdiData;
    this.testGeneData = {
      allRelatedTFMatches: [],  // 初始化为空
      allRelatedTFs: []
    };
    this.renderNetwork();
  },

  methods: {
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1; // Go back to first page when page size changes
      this.updatePaginatedData();
      console.log(`Items per page: ${val}`);
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.updatePaginatedData();
      console.log(`Current page: ${val}`);
    },
    updatePaginatedData() {
      const startIndex = (this.currentPage - 1) * this.pageSize;
      const endIndex = startIndex + this.pageSize;
      this.paginatedData = this.testGeneData.allRelatedTFMatches.slice(startIndex, endIndex);
    },

    async networkinput() {
      if (!this.gene || !this.gene.trim()) {
        this.$message.warning("Please enter a gene name.");
        return;
      }

      this.loading = true;
      try {
        const result = await testByGene(this.gene.trim());

        if (!result || !result.allRelatedTFMatches.length) {
          this.$message.warning(`No data found for gene "${this.gene}".`);
          this.gene = '';
          // this.testGeneData = { allRelatedTFMatches: [], allRelatedTFs: [] };
          // this.network = { nodes: [], links: [], categories: [] };
          // this.paginatedData = [];
          // this.tablePageTotal = 0;
          // this.renderNetwork();
          return;
        }

        this.testGeneData = result;
        this.tablePageTotal = result.allRelatedTFMatches.length;
        this.updatePaginatedData();
        this.network = transformData(result.allRelatedTFMatches);
        this.renderNetwork();

      } catch (err) {
        console.error("加载失败:", err);
        this.$message.error("Failed to fetch data.");
      } finally {
        this.loading = false;
      }
    },

    //下载表格数据
    downloadTableData() {
      if (!this.testGeneData.allRelatedTFMatches || !this.testGeneData.allRelatedTFMatches.length) {
        this.$message.warning("No data to export.");
        return;
      }

      const data = this.testGeneData.allRelatedTFMatches.map(item => ({
        TF: item.TF,
        Target_gene: item.Target_gene,
        Function: item.Function,
        PMID: item.PMID,
        TF_Entrez: item.TF_Entrez,
        Target_gene_Entrez: item.Target_gene_Entrez
      }));

      const worksheet = XLSX.utils.json_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, "TF-Gene Interactions");

      XLSX.writeFile(workbook, `${this.gene}_TF_Gene_Interactions.xlsx`);
    },


    renderNetwork() {
      if (!this.network || !this.network.nodes.length) {
        this.chart.clear();
        this.$message.warning(`No network data found for gene "${this.gene}".`);
        return;
      }
      const titleText = this.gene &&this.gene.trim()
        ? `${this.gene} Gene Network:`
        : 'Adipokines related TF network';

      const option = {
        title: {
          text: titleText,
          left: "left",
          top:"10px",
          textStyle: {
            fontSize:24,
            color: '#245aa9',   // 字体颜色
          },
        },
        tooltip: {
          trigger: 'item', // 显示节点和边的信息
          formatter: function (params) {
            if (params.dataType === 'edge') { // 如果是边
              return params.data.info; // 显示 info 字段内容
            }
            return `${params.data.name}`; // 如果是节点
          }
        },
        legend: {
          data: this.network.categories.map(c => c.name), // 图例的内容是节点的分类
          left: '10px', // 图例位置在左侧
          top: '60px', // 将图例放置在标题下方，调整这个值来控制距离
          // orient: 'horizontal', // 设置图例为横向排列
          orient: 'vertical', // 将图例改为垂直排列
          itemWidth: 20, // 设置图例项的宽度
          itemHeight: 20, // 设置图例项的高度
          textStyle: {
            fontSize: 16, // 设置图例文字的字体大小
            color: '#0d2946', // 设置图例文字的颜色，可以根据需求调整
          },
        },
        series: [
          {
            type: "graph",
            layout: "circular",  // 改为圆形布局
            circular: {
              rotateLabel: true  // 标签随节点旋转
            },
            data: this.network.nodes,
            links: this.network.links,
            categories: this.network.categories,
            roam: true,
            label: {
              show: true,
              position: "right"
            },
            lineStyle: {
              color: 'source',
              curveness: 0.3
            },
            emphasis: {
              focus: 'adjacency',
              lineStyle: {
                width: 2
              }
            }
          }
        ]

      };

      this.chart.setOption(option);
    },
  },
}
</script>

<style scoped>
#TF-gene {
  max-width: 1400px;
  margin: 0 auto;
  font-family: 'Segoe UI', Roboto, sans-serif;
  color: #333;
  background-color: #ffffff;
}

/* 主卡片 */
.tf-card {
  background-color: #ffffff;
  padding: 32px 40px;
  border-radius: 12px;
  border: 1px solid #dfe6ec;
  box-shadow: none;
  margin-bottom: 40px;
}

/* 标题区域 */
.tf-header {
  margin-top: -60px;
  margin-bottom: 18px;
  text-align: left;
}

.tf-title {
  font-size: 28px;
  font-weight: 700;
  color: #2a5eaa; /* 主蓝色 */
  margin-bottom: 10px;
}

.tf-subtitle {
  font-size: 18px;
  color: #444;
  font-weight: 500;
}


/* 输入区域 */
.tf-input-group {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 16px;
  margin-bottom: 20px;
}

.tf-label {
  font-size: 16px;
  font-weight: 600;
  color: #2a3f5f;
}

.tf-input {
  flex: 1;
  min-width: 240px;
  padding: 10px 14px;
  font-size: 16px;
  border: 1px solid #ccc;
  border-radius: 6px;
  transition: border-color 0.2s;
  background-color: #fafafa;
}

.tf-input:focus {
  outline: none;
  border-color: #2a5eaa;
  background-color: #fff;
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
  border-color: #1f4c90 !important;
}


/* 提示区 */
.tf-hint {
  font-size: 16.5px;
  text-align: left;
  font-weight: 500;
  line-height: 1.8;
  color: #2c3e50;
  background: #eaf3fc;
  padding: 18px 22px;
  border-left: 4px solid #2a5eaa;
  border-radius: 8px;
}


/* 图表容器 */
.chart-container {
  width: 97.2%; /* 设置容器的宽度 */
  height: 700px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin: 0 auto 40px auto; /* 控制垂直方向的距离 */
  padding: 20px; /* 给容器内部添加内边距 */
}

.table-title-bar{
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #245aa9;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
  padding: 15px;
}

.download-link:hover {
  color: #ffdd57;
}

/*font-size: 22px;*/
/*font-weight: 600;*/
/*align-items: center;*/
/*color: #fefeff;*/
/*padding: 15px;*/

.download-link {
  color: #ffffff;
  font-size: 20px;
  cursor: pointer;
  align-items: center;
  margin-top: -5px;
  margin-right: 10px;
  text-decoration: underline;
}

/* 表格样式优化 */
.el-table {
  border-radius: 10px;
  font-size: 14px;
}

.table-expand {
  background: #f9f9f9;
  border-radius: 10px;
  padding: 15px;
  font-size: 14px;
}

.table-expand .el-form-item {
  margin-bottom: 10px;
}

.table-expand .el-form-item label {
  font-weight: 500;
  color: #555;
}

.el-pagination {
  margin-top: 20px;
  justify-content: center;
}
.el-table-tf{
  background: white;
  text-align: left;
}
.info-text{
  font-size: 22px;
  font-weight: 600;
  align-items: center;
  color: #fefeff;
  padding: 15px;
}

</style>
