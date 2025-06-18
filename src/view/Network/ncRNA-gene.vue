<template>
  <div id="ncRNA-gene">
    <div class="input-container">
      <!-- el-card1 and el-card2 placed side by side -->
      <el-card class="el-card1">
        <p class="nc-title1">ncRNA-mRNA Network</p>
        <div class="form-group">
          <label for="datasetSelect" class="input-label">Dataset: </label>
          <el-select
            id="datasetSelect"
            v-model="dataset"
            placeholder="Please select a dataset"
            class="input-field1"
            style="width: 200px;">
            <el-option
              label="miR-gene-miRTarBase"
              value="miR-gene-miRTarBase">
            </el-option>
          </el-select>
        </div>

        <div class="form-group">
          <label for="speciesSelect" class="input-label"> Species: </label>
          <el-select
            id="speciesSelect"
            v-model="species"
            placeholder="Please select species">
            <el-option
              v-for="item in speciesData"
              :key="item.value"
              :label="item.value"
              :value="item.value">
              <span style="float: left; color: #8492a6; font-size: 13px ">{{item.value}}</span>

            </el-option>
          </el-select>
        </div>
        <div class="form-group">
          <!-- 单选框 -->
          <div class="radio-group">
            <el-radio v-model="selectedOption" label="allgene"><span style="font-size: 16px;font-weight: bold">all gene</span></el-radio>
            <el-radio v-model="selectedOption" label="gene"><span style="font-size: 16px;font-weight: bold">gene</span></el-radio>
            <el-radio v-model="selectedOption" label="ncrna"><span style="font-size: 16px;font-weight: bold">ncRNA</span></el-radio>
            <!-- 输入框（仅在选择 'gene' 时显示） -->
            <div class="input-group" style="margin-left: -10px">
              <input
                type="text"
                id="geneInput"
                v-model="gene"
                placeholder="Enter Gene symbol"
                class="input-field"
                :disabled="selectedOption === 'allgene'"
              />
            </div>
          </div>


        </div>
        <el-button class="hover-blue-btn" type="primary" @click="networkinput">Search</el-button>
        <el-button class="hover-blue-btn" type="primary" @click="downloadresult">Download Result</el-button>


      </el-card>

      <el-card class="el-card2">
        <p><strong>Function:</strong> This section generates the ncRNA-gene network based on the ncRNA or gene you input.</p>
        <p><strong>Dataset:</strong> </p>
        <p>
        <span style="font-weight: bold">miR-gene-miRTarBase:</span> The dataset is sourced from the miRTarBase database and includes high-confidence association information between <span style="font-style: italic">21 sapiens</span> miRNA and target genes.
        </p>
      </el-card>
    </div>
    <div v-if="testGeneData.length" class="el-table-nc">
      <!-- Table -->
      <el-table
        :data="paginatedData"
        style="width: 1600px; margin: 20px auto; border-radius: 5px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);"
        :header-cell-style="{ backgroundColor: '#fff', color: '#245aa9' }">
        <el-table-column type="expand" >
          <template v-slot="props">
            <el-form label-position="left" inline class="table-expand">
              <el-form-item label="miRTarBase ID">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row['miRTarBase ID'] }}</span>
              </el-form-item>
              <br>
              <el-form-item label="miRNA">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row.miRNA }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Species (miRNA)">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row['Species (miRNA)'] }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Target Gene">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row['Target Gene'] }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Target Gene (Entrez ID)">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row['Target Gene (Entrez ID)'] }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Experiments">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row.Experiments }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Support Type">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row['Support Type'] }}</span>
              </el-form-item>
              <br>
              <el-form-item label="References (PMID)">
                <span style=" color: #4f5052;font-weight: bold">{{ props.row['References (PMID)'] }}</span>
              </el-form-item>

            </el-form>
          </template>
        </el-table-column>
        <el-table-column label="miRNA" prop="miRNA"></el-table-column>
        <el-table-column label="Target Gene" prop="Target Gene"></el-table-column>
        <el-table-column label="Species" prop="Species (miRNA)"></el-table-column>
        <el-table-column label="Validation methods">
            <el-table-column
              label="Reporter assay"
              width="140px">
              <template v-slot="scope">
                <span v-if="scope.row.Experiments && /reporter assay/i.test(scope.row.Experiments)">✔️</span>
              </template>
            </el-table-column>
            <el-table-column
              label="Western blot"
              width="140px">
              <template v-slot="scope">
                <span v-if="scope.row.Experiments && scope.row.Experiments.includes('Western blot')">✔️</span>
              </template>
            </el-table-column>
            <el-table-column
              label="qRT-PCR"
              width="140px">
              <template v-slot="scope">
                <span v-if="scope.row.Experiments && scope.row.Experiments.includes('qRT-PCR')">✔️</span>
              </template>
            </el-table-column>
        </el-table-column>
        <el-table-column label="Sum" prop="score" width="100px">
          <template v-slot="scope">
            <span style="font-weight: bold; color: #409EFF">{{ scope.row.score }}</span>
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
    <!-- Network graph -->
    <div ref="chartContainer" class="chart-container"></div>
  </div>
