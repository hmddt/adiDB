<template>
  <div id="list">
    <div class="table-search">

      <div class="home-select" style="text-align: left">
        <div style="text-align: center; margin-top: 20px">
          <span style="font-weight: bold; font-size: 20px; color: #2f2c23"> Gene: </span>
          <el-select
            v-model="gene"
            filterable
            remote
            placeholder="please enter gene symbol"
            :remote-method="remoteMethod"
            style="width: 68%"
          >
            <el-option
              v-for="option in options"
              :label="option"
              :value="option"
              :key="option"
              style="text-align: left"
            ></el-option>
          </el-select>
          <el-button
            type="primary"
            class="hover-blue-btn"
            style=" height: 4%"
            @click="SearchGene"
          >
            Search
          </el-button>

        </div>
        <div style="text-align: left; margin-top: 20px">
          <span style="font-size: 15px; margin-left: 10.5%; font-weight: bold; color: blue">Examples:</span>
          <span
            style="font-size: 13px; font-weight: bold; cursor: pointer"
            @click="examplesgene('LEP')"
            @mouseenter="examplesstyle1 = true"
            @mouseleave="examplesstyle1 = false"
            :class="{ examplesstyle: examplesstyle1 }"
          >
            LEP
          </span>
          <span> , </span>
          <span
            style="font-size: 13px; font-weight: bold; cursor: pointer"
            @click="examplesgene('RBP4')"
            @mouseenter="examplesstyle2 = true"
            @mouseleave="examplesstyle2 = false"
            :class="{ examplesstyle: examplesstyle2 }"
          >
            RBP4
          </span>
        </div>
      </div>
    </div>

    <div class="summary">
      <div class="summary-table">
        <el-table
          v-loading="loading"
          :data="paginatedData"
          border
          style="width: 100%;min-height: 580px;font-size: 16px"
          :header-cell-style="{ backgroundColor: '#fff', color: '#245aa9', fontWeight: 'bold' }">
<!--          @row-click = "goToDetail"-->


          <el-table-column
            prop="gene"
            label="Gene Symbol"
            width="140"
            v-slot:default="scope"
          >
            <router-link
              :to="{ path: '/listinformation', query: { gene: scope.row.gene } }"
            >
              <span class="gene-link">
              {{ scope.row.gene }}
              </span>
            </router-link>
          </el-table-column>
          <el-table-column
          prop="protein"
          label="Protein"
          width="330">

          </el-table-column>
          <el-table-column
            prop="Species"
            label="Species"
            width="230">
            <template slot-scope="scope">
              <span style="font-style: italic;">{{ scope.row.Species }}</span>
            </template>
          </el-table-column>

          <el-table-column
            prop="Ensembl"
            label="Gene ID"
            width="200"
          >
            <template slot-scope="scope">
              <a
                :href="getGeneLink(scope.row.Ensembl, scope.row.gene)"
                target="_blank"
              >
                <span style="display: inline-block; white-space: nowrap;">
                {{ scope.row.Ensembl }}
                </span>
              </a>
            </template>
          </el-table-column>
<!--          <el-table-column-->
<!--            prop="Function"-->
<!--            label="Function"-->
<!--            min-width="35%"-->
<!--            align="left"-->

<!--          ></el-table-column>-->
          <el-table-column
            prop="Function"
            label="Function"
            align="left"
          >
            <template slot-scope="scope">
              <div
                @click="toggleRow(scope.row)"
                style="position: relative; cursor: pointer; overflow: hidden"
              >
                <div
                  :style="{
          overflow: 'hidden',
          whiteSpace: scope.row._expanded ? 'normal' : 'nowrap',
          textOverflow: scope.row._expanded ? 'initial' : 'ellipsis',
          paddingRight: '20px'
        }"
                >

                  {{ scope.row.Function }}
                </div>
                <i
                  class="el-icon-caret-bottom"
                  :style="{
                color:'#999',
                position: 'absolute',
                right: '0',
                top: '0',
                padding: '5px',
                transition: 'transform 0.3s ease'
                }"
                />
              </div>
            </template>
          </el-table-column>


          <!--          将more按钮去掉 改为点击这一类就近详情列表-->
<!--          <el-table-column-->
<!--            prop="action"-->
<!--            label="Action"-->
<!--            min-width="15%"-->
<!--            v-slot:default="scope"-->
<!--          >-->
<!--            <router-link-->
<!--              :to="{ path: '/listinformation', query: { gene: scope.row.gene } }"-->
<!--            >-->
<!--              <el-button type="primary" size="small" class="detail-button">More</el-button>-->
<!--            </router-link>-->
<!--          </el-table-column>-->
        </el-table>
        <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="currentPage"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="tablePageTotal"
          style="margin-top: 30px"
        ></el-pagination>

      </div>
      <br>
    </div>
  </div>
</template>

<script>
import Listcard from "./Listcardl.vue";



