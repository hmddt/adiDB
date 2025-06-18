<template>
  <div id="immustimulator">
    <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
      <br>
      <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Immune Stimulator Factor Analysis
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
    <hr style="width: 1300px">
    <div style="margin: 20px;">
      <el-form :inline="true" class="demo-form-inline">
        <!--longivity gene-->
<!--        <el-form-item label="Gene" v-show="!allGene">-->
        <span style="font-size: 16px">Gene:&nbsp&nbsp</span>
          <el-select
            v-model="gene"
            filterable
            remote
            placeholder="please enter gene symbol"
            :remote-method="remoteMethod"
            :loading="remoteLoading">
            <!-- remote-method封装好的钩子函数。当用户在输入框中输入内容的时候，会触发这个函数的执行，
            把输入框对应的值作为参数带给回调函数，loading的意思就是远程搜索的时候等待的时间，即：加载中-->
            <el-option
              v-for="option in options"
              :label="option"
              :value="option"
              :key="option">
            </el-option>
          </el-select>

        <el-button type="primary" class="hover-blue-btn" @click="getimmustimulatorPic">Click</el-button>
      </el-form>
    </div>


    <el-empty description="Wait For Your Click" v-show="!show" style="height: 600px"></el-empty>

    <div v-loading="loading" v-show="show"  >
      <div class="checkpoint-left" style=" height: 800px;margin-top: 50px;background-color: #ffffff;">
        <!--免疫检查点图片图片-->
        <el-image
          style=" height: 750px"
          :src="useUrlImage ? png64 : ('data:image/png;base64,' + png64)"
          fit="contain">
        </el-image>
        <br>
        <el-button type="primary"  round @click="downloadDiffImg">Download</el-button>
      </div>

<!--      <div class="checkpoint-right" style=" position: relative; margin-left: 5%; margin-top:10px;padding: 10px;width: 30%; background-color: #ffffff;">-->
<!--        &lt;!&ndash;拿到checkpoint数据&ndash;&gt;-->
<!--        <span style="font-weight: bold;font-size: 14.5px"> Correlation with immustimulator </span>-->
<!--        <el-table-->
<!--          :stripe="true"-->
<!--          :data="immus"-->
<!--          height="500"-->
<!--          border-->
<!--          style="width: 100%;height: 87%;top: 20px">-->
<!--          <el-table-column-->
<!--            prop="gene"-->
<!--            label="gene">-->
<!--          </el-table-column>-->
<!--          <el-table-column-->
<!--            prop="cancer"-->
<!--            label="cancer">-->
<!--          </el-table-column>-->
<!--          <el-table-column-->
<!--            prop="immustimulator"-->
<!--            label="immustimulator">-->
<!--          </el-table-column>-->
<!--          <el-table-column-->
<!--            prop="cor"-->
<!--            label="cor">-->
<!--          </el-table-column>-->
<!--          <el-table-column-->
<!--            prop="sig"-->
<!--            label="sig">-->
<!--          </el-table-column>-->

<!--        </el-table>-->

<!--        <el-button type="primary" round @click="downloadDiffDataData" style="position: relative;margin-top: 7%">Download</el-button>-->
<!--      </div>-->


    </div>

  </div>
</template>

<script>
import jsPDF from "jspdf";

