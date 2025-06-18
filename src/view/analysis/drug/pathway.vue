<template>
  <div id="pathway">
    <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
      <br>
      <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Drug Pathway Analysis
          </span>
        <i class="el-icon-question" style="color: #3a8ee6;cursor: pointer; /* 添加指针样式，表明是可交互的 */" @click="Showhelp = !Showhelp" @mouseenter="showTooltip" @mouseleave="hideTooltip"></i>
      </p>
      <div v-if="isTooltipVisible" :style="{ top: tooltipTop + 'px', left: tooltipLeft + 'px' }" class="tooltip">
        learn more about mRNA Expression
      </div>
      <br>
      <div v-show="Showhelp" style="font-size: 13px;line-height: 1.5;color: #4d4d4d">
        <p>
          <span style="color: #e6903a"> > </span>
          <span>
            The function of this module is to analyse the differential expression of genes in tumour and normal samples in pan-cancer.
          </span>
        </p>
        <p>
          <span style="color: #e6903a"> > </span>
          There are two kinds of analysis results in this module:
          Result 1 is the box plot of mRNA expression of the gene in tumour and normal samples in pan-cancer. Result 2 is a table of the differential expression analysis results of the gene in pan-cancer.
        </p>
      </div>
    </div>

    <div class="pathway-title">
      <!-- 药物靶点通路模块标题简介 -->
    </div>
    <div class="pathway-select">
      <!-- 搜索框 -->
      <div style="text-align: left;height: 200px; ">
        <el-form :inline="true" class="demo-form-inline" >
          <span style="margin-left: 65px;">Gene List:&nbsp&nbsp</span>
          <div style="margin-left: 60px;width: 800px;height: 150px">
            <el-input
              type="textarea"
              :rows="5"
              v-model="genes"
              placeholder="Please enter gene symbols, separated by commas"
              style="width: 800px;height: 150px"
            >
            </el-input>


          </div>
          <div style="margin-left: 60px">
            <span @click="clicksample" style="color: #3a8ee6; cursor: pointer;">Sample</span>
            <el-button type="primary" class="hover-blue-btn" @click="getPathwayPic" style="margin-left: 100px;margin-top: 10px" >Click</el-button>
          </div>

        </el-form>
      </div>
    </div>
    <el-divider></el-divider>
    <div class="pathway-container">
<!--      <div style="text-align: left; margin-bottom: 30px">-->
<!--        <span>Drug gene pathway analysis result</span>-->
<!--        <span style="margin-left: 700px;color: #3a8ee6;cursor: pointer" @click="downloadDiffImg()">download</span>-->
<!--      </div>-->

      <div style="min-height: 640px">
        <el-empty description="Wait For Your Click" v-show="!show" style="height: 600px"></el-empty>

        <div v-loading="loading" v-show="show">
          <el-image
            style="width: 800px;height: 600px"
            :src="'data:image/png;base64,' + png64"
            fit="contain">
          </el-image>

          <br style="margin-top: 40px">
          <el-button type="primary" round @click="downloadDiffImg()">Download</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import jsPDF from "jspdf";

export default {
  name: "pathway",

  data() {
    return {
      png64: "",
      show: false,
      options: [],
      genes: '',  // 支持多个基因
      loading: false,
      allGene: false,
      diffList: [],
      Showhelp :false,//控制div块的显示和隐藏
      isTooltipVisible :false,//问号鼠标移入
      tooltipTop: 0, // 提示框距离顶部的距离
      tooltipLeft: 0, // 提示框距离左侧的距离
    };
  },

  methods: {
    // 获取药物通路图
    getPathwayPic() {
      this.show = true;
      this.loading = true;
      this.png64 = "";

      // 将输入的多个基因分隔开来
      const geneList = this.genes.split(/[, \n]+/).map(gene => gene.trim()).filter(gene => gene);

      if (geneList.length > 200) {
        this.$message({
          message: 'The number of genes cannot exceed 200, so please re-enter.',
          type: 'warning'
        });
        return;
      }
      //输出输入的多基因信息
      console.log(geneList)
      this.$http.get("http://47.97.192.100:8989/r/drugpathway/" + geneList).then(res => {
        this.png64 = res.data;
        this.loading = false;
      });
      // this.$http.get("http://localhost:8989/r/drugpathway/" + geneList).then(res => {
      //  this.png64 = res.data;
      //  this.loading = false;
      //});

    },
    downloadDiffData() {
      let headerRow = ['Gene', 'Drug', 'p.value', 'cor'];
      let csvContent = headerRow.join(",") + "\n";
      let csvData = this.diffList.map(row => {
        let { id, ...rowData } = row;
        return Object.values(rowData).join(",");
      });
      csvContent += csvData.join("\n");

      let blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      let link = document.createElement("a");
      let filename = this.genes.replace(/,/g, '_') + '_drug.csv';  // 使用下划线替换逗号
      if (link.download !== undefined) {
        let url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", filename);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
    },
    downloadDiffImg() {
      if (!this.png64){
        this.$message({
          message:'There are no analysis results on the current page',
          type:'warning'
        });
        return;
      }

      let doc = new jsPDF({
        orientation: 'landscape',
        unit: 'px',
        format: [857, 2572]
      });

      // 根据需要调整插入位置
      doc.addImage('data:image/png;base64,' + this.png64, 'PNG', 0, 0);
      let filename = this.genes.replace(/,/g, '_') + '_drug.pdf';  // 使用下划线替换逗号
      doc.save(filename);
    },
    //点击示例
    clicksample(){
      this.genes = 'EZH2 TP53 BRCA1'

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
    this.clicksample();
    this.getPathwayPic();
  }
}
</script>

<style scoped>
#pathway{
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
