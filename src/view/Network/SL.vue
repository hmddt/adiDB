<template>
<!--合成致死网络模块-->
  <div id="sl">
    <div class="sl-container">
      <el-card class="sl-card">
        <div  class="sl-header">
          <p class="sl-title1">Synthetic Lethality Network</p>
          <p class="sl-subtitle">Please enter the gene you are interested in below</p>
        </div>

        <div class="sl-input-group">
          <label for="geneInput" class="sl-label">Gene: </label>
          <input
            type="text"
            id="geneInput"
            v-model="gene"
            @click="gene=''"
            placeholder="Enter Gene value"
            class="sl-input"/>
          <el-button  class="hover-blue-btn" type="primary"  @click="networkinput">Input</el-button>
        </div>

        <div class="sl-hunt">
          <p><strong>Synthetic Lethality:</strong> Synthetic lethality occurs when the loss of two genes together causes cell death, but losing either one alone does not. It is a key concept in cancer therapy research.</p>
          <p><strong>Data Source:</strong> The data were collected from multiple databases, including PubMed, SynLethDB, <span style="color: #3a8ee6;font-weight: bold">SLOAD</span>, and <span style="color: #3a8ee6;font-weight: bold">CSSL</span>. In addition,
            computational <span style="color: #3a8ee6;font-weight: bold;cursor: pointer" @click="startState=true" >prediction</span>  tools were employed to further complement and refine the dataset.</p>
        </div>
        <br>
        <div class="herf-database">
          <el-card><img src="../../assets/otherDataBaseImg/SLOAD.png" @click="loacationdb('SLOAD')" style="height: 80px"></el-card>
          <el-card><img src="../../assets/otherDataBaseImg/CSSL2.png" @click="loacationdb('CSSL')" style="height: 80px"></el-card>

        </div>

      </el-card>

    </div>
    <div>
      <div v-show="startState">
        <starte-charts></starte-charts>
      </div>
      <div v-show="!startState" ref="chartContainer" class="chart-container"></div>
    </div>
  </div>
</template>

