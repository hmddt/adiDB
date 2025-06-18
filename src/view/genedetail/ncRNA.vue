<template>
  <div id="ncRNA">
    <br />
    <h3 class="ncRNA-subtitle">Novel ncRNA adipokines secreted by adipocytes</h3>

    <!-- 搜索栏 -->
    <div class="search-container">
      <el-input
        v-model="searchQuery"
        placeholder="Search gene / pmid / species..."
        class="search-input"
        @input="updatePaginatedData"
        @keyup.enter.native="handleSearch"
      />
      <el-button class="hover-blue-btn" type="primary" @click="handleSearch">Search</el-button>
      <el-button class="hover-blue-btn" type="primary" @click="handleReset">Reset</el-button>
      <el-button class="hover-blue-btn" type="primary" @click="downloadSearch">Download</el-button>
    </div>

    <br />

    <div class="table-container">
      <el-table
        v-loading="loading"
        :data="paginatedData"
        style="width: 95%; margin-left: 2.5%; font-size: 16px"
        stripe
        highlight-current-row
        border
        :header-cell-style="{
          backgroundColor: '#fff',
          color: '#2a5eaa',
          fontWeight: 'bold',
          fontSize: '16px',
          borderBottom: 'none'
        }"
      >
        <el-table-column label="Gene" prop="gene" width="300" />
        <el-table-column label="ncRNA Type" prop="ncRNAtype" width="300" />
        <el-table-column label="PMID" prop="pmid" width="300">
          <template v-slot="scope">
            <a
              href="#"
              @click.prevent="goPubmed(scope.row.pmid)"
              class="pmid-link"
            >
              {{ scope.row.pmid }}
            </a>
          </template>
        </el-table-column>
        <el-table-column label="Species" prop="species" min-width="300" />
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
        :total="tablePageTotal"
      />
    </div>
  </div>
</template>

<script>
import * as XLSX from "xlsx";
export default {
  name: "ncRNA",
  data() {
    return {
      searchQuery: "",
      currentPage: 1,
      pageSize: 10,
      tablePageTotal: 0,
      loading: true,
      allData: [],
      paginatedData: []
    };
  },
  methods: {
    goPubmed(pmid) {
      const url = `https://pubmed.ncbi.nlm.nih.gov/${pmid}/`;
      window.open(url, "_blank");
    },
    handleSearch() {
      const term = this.searchQuery.toLowerCase();
      const filtered = this.allData.filter(item =>
        Object.values(item).some(value =>
          String(value).toLowerCase().includes(term)
        )
      );
      this.tablePageTotal = filtered.length;
      this.currentPage = 1;
      this.paginatedData = filtered.slice(0, this.pageSize);
    },
    handleReset() {
      this.searchQuery = "";
      this.updatePaginatedData();
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.updatePaginatedData();
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.updatePaginatedData();
    },
    updatePaginatedData() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      const data = this.searchQuery
        ? this.allData.filter(item =>
          Object.values(item).some(value =>
            String(value).toLowerCase().includes(this.searchQuery.toLowerCase())
          )
        )
        : this.allData;
      this.tablePageTotal = data.length;
      this.paginatedData = data.slice(start, end);
    },
    async loadData() {
      this.loading = true;
      try {
        const res = await this.$http.get("http://47.97.192.100:8090/ncrna/brief/full");
        this.allData = res.data;
        this.updatePaginatedData();
      } catch (err) {
        this.$message.error("数据加载失败");
      }
      this.loading = false;
    },
    downloadSearch() {
      if (this.paginatedData.length === 0) {
        this.$message.warning("没有可导出的数据！");
        return;
      }
      const ws = XLSX.utils.json_to_sheet(this.paginatedData);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "ncRNA_Brief");
      XLSX.writeFile(wb, "ncRNA_Brief.xlsx");
    }
  },
  mounted() {
    this.loadData();
  }
};
</script>

<style scoped>
#ncRNA {
  max-width: 1400px;
  margin: 0 auto;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.search-container {
  display: flex;
  margin-left: 2.5%;
  align-items: center;
}
.search-input {
  flex: 1;
  max-width: 300px;
  margin-right: 10px;
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

.pmid-link {
  color: #409eff;
  font-weight: bold;
  cursor: pointer;
}
.pmid-link:hover {
  text-decoration: underline;
}

.ncRNA-subtitle {
  margin-left: 3%;
  text-align: left;
  color: #2a5eaa;
  font-weight: 600;
  font-size: 24px;
  margin-top: 10px;
}


.table-container {
  margin-bottom: 20px;
  min-height: 500px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