</template>

<script>
import * as echarts from "echarts";
import  { TgNcRNA,mirRNATg,transformData } from '../../../datajs/ncRNA-gene'
import mountedNodeData from '../../../datajs/ncRNAnetwork/matchedNodeNetwork.json'
export default {
  name: "ncRNA-gene",
  data(){
    return{
      dataset:'',//选择的数据集
      selectedOption: 'allgene', // 默认选中 '所有基因'
      gene:'',//填入的基因
      species:'' , //选中物种信息
      result: [], // Filtered data
      testGeneData: {}, // Data fetched from testByGene function
      network: {}, // Data required for the network graph
      chart: null, // ECharts instance
      tablePageTotal: '', // 分页组件
      currentPage: 1,
      pageSize: 10, // 分页组件
      paginatedData: [], // 分页组件
      speciesData:[{
        value: 'Mus musculus',
        label:'10090', //小鼠
      },{
        value: 'Homo sapiens',
        label:'9606', //人类
      },{
        value: 'Drosophila melanogaster',
        label:'7227',  //黑腹果蝇
      },{
        value: 'Rattus norvegicus',
        label:'10116', //褐家鼠
      },{
        value: 'Caenorhabditis elegans',
        label:'6239' ,//秀丽隐杆线虫
      },{
        value: 'Danio rerio',
        label:'7955' ,//斑马鱼
      },{
        value: 'Arabidopsis thaliana',
        label:'3702', //拟界南
      },{
        value: 'Sus scrofa',
        label:'9823', //家猪
      },{
        value: 'Gallus gallus',
        label:'9031', //家鸡
      },{
        value: 'Epstein Barr virus',
        label:'10376', //埃博斯坦-巴尔病毒
      },{
        value: 'Bos taurus',
        label:'9913', //家牛
      },{
        value: 'Cricetulus griseus',
        label:'10029',//中国仓鼠
      },{
        value: 'Bombyx mori',
        label:'7091', //家蚕
      },{
        value: 'Taeniopygia guttata',
        label:'59729', //斑胸草雀
      },{
        value: 'Xenopus laevis',
        label:'8355', //非洲爪蟾
      },{
        value: 'Xenopus tropicalis',
        label:'8364', //热带爪蟾
      },{
        value: 'Oryzias latipes',
        label:'8090',//青锵鱼
      },{
        value: 'Canis familiaris',
        label:'9615',
      },{
        value: 'Ovis aries',
        label:'9940',
      },{
        value: 'Kaposi sarcoma-associated herpesvirus',
        label:'37296',
      },{
        value: 'Human cytomegalovirus',
        label:'10359',
      },

      ],
    }
  },
  watch:{
    selectedOption(newVal) {
      if (newVal === 'allgene') {
        this.gene = ''; // 清空 gene 输入框数据
      }
    },
  },
  mounted() {
    // Initialize ECharts chart instance
    this.chart = echarts.init(this.$refs.chartContainer);
    this.species = 'Homo sapiens';
    this.dataset = 'miR-gene-miRTarBase';
    this.selectedOption = 'gene';
    this.gene = ''
    // this.networkinput();
    this.network = mountedNodeData;
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
      this.paginatedData = this.testGeneData.slice(startIndex, endIndex);
    },
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

    async networkinput() {
      if (!this.dataset) {
        this.dataset = 'miR-gene-miRTarBase';
      }
      if (!this.species) {
        this.species = 'Homo sapiens';
      }

      this.result = '';
      this.testGeneData = '';
      this.paginatedData = '';//对数据进行初始化
      this.currentPage= 1;
      // 根据选择过滤数据
      if (this.selectedOption === "gene") {
        this.result = await TgNcRNA(this.dataset, this.species, this.gene);
        this.testGeneData = this.result;
      } else if(this.selectedOption === "allgene") {
        this.result = await TgNcRNA(this.dataset, this.species, 'all');
        this.testGeneData = this.result;
      }else if(this.selectedOption === "ncrna"){
        this.result = await  mirRNATg(this.dataset, this.species ,this.gene);
        this.testGeneData = this.result;
      }

      // 添加评分机制
      this.testGeneData = this.testGeneData.map(item => {
        let score = 0;
        if (item.Experiments) {
          if (item.Experiments.includes('eporter assay')) score += 1; //这样对大小写没那么敏感
          if (item.Experiments.includes('Western blot')) score += 1;
          if (item.Experiments.includes('qRT-PCR')) score += 1;
          if (item.Experiments.includes('phenotypic sensor assay')) score += 1;

        }
        return { ...item, score }; // 为每个条目添加一个 `score` 字段
      });

      // 按评分排序（降序）
      this.testGeneData.sort((a, b) => b.score - a.score);

      // 初始化分页和网络图
      this.tablePageTotal = this.testGeneData.length;
      this.updatePaginatedData();
      this.network = transformData(this.testGeneData);
      this.renderNetwork();
    },
    downloadresult(){
      if (!this.testGeneData || this.testGeneData.length === 0) {
        this.$message.warning('暂无数据可导出');
        return;
      }

      const header = ['miRTarBase ID', 'miRNA', 'Target Gene', 'Species (Target Gene)', 'Experiments'];
      const rows = this.testGeneData.map(item => [
        item['miRTarBase ID'],
        item['miRNA'],
        item['Target Gene'],
        item['Species (Target Gene)'],
        item['Experiments']
      ]);

      const csvContent = [header, ...rows]
        .map(row =>
          row.map(field =>
            `"${(field !== undefined && field !== null ? field.toString().replace(/"/g, '""') : '')}"`
          ).join(',')
        )
        .join('\n');
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);

      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', this.gene+'_ncRNA.csv');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    },

    renderNetwork() {
      if (!this.network || !this.network.nodes.length) {
        this.chart.clear();
        this.$message.warning(`No network data found for gene "${this.gene}".`);
        return;
      }
      const titleText = this.gene && this.gene.trim() ?` ${this.gene} Network:` : 'Adipokines related ncRNA-mRNA Network';
      const option = {
        // title: {
        //   text: "Gene Network",
        //   left: "center",
        // },
        title: {
          text:titleText,
          left: "left",
          top:"10px",
          textStyle: {
            fontSize:24,
            color: '#2b6cb0',   // 字体颜色
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
        force: {
          repulsion: 500,        // 节点之间的排斥力，数值越大，节点越分散
          edgeLength: [200, 300], // 边的长度范围：最短80，最长150
          gravity: 0.1,           // 减小中心吸力，防止节点聚在中间
          friction: 0.2,          // 增加摩擦，减少剧烈移动
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
        ],

      };

      this.chart.setOption(option);
    },
  },
}
</script>

<style scoped>
#ncRNA-gene {
  max-width: 1400px;
  margin: 0 auto;
  font-family: 'Segoe UI', Roboto, sans-serif;
  color: #333;
  background-color: #ffffff;
}

