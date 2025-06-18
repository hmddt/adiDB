<template>
  <div id="GeneDrug">
    <!-- 搜索栏 -->
    <div class="search-container">
      <el-input
        v-model="searchQuery"
        placeholder="Search..."
        class="search-input"
        @input="updatePaginatedData"
      />
      <el-button type="primary" @click="handleSearch">Search</el-button>
      <el-button type="primary" @click="downloadSearch">Download</el-button>
    </div>

    <!-- 数据表格 -->
    <div class="table-container">
      <el-table
        :data="paginatedData"
        style="width: 100%;font-size: 16px"
        border
        stripe
        highlight-current-row
      >
        <!-- 展开行 -->
        <el-table-column
          type="expand"
          border
          stripe
        >
          <template #default="props">
            <el-form label-position="left" inline class="expand-form">
              <el-form-item label="PMID">
                <span>{{ props.row.pmid }}</span>
              </el-form-item>
              <br>
              <el-form-item label="DOI">
                <span>{{ props.row.doi }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Title">
                <span>{{ props.row.title }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Abstract">
                <span>{{ props.row.abstract }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Year">
                <span>{{ props.row.year }}</span>
              </el-form-item>
              <br>
              <el-form-item label="Keywords">
                <span style="font-weight: bold">{{ props.row.keywords }}</span>
              </el-form-item>
            </el-form>
          </template>
        </el-table-column>

        <!-- 列定义 -->
        <el-table-column label="PMID" prop="pmid" width="150">
          <template #default="scope">
            <a
              href="#"
              @click.prevent="getPubmed(scope.row.pmid)"
              class="pmid-link"
            >
              {{ scope.row.pmid }}
            </a>
          </template>
        </el-table-column>

        <el-table-column label="Title" prop="title" show-overflow-tooltip></el-table-column>
      </el-table>
    </div>

    <!-- 分页栏 -->
    <div class="pagination-container">
      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        :page-sizes="[10, 20, 50, 100]"
        :page-size="pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="tablePageTotal"
      />
    </div>
  </div>
</template>

<script>
import * as XLSX from 'xlsx';
import GeneDrugDataTable from "../../../datajs/gene-drugData.json"
import wordCloud2 from "./wordCloud2.vue";
import { filterDataByQuery } from '../../../datajs/wordclouddata.js';
export default {
  name: "GeneDrug",
  data(){
    return {
      GeneDrug: [], // 完整数据
      searchQuery:'',  //搜索框内数据
      tablePageTotal: 0, // 数据总条目数
      currentPage: 1, // 当前页码
      pageSize: 10, // 每页条目数
      paginatedData: [] // 当前页展示的数据
    };
  },
  components:{
    wordCloud2
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
      this.currentPage = val;
      this.updatePaginatedData();
    },

    // 搜索按钮点击事件
    handleSearch() {
      console.log(this.searchQuery);
      this.GeneDrug = filterDataByQuery(this.searchQuery);
      this.tablePageTotal = this.GeneDrug.length;
      this.updatePaginatedData();//初始化查询得到的结果
    },
    //下载搜索文件的功能
    downloadSearch(){
      if (this.GeneDrug.length === 0) {
        this.$message.warning('没有可导出的数据！');
        return;
      }

      // 定义数据和标题
      const data = this.GeneDrug.map(item => ({
        PMID: item.pmid,
        DOI: item.doi,
        Title: item.title,
        Abstract: item.abstract,
        Year: item.year,
        Keywords: item.keywords,
      }));

      // 创建工作簿和工作表
      const workbook = XLSX.utils.book_new();
      const worksheet = XLSX.utils.json_to_sheet(data);

      // 将工作表添加到工作簿
      XLSX.utils.book_append_sheet(workbook, worksheet, "GeneDrug Data");

      // 生成 XLS 文件并触发下载
      XLSX.writeFile(workbook, "GeneDrug_Data.xls");
    },



    updatePaginatedData() {

      const startIndex = (this.currentPage - 1) * this.pageSize;
      const endIndex = startIndex + this.pageSize;
      this.paginatedData = this.GeneDrug.slice(startIndex, endIndex);
    },
    loadGeneDrugData() {
      this.GeneDrug = GeneDrugDataTable; // 加载完整数据
      this.tablePageTotal = this.GeneDrug.length; // 设置总条目数
      this.updatePaginatedData(); // 初始化分页数据
    }
  },
  mounted() {
    this.loadGeneDrugData();
  }
};
</script>

<style scoped>
#GeneDrug {
  padding: 20px;
  max-width: 1400px;
  margin: 20px auto;
  background: #fafafa;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* 搜索栏 */
.search-container {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.search-input {
  flex: 1;
  max-width: 300px;
  margin-right: 10px;
}

/* 表格容器 */
.table-container {
  margin-bottom: 20px;
}

.pmid-link {
  color: #409eff;
  font-weight: bold;
  cursor: pointer;
}

.pmid-link:hover {
  text-decoration: underline;
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