export default {
  name: "checkpoint",
  data() {
    return {
      png64: "",
      show: false,
      allGenes: [
        "LEP", "TP53", "BRCA1", "BRCA2", "EGFR", "VEGFA", "TNF", "IL6", "MMP9", "CDKN2A",
        "KRAS", "AKT1", "PTEN", "CTNNB1", "MYC", "APC", "BRAF", "CCND1", "ESR1", "MTOR",
        "CDH1", "RB1", "ERBB2", "FGFR1", "MDM2", "CDK4", "SMAD4", "PDGFRA", "GATA3", "JAK2",
        "PIK3CA", "TSC2", "HIF1A", "CDK6", "NFKB1", "IDH1", "STAT3", "FOXO3", "AR", "TGFBR2",
        "RELA", "MAPK1", "CXCL8", "BCL2", "IL10", "CXCL12", "CCL2", "TGFB1", "SOCS3", "IL2",
        "PDCD1", "CD274", "LAG3", "HAVCR2", "CTLA4", "TIGIT", "CD80", "CD86", "ICOS", "CD28",
        "FASLG", "FAS", "CD40", "CD40LG", "TNFRSF9", "TNFSF9", "IL12A", "IL12B", "IL18", "IL1B",
        "IFNG", "GZMB", "PRF1", "KLRK1", "NKG7", "GNLY", "CXCR3", "CCR5", "CCR7", "CXCR5",
        "CD3D", "CD3E", "CD4", "CD8A", "CD8B", "FOXP3", "IL21", "IL23A", "STAT1", "IRF1", "IRF8",
        "CIITA", "HLA-DRA", "HLA-DRB1", "HLA-A", "HLA-B", "HLA-C", "HLA-E", "HLA-F", "HLA-G"
      ],
      options: [],
      immus: [],
      useUrlImage: true,
      gene: 'LEP',
      loading: false,
      remoteLoading: false,
      Showhelp: false,
      isTooltipVisible: false,
      tooltipTop: 0,
      tooltipLeft: 0,
    };
  },
  methods: {
    // ✅ 本地模糊搜索 gene
    remoteMethod(query) {
      if (query !== "") {
        this.remoteLoading = true;
        setTimeout(() => {
          this.options = this.allGenes.filter(item =>
            item.toLowerCase().includes(query.toLowerCase())
          );
          this.remoteLoading = false;
        }, 200);
      } else {
        this.options = [];
        this.remoteLoading = false;
      }
    },

    // 加载免疫图片
    getimmustimulatorPic() {
      this.show = true;
      this.loading = true;
      this.png64 = "";
      Promise.all([
        this.$http.get("http://47.97.192.100:8989/r/immu/immustimulator/" + this.gene)
      ]).then(([imgRes]) => {
        this.png64 = imgRes.data;
        this.loading = false;
      });
    },

    // 下载图片 PDF
    downloadDiffImg() {
      let doc = new jsPDF({ unit: 'px', format: [1200, 1200] });
      doc.addImage('data:image/png;base64,' + this.png64, 'PNG', 0, 0);
      doc.save(this.gene + '_immustimulator_image.pdf');
    },

    // 下载表格 CSV
    downloadDiffDataData() {
      let headerRow = ['Gene', 'Cancer', 'immustimulator', 'Cor', 'Sig'];
      let csvContent = headerRow.join(",") + "\n";
      let csvData = this.immus.map(row => {
        let { id, ...rowData } = row;
        return Object.values(rowData).join(",");
      });
      csvContent += csvData.join("\n");

      let blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      let link = document.createElement("a");
      let url = URL.createObjectURL(blob);
      link.setAttribute("href", url);
      link.setAttribute("download", this.gene + '_immustimulator.csv');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },

    showTooltip(event) {
      this.isTooltipVisible = true;
      this.tooltipTop = event.clientY + 10;
      this.tooltipLeft = event.clientX + 10;
    },

    hideTooltip() {
      this.isTooltipVisible = false;
    },

    init() {
      setTimeout(() => {
        this.loading = true;
        this.png64 = "http://tmliang.cn/pic/adi/analysis/LEP_immustimulator_image.png";
        this.useUrlImage = true;
        this.show = true;

        const img = new Image();
        img.onload = () => {
          this.loading = false;
        };
        img.onerror = () => {
          this.$message.error('图片加载失败，请检查地址或服务器设置');
          this.loading = false;
        };
        img.src = this.png64;
        console.log("stimulator界面初始化图片记载完成");
      }, 500);
    }
  },
  mounted() {
    this.init();
  },
  activated() {
    this.init();
  }
};
</script>


<style scoped>
#immustimulator{
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
