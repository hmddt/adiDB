<template>
  <!-- 肥胖相关数据集页面 -->
  <div id="dataset">
    <!-- 页面标题 -->
    <div class="dataset-title">
      <p class="dataset-title-text">Obesity Related Datasets</p>
    </div>

    <!-- 数据集卡片展示 -->
    <div v-for="(item, index) in paginatedData" :key="index" class="dataset-card">
      <p class="dataset-card-header">
        <span style="color: #3a8ee6;font-size: 25px" >{{ item.undefined || 'N/A' }}</span>
        <span style="font-size: 18px">{{ item.Organism || 'N/A' }}</span>
      </p>
      <p class="dataset-card-title">{{ item.Title || 'No Title Available' }}</p>
      <p class="dataset-card-design" style="font-size: 18px">{{ item['Overall design'] || 'No Overall Design Available' }}</p>
      <p class="dataset-card-status" style="font-size: 16px">
        <span>{{ item.Status || 'Unknown Status' }}</span>
        <span @click="clickgse(item.undefined)" style="font-weight: bold;color: #3a8ee6;font-size: 16px;cursor: pointer"><i class="el-icon-right"></i>Go To GEO</span>
      </p>

      <!-- 原生横向表格 -->
      <div class="dataset-table">
        <table>
          <thead>
          <tr>
            <th>Obese Group</th>
            <th>Lean Group</th>
          </tr>
          </thead>
          <tbody>
          <tr>
            <td>{{ item['obese group'] || 'unknown' }}</td>
            <td>{{ item['lean group'] || 'unknown' }}</td>
          </tr>
          </tbody>
        </table>
      </div>

    </div>

    <!-- 分页组件 -->
    <el-pagination
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      :current-page="currentPage"
      :page-sizes="[10, 20, 50, 100]"
      :page-size="pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="tablePageTotal"
      class="pagination"
    />
  </div>
</template>


<script>
import Obesity_dataset from '../../../datajs/Obesity_dataset.json';

export default {
  name: 'dataset',
  data() {
    return {
      Obesity_dataset: [], // 肥胖数据集信息
      tablePageTotal: 0, // 总数据条数
      currentPage: 1, // 当前页码
      pageSize: 10, // 每页显示条数
      paginatedData: [], // 当前页的数据
    };
  },
  mounted() {
    this.initializeData();
  },
  methods: {
    initializeData() {
      this.Obesity_dataset = Obesity_dataset;
      this.tablePageTotal = Obesity_dataset.length;
      this.updatePaginatedData();
    },
    // 处理页码变化
    handleCurrentChange(page) {
      this.currentPage = page;
      this.updatePaginatedData();
    },
    // 处理每页显示条数变化
    handleSizeChange(size) {
      this.pageSize = size;
      this.currentPage = 1; // 重置到第一页
      this.updatePaginatedData();
    },
    // 更新当前页数据
    updatePaginatedData() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      this.paginatedData = this.Obesity_dataset.slice(start, end);
    },
    //点击数据集跳转页面
    clickgse(gseno){
      window.open('https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc='+gseno);
    }
  }
};

</script>

<style scoped>
#dataset {
  padding: 20px 0;
  width: 1400px;
  margin: 0 auto;
  background: #ffffff;
  text-align: left;
}

/* 标题样式 */
.dataset-title {
  text-align: center;
  margin-bottom: 20px;
}

.dataset-title-text {
  font-size: 32px;
  font-weight: bold;
  color: #3a8ee6;
}

/* 数据集卡片样式 */
.dataset-card {
  background: #ffffff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 15px;
  width: 95%;
  margin-left: 2.5%;
  margin-bottom: 15px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.dataset-card-header {
  display: flex;
  justify-content: space-between;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 10px;
  color: #2c3e50;
}

.dataset-card-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 8px;
  color: #333;
}

.dataset-card-status {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  margin-bottom: 8px;
  color: #666;
}

.dataset-card-design {
  font-size: 14px;
  color: #555;
}

/* 分页组件样式 */
.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}


/*横向表格样式*/
.dataset-table {
  width: 100%;
  margin-top: 10px;
}

.dataset-table table {
  width: 50%;
  border-collapse: collapse;
  border: 1px solid #e0e0e0;
}

.dataset-table th, .dataset-table td {
  padding: 8px 12px;
  text-align: center;
  border: 1px solid #e0e0e0;
}

.dataset-table th {
  background-color: #f2f2f2;
  color: #3a8ee6;
  font-weight: bold;
}

</style>