export default {
  name: "list",
  components: {
    Listcard,
  },
  data() {
    return {
      tableDate: [], // All table data
      paginatedData: [], // Data to display for the current page
      gene: "",
      allgene: [],
      options: [],
      examplesstyle1: false,
      examplesstyle2: false,
      tablePageTotal: 0, // Total number of items
      currentPage: 1, // Current page number
      pageSize: 10, // Number of items per page
      loading:true,//加载动画
    };
  },
  mounted() {
    this.fetchInitialData();
    // this.$http.get('http://47.97.192.100:8090/adi/all').then(res=>{
    //   this.tableDate = res.data;
    //   this.tablePageTotal = this.tableDate.length; // Set total items count
    //   this.updatePaginatedData(); // Initialize pagination data
    // });
    //数据库内ip位置
    // http://localhost:8090/adi/all
    // this.$http.get('http://47.97.192.100:8090/adi/allToAbstract').then(res=>{
    //   this.tableDate = res.data;
    //   this.tablePageTotal = this.tableDate.length; // Set total items count
    //   this.updatePaginatedData(); // Initialize pagination data
    // });//本地地址 （all和allToAbstract区别在于第二个没有查取abstract）
    // this.$http.get('http://localhost:8090/adi/allToAbstract').then(res=>{
    //   this.tableDate = res.data;
    //   this.tablePageTotal = this.tableDate.length; // Set total items count
    //   this.updatePaginatedData(); // Initialize pagination data
    //   this.loading = false;
    // });//本地地址 （all和allToAbstract区别在于第二个没有查取abstract）
    // this.$http.get('http://47.97.192.100:8090/adi/gene').then(res=>{
    //   this.allgene = res.data;
    // });
    // this.tableDate = adigene; // Load data

  },
  methods: {
    async fetchInitialData() {
      try {
        // 请求10条数据接口（假设你有一个返回10条数据的接口）
        const initialDataRes = await this.$http.get('http://47.97.192.100:8090/adi/allToAbstract');
        this.tableDate = initialDataRes.data;  // 设置初始数据
        this.tablePageTotal = initialDataRes.data.length;  // 设置总记录数（可用数据）
        this.updatePaginatedData();  // 初始化分页数据
        this.loading = false;
        // 请求全部数据
        const fullDataRes = await this.$http.get('http://47.97.192.100:8090/adi/allToAbstract/full');
        // 使用全部数据更新表格内容
        this.tableDate = fullDataRes.data;
        this.tablePageTotal = fullDataRes.data.length; // 更新总记录数
        this.updatePaginatedData();  // 再次更新分页数据

        // 请求 gene 数据
        const geneRes = await this.$http.get('http://47.97.192.100:8090/adi/gene');
        this.allgene = geneRes.data;  // 设置 gene 数据

      } catch (error) {
        console.error("数据加载失败:", error);
      }
    },

    remoteMethod(query) {
      if (query !== "") {
        this.options = this.allgene.filter((item) =>
          item.toLowerCase().includes(query.toLowerCase())
        );
      } else {
        this.options = [];
      }
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1; // Reset to the first page
      this.updatePaginatedData();
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.updatePaginatedData();
    },
    updatePaginatedData() {
      const startIndex = (this.currentPage - 1) * this.pageSize;
      const endIndex = startIndex + this.pageSize;
      this.paginatedData = this.tableDate.slice(startIndex, endIndex);
    },
    SearchGene() {
      const geneFound = this.allgene.some((item) => item.toLowerCase() === this.gene.toLowerCase());

      if (!geneFound) {
        // If gene is not found, show an error message
        this.$message.error("There are no adipokine genes.");
      } else {
        // If gene is found, navigate to the detailed page
        this.$router.push({ path: "/listinformation", query: { gene: this.gene } });
      }
    },
    examplesgene(example) {
      this.gene = example;
    },
    goToDetail(row){
      this.$router.push({
        path: "/listinformation",
        query: { gene: row.gene }
      });
    },
    toggleRow(row) {
      this.$set(row, "_expanded", !row._expanded);
    },
    // 判断跳转哪个链接
    getGeneLink(enid, gene) {
      if (enid.includes("MGI")) {
        return `https://www.informatics.jax.org/quicksearch/summary?queryType=exactPhrase&query=${encodeURIComponent(enid)}`;
      } else {
        return `https://www.genecards.org/cgi-bin/carddisp.pl?gene=`+gene;
      }
    }
    },

};
</script>


<style scoped>
body, div, dl, dt, dd, ul, ol, li, h1, h2, h3, h4, h5, h6, pre, form, fieldset, legend, input, textarea, button, p, blockquote, th, td
{margin: 0;}
body{text-align: center;font-family: Helvetica Neue,Helvetica,Arial,Microsoft Yahei,Hiragino Sans GB,Heiti SC,WenQuanYi Micro Hei,sans-serif;}
li{ list-style: none;}
a{text-decoration: none;
  color: #5a5a5a
}
a:hover{
  text-decoration: underline; /* 添加下划线 */
  color: #3a8ee6;
}
img{border: none;}

#list{
  width: 1400px;
  margin: 0 auto;
  height: 100%;
  border-style: solid;
  background-color: #ffffff;
  border-color: rgba(168,168,168,0);

}
.summary{
  /*display: flex;*/
  position: relative;
  display: flex;
  flex-direction: column;

  left: 0;
  width: 100%;
  background: #ffffff;
}
.summary-table{
  flex: 1; /* 让表格自动填满剩余空间 */
  width: 80%;
  position: relative;
  top: 50px;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  min-height: 680px;

}
.el-table {
  writing-mode: horizontal-tb !important;
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
.gene-link{
  color: #409eff;
  font-weight: bold;
  cursor: pointer;
}
.hover-blue-btn:hover {
  background-color: #1f4c90 !important;
  border-color: #1f4c90 !important;
}

/deep/ .el-table th:first-child {
  border-top-left-radius: 8px;
}

/deep/ .el-table th:last-child {
  border-top-right-radius: 8px;
}

/deep/ .el-table__row:hover td {
  background-color: #f0f6ff !important;
}

.examplesstyle{
  color: #3a8ee6;
  text-decoration: underline;
}
</style>