<script>
import * as echarts from "echarts";
import mountedslData from '../../../datajs/slnetwork/matchedSynlethalityNetwork.json'
import starteCharts from '../test/NetworkGraph.vue'
export default {
  name: "SL",
  data(){
    return{
      gene: '',
      uniqueSLData:[], //后端筛选得到的去重后的合成致死网络数据结果
      chartdata:[],//用于图表的处理数据
      network:[],
      startState:true,
    }
  },
  components:{
    starteCharts,
  },
  mounted() {
    this.$nextTick(() => {
      this.chart = echarts.init(this.$refs.chartContainer);
      // this.gene = 'FABP4';
      this.network = mountedslData;
      this.renderNetwork();
    });
  },
  methods:{
    networkinput(){
      this.startState = false;
      if(this.gene === ''){
        this.$message.warning('Enter gene symbol as empty!');
      }
      else {
        this.$http.get("http://47.97.192.100:8090/sl/gene/"+this.gene).then((res)=>{
          const data = res.data.uniqueData;

          if (!data || data.length === 0) {
            this.$message.warning(`No synthetic lethality data found for "${this.gene}".`);
            this.gene = '';
            return;
          }
          this.uniqueSLData = res.data.uniqueData.map(item => {
            return {
              GeneA: item.GeneA,
              GeneB: item.GeneB,
              PMID: item.PMID,
            };
          });
          this.chartdata = this.chartdataprocess();
          this.network =this.chartdata;
          this.renderNetwork();
        });
      }

    },
    chartdataprocess(){
    //   原始数据处理方法
    //   原始数据 this.uniqueSLData 对节点进行初始化

      const inputData = this.uniqueSLData;
      const nodes = [];
      const links = [];
      const categories = [
        { name: "GeneA" , itemStyle: { color: "#27ae60" }},
        { name: "GeneB" , itemStyle: { color: "#27ae60" } }
      ];
      // 如果输入基因不在GeneA,则GeneA和GeneB调换位置
      inputData.forEach((item)=> {
        if (this.gene !== item.GeneA){
          const GeneC = item.GeneA;
          item.GeneA = item.GeneB;
          item.GeneB = GeneC;
        }
      })

      const nodeMap = new Map(); // 用于检查节点是否已存在
      let nodeId = 0; // 节点 ID 累计值
      inputData.forEach((item) => {
        // 添加或更新 TF 节点
        if (!nodeMap.has(item.GeneA)) {
          nodeMap.set(item.GeneA, { id: nodeId, category: 0 }); // TF 类别
          nodes.push({
            id: String(nodeId),
            name: item.GeneA,
            symbolSize: 10, // 示例大小
            x: Math.random() * 500 - 250, // 随机 x 坐标
            y: Math.random() * 500 - 250, // 随机 y 坐标
            // value: Math.random() * 30 + 10, // 示例值
            category: 0
          });
          nodeId++;
        } else {
          const existingNode = nodeMap.get(item.GeneA);
          if (existingNode.category === 1) {
            existingNode.category = 0;
            const nodeToUpdate = nodes.find(node => node.id === String(existingNode.id));
            if (nodeToUpdate) {
              nodeToUpdate.category = 0;
              nodeToUpdate.symbolSize = 10; //
              // nodeToUpdate.value = Math.random() * 30 + 10; //
            }
          }
        }

        // 添加 Target_gene 节点
        if (!nodeMap.has(item.GeneB)) {
          nodeMap.set(item.GeneB, { id: nodeId, category: 1 }); // Target_gene 类别
          nodes.push({
            id: String(nodeId),
            name: item.GeneB,
            symbolSize: 10, // 示例大小
            x: Math.random() * 300 - 20, // 随机 x 坐标
            y: Math.random() * 300 - 20, // 随机 y 坐标
            category: 1 // Target_gene 的类别
          });
          nodeId++;
        }

        // 添加链接
        links.push({
          source: String(nodeMap.get(item.GeneA).id),
          target: String(nodeMap.get(item.GeneB).id),
          lineStyle: {
            color: '#a60b0b' // 设置边的颜色
          },
          info: `SLGene: ${item.GeneA} , ${item.GeneB}, PMID: ${item.PMID}`,

        });
      });

      return { nodes, links, categories };
    },
    renderNetwork() {
      if (this.chart) {
        this.chart.dispose();
        this.chart = echarts.init(this.$refs.chartContainer);
      }

      console.log("Network Data:", this.network);

      if (!this.network || !this.network.nodes || this.network.nodes.length === 0) {
        this.$message.warning(`No network data found for gene "${this.gene}".`);
        return;
      }
      const titleText = this.gene&&this.gene.trim() ?`${this.gene} Gene Network:`: 'Adipokines related Synthetic Lethality Network';

      const option = {
        title: {
          text: titleText,
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
        // legend: {
        //   data: this.network.categories.map(c => c.name), // 图例的内容是节点的分类
        //   left: '10px', // 图例位置在左侧
        //   top: '60px', // 将图例放置在标题下方，调整这个值来控制距离
        //   // orient: 'horizontal', // 设置图例为横向排列
        //   orient: 'vertical', // 将图例改为垂直排列
        //   itemWidth: 20, // 设置图例项的宽度
        //   itemHeight: 20, // 设置图例项的高度
        //   textStyle: {
        //     fontSize: 16, // 设置图例文字的字体大小
        //     color: '#0d2946', // 设置图例文字的颜色，可以根据需求调整
        //   },
        // },

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
    loacationdb(name){
      window.open('http://www.tmliang.cn/'+name+'/');
    }

  },
}
</script>

<style scoped>
#sl {
  margin: 0 auto;
  max-width: 1400px;
  font-family: 'Segoe UI', Roboto, sans-serif;
  color: #333;
  background-color: #ffffff;
}

/* 卡片样式 */
.sl-card {
  width: 100%;
  background-color: #ffffff;
  padding: 32px 40px;
  border-radius: 12px;
  border: 1px solid #dfe6ec;
  box-shadow: none;
  margin-bottom: 40px;
  text-align: left;
}

/* 标题与副标题 */
.sl-header {
  margin-top: -20px;
  margin-bottom: 18px;
  text-align: left;
}

.sl-title1 {
  margin-top: -30px;
  font-size: 28px;
  font-weight: 700;
  color: #2a5eaa;
  margin-bottom: 10px;
}

.sl-subtitle {
  font-size: 18px;
  color: #444;
  font-weight: 500;
}

/* 输入区 */
.sl-input-group {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 16px;
  margin-bottom: 20px;
}

.sl-label {
  font-size: 16px;
  font-weight: 600;
  color: #2a3f5f;
}

.sl-input {
  flex: 1;
  min-width: 240px;
  padding: 10px 14px;
  font-size: 16px;
  border: 1px solid #ccc;
  border-radius: 6px;
  background-color: #fafafa;
  transition: border-color 0.2s;
}

.sl-input:focus {
  outline: none;
  border-color: #2a5eaa;
  background-color: #fff;
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

/* 提示区 */
.sl-hunt {
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
  width: 97.2%;
  height: 700px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  margin: 0 auto 40px auto;
  padding: 20px;
}

.sl-container {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 20px;
}
.herf-database{
  display: flex;
  flex-wrap: wrap;         /* 允许换行 */
  gap: 16px;               /* 子模块之间的间距，可根据需要调整 */
}

</style>
