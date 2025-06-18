<template>
<div id="GeneDisease">
  <br>
  <!-- 搜索栏 -->
  <div class="search-container">
    <el-input
      v-model="searchQuery"
      placeholder="Search..."
      class="search-input"
      @input="updatePaginatedData"
      @keyup.enter.native="handleSearch"
    />

    <el-button class="hover-blue-btn" type="primary" @click="handleSearch">Search</el-button>
    <el-button class="hover-blue-btn" type="primary" @click="handleReset">Reset</el-button>
    <el-button class="hover-blue-btn" type="primary" @click="downloadSearch">Download</el-button>
  </div>
  <br>
  <div class="table-container">
    <el-table
      v-loading="loading"
      :data="paginatedData"
      style="width: 95%;margin-left: 2.5%;font-size: 16px"
      stripe
      highlight-current-row
      border
      :header-cell-style="{
      backgroundColor: '#fff',
      color: '#245aa9',
      fontWeight: 'bold',
      fontSize: '16px',
      borderBottom: 'none'
      }"
    >
      <el-table-column type="expand" >
        <template v-slot="props">
          <el-form label-position="left" inline class="expand-form" >
            <el-form-item label="Disease">
              <template #label>
                <strong>Disease</strong>
              <span>{{props.row.Diseases}}</span>
              </template>
            </el-form-item>
            <br>

            <el-form-item>
              <template #label>
                <strong>PMID</strong>
              </template>
              <span>{{ props.row.PMID }}</span>
            </el-form-item>
            <br>

            <el-form-item>
              <template #label>
                <strong>Title</strong>
              </template>
              <span>{{ props.row.Title }}</span>
            </el-form-item>
            <br>

            <el-form-item>
              <template #label>
                <strong>Abstract</strong>
              </template>
              <span>{{ props.row.Abstract }}</span>
            </el-form-item>
          </el-form>
        </template>
      </el-table-column>
      <el-table-column
        label="Disease"
        prop="Diseases"
        width="400"
        show-overflow-tooltip>
      </el-table-column>
      <el-table-column
        label="PMID"
        prop="pmid"
        width="150">
        <template v-slot="scope">
          <a
            href="#"
            @click.prevent="getPubmed(scope.row.PMID)"
            class="pmid-link"
            style=" cursor: pointer;">
            {{ scope.row.PMID }}
          </a>
        </template>
      </el-table-column>
<!--      <el-table-column-->
<!--        label="Title"-->
<!--        prop="Title"-->
<!--        show-overflow-tooltip>-->
<!--      </el-table-column>-->
      <el-table-column
        prop="Title"
        label="Title"
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
              {{ scope.row.Title }}
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
    </el-table>
  </div>
  <div class="pagination-container">
    <el-pagination
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      :current-page.sync="currentPage"
      :page-sizes="[10, 20, 50, 100]"
      :page-size="pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="tablePageTotal">
    </el-pagination>
  </div>
<!--  <div>-->
<!--    <p1>This is the word cloud</p1>-->
<!--    <word-cloud2 :sourceData="GeneDis" title="Gene-Dis Word Cloud"></word-cloud2>-->
<!--  </div>-->
  <div  style="background: #ffffff;">
    <word-cloud2 :resultData = "this.adiDisease" @word-clicked="handleWordClick" ></word-cloud2>
<!--    <p>右侧放基因频次图</p>-->
    <div style="text-align: right; font-size: 13px; color: #999; margin-top: -58px; padding-right: 10px;">
      * All literature data are derived from the PubMed database.
    </div>
  </div>
</div>
</template>

<script>
import WordCloud2 from "./wordCloud2.vue";
import * as XLSX from "xlsx";
import adiDiseaseJson from "../../../datajs/adi-disease.json";