.nc-title1{
  font-size: 28px;
  font-weight: 700;
  color: #2a5eaa;
  margin-top: -10px;

}

.el-table-nc{
}
.input-container {
  display: flex;
  justify-content: center; /* Center the cards */
  gap: 20px; /* Space between cards */
  margin-bottom: 20px;
}

.el-card1,
.el-card2 {
  width: 750px; /* Adjust the width of the cards */
}

.el-card1 {
  height: 300px;
  display: flex;
  text-align: left;
  font-size: 16px;
  color: #444;
  background: #ffffff;
  padding: 12px 16px;
  border-radius: 6px;
  line-height: 1.6;
}

.el-card2 {
  font-size: 16.5px;
  text-align: left;
  font-weight: 500;
  line-height: 1.8;
  color: #2c3e50;
  background: #ffffff;
  padding: 18px 22px;

  border-radius: 8px;
}


/* 选中后下拉框的文字为蓝色加粗 */
/deep/ .el-select .el-input__inner {
  font-weight: bold;
  color: #2a5eaa;
}

/* 选中项在下拉列表中也加粗高亮 */
/deep/ .el-select-dropdown__item.selected {
  font-weight: bold;
  color: #2a5eaa;
}

/* 按钮样式 */
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

.form-group{
  padding: 8px;
}

/* 单选框和输入框在同一行显示 */
.radio-group {
  display: flex;
  align-items: center;
  gap: 15px;

}

.input-group {
  display: inline-flex;
  align-items: center;
  margin-left: 10px;
  visibility: visible; /* 默认可见 */
}

.input-label {
  font-size: 16px;
  margin-right: 10px;
  font-weight: bold;
}

.input-field {
  padding: 8px;
  font-size: 16px;
  border: 1px solid #ccc;
  border-radius: 4px;
  width: 200px;
}



.table-expand {
  padding: 10px 15px;
  background: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.table-expand .el-form-item {
  margin-bottom: 12px;
}

.table-expand .el-form-item label {
  font-weight: bold;
  font-size: 14px;
  color: #666;
}


.chart-container {
  width: 97.2%; /* 设置容器的宽度 */
  height: 700px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin: 20px auto 40px auto; /* 控制垂直方向的距离 */
  padding: 20px; /* 给容器内部添加内边距 */
}

</style>