export default {
  name: "GeneDisease",
  components: {WordCloud2},
  data(){
    return {
      GeneDis: [], // 完整数据
      searchQuery:'',  //搜索框内数据
      tablePageTotal: 0, // 数据总条目数
      currentPage: 1, // 当前页码
      pageSize: 10, // 每页条目数
      paginatedData: [] ,// 当前页展示的数据
      adiDisease:[],//初始化获取词云json文件  ，数据格式：name   vlaue
      loading:true,//加载动画
      originalGeneDis: [],  // 原始完整数据

    };
  },
  methods: {
    // 超链接到pubmed数据库
    getPubmed(pmid) {
      if (pmid) {
        const url = `https://pubmed.ncbi.nlm.nih.gov/${pmid}/`;
        window.open(url, '_blank'); // 在新标签页打开
      } else {
        console.error("Invalid PMID provided.");
      }
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1; // 每页条数变化时，回到第一页
      this.updatePaginatedData();
    },
    handleCurrentChange(val) {
      console.log("开始换页")
      this.currentPage = val;
      this.updatePaginatedData();
    },
    // 搜索按钮点击事件
    handleSearch() {
      console.log(this.searchQuery);
      this.GeneDis = this.filterDIsDataByQuery(this.searchQuery);
        this.tablePageTotal = this.GeneDis.length;
        this.currentPage = 1; // 搜索结果后始终回到第一页
        this.updatePaginatedData(); // 立即更新分页数据


    },

    handleReset() {
      this.searchQuery = '';
      this.GeneDis = [...this.originalGeneDis];
      this.tablePageTotal = this.GeneDis.length;
      this.currentPage = 1;
      this.updatePaginatedData();
      this.$message.success("Data has been reset.");
    },


    handleWordClick(word) {
      this.searchQuery = word;
      this.handleSearch(); // 直接触发搜索
    },

    //下载搜索文件的功能
    downloadSearch(){
      if (this.GeneDis.length === 0) {
        this.$message.warning('没有可导出的数据！');
        return;
      }

      // 定义数据和标题
      const data = this.GeneDis.map(item => ({
        Diseases: item.Diseases,
        PMID: item.PMID,

        Title: item.title,
        Abstract: item.abstract,
      }));

      // 创建工作簿和工作表
      const workbook = XLSX.utils.book_new();
      const worksheet = XLSX.utils.json_to_sheet(data);

      // 将工作表添加到工作簿
      XLSX.utils.book_append_sheet(workbook, worksheet, "GeneDrug Data");

      // 生成 XLS 文件并触发下载
      XLSX.writeFile(workbook, "GeneDis_Data.xls");
    },

    updatePaginatedData() {
      const startIndex = (this.currentPage - 1) * this.pageSize;
      const endIndex = startIndex + this.pageSize;
      this.paginatedData = this.GeneDis.slice(startIndex, endIndex);
    },
    async loadGeneDrugData() {
      try{
        this.searchQuery = null;
        // 加载10条数据
        const initialDataRes = await this.$http.get("http://47.97.192.100:8090/adidisease/queryall");
        this.GeneDis = initialDataRes.data;
        this.tablePageTotal = initialDataRes.data.length; // 设置总条目数
        this.updatePaginatedData(); // 初始化分页数据
        this.loading = false;
        console.log("开始加载完整疾病数据")
        const fullDataRes = await this.$http.get("http://47.97.192.100:8090/adidisease/queryall/full");
        this.GeneDis = fullDataRes.data;
        this.originalGeneDis = fullDataRes.data;
        this.tablePageTotal = fullDataRes.data.length; // 设置总条目数
        this.updatePaginatedData(); // 初始化分页数据

      }catch (error){
        console.error("疾病文献数据加载失败",error);
      }

    },

    toggleRow(row) {
      this.$set(row, "_expanded", !row._expanded);
    },

    hasExpandableContent(row) {
      return row.Abstract || row.Title || row.PMID || row.Diseases;
    },


    filterDIsDataByQuery(query) {
      const data = this.originalGeneDis;
      // 如果没有查询内容，则返回完整的数据
      if (!query) {
      return data;
      }

  // 过滤数据，检查每个字段是否包含搜索内容
      const searchTerm = query.toLowerCase();
      return data.filter(item => {
        return Object.values(item).some(value =>
          String(value).toLowerCase().includes(searchTerm)
        );
  });
}

},
  mounted() {
    this.loadGeneDrugData();
    this.adiDisease = adiDiseaseJson;
  }
}
</script>

<style scoped>
#GeneDisease{
  max-width: 1400px;
  margin: 0 auto;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* 搜索栏 */
.search-container {
  display: flex;
  margin-left: 2.5%;
  align-items: center;
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



.search-input {
  flex: 1;
  max-width: 300px;
  margin-right: 10px;
}

/* 表格容器 */
.table-container {
  margin-bottom: 20px;
  min-height: 528px;
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


.pmid-link {
  color: #409eff;
  font-weight: bold;
  cursor: pointer;
}

.pmid-link:hover {
  text-decoration: underline;
}

.el-table {
  writing-mode: horizontal-tb !important;
}

/* 展开表单 */
.expand-form {
  padding: 10px;
  background: #f9fafc;
  border-radius: 4px;
}

.expand-form .el-form-item {
  margin-right: 20px;
  margin-bottom: 10px;
}

/* 分页栏 */
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

</style>
