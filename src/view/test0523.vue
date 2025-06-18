<template>
  <div id="surv">
    <div>
      <!--对Surv表达介绍-->
      <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
        <br>
        <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">survival
          </span>
          <i class="el-icon-question" style="color: #3a8ee6;cursor: pointer; /* 添加指针样式，表明是可交互的 */" @click="Showhelp = !Showhelp" @mouseenter="showTooltip" @mouseleave="hideTooltip"></i>
        </p>
        <div v-if="isTooltipVisible" :style="{ top: tooltipTop + 'px', left: tooltipLeft + 'px' }" class="tooltip">
          learn more about survival
        </div>
        <br>
        <div v-show="Showhelp" style="font-size: 13px;line-height: 1.5;color: #4d4d4d">
          <p>
            <span style="color: #e6903a"> > </span>
            <span>
            The function of this module is to analyse the effect of the expression of genes on the prognosis of patients in a given cancer.
          </span>
          </p>
          <p>
            <span style="color: #e6903a"> > </span>
            The module uses the median expression of a given gene in a tumour sample as a grouping condition to classify patients into groups with high and low expression of the gene, and then performs survival analysis to obtain the survival curves of patients in different groups.
          </p>
        </div>
      </div>
    </div>
    <hr style="width: 1300px">
    <!--搜索表单-->
    <div style="margin: 20px;">
      <el-form :inline="true" class="demo-form-inline">
        <el-form-item label="Cancer">
          <el-select v-model="cancer" filterable placeholder="Cancer">
            <el-option
              v-for="cancer in cancers"
              :key="cancer"
              :label="cancer"
              :value="cancer">
            </el-option>
          </el-select>
        </el-form-item>
        <!--all gene-->
        <el-form-item label="Gene" v-show="allGene">
          <el-input v-model="gene" placeholder="please enter gene symbol"></el-input>
        </el-form-item>
        <!--longivity gene-->
        <el-form-item label="Gene" v-show="!allGene">
          <el-select
            v-model="gene"
            filterable
            remote
            placeholder="please enter gene symbol"
            :remote-method="remoteMethod"
            :loading="loading">
            <!-- remote-method封装好的钩子函数。当用户在输入框中输入内容的时候，会触发这个函数的执行，
            把输入框对应的值作为参数带给回调函数，loading的意思就是远程搜索的时候等待的时间，即：加载中-->
            <el-option
              v-for="option in options"
              :label="option"
              :value="option"
              :key="option">
            </el-option>
          </el-select>
        </el-form-item>
        <el-button type="primary" style="background-color: #2f2c23;font-weight: bold" @click="getPic">Click</el-button>
      </el-form>
    </div>
    <!--结果展示模块-->
    <el-empty description="Wait For Your Click" v-show="!show" style="height: 600px"></el-empty>
    <div v-loading="loading" v-show="show">
      <!--Surv-->

      <el-card style="background: white">
        <el-image
          v-if="img64"
          :src="'data:image/png;base64,' + img64"
          fit="contain"
          style="width: 100%; max-height: 600px"
        />
      </el-card>
      <br>
      <el-button type="primary" round @click="downloadImg">Download</el-button>
    </div>
  </div>
</template>

<script>
import analysisCon1 from "./analysis-con1.vue";

import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf';
import pdfWorker from 'pdfjs-dist/legacy/build/pdf.worker.entry';

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorker;



export default {
  name: "HCCPlot",
  components:{
    analysisCon1
  },
  data() {
    return {
      show: false,
      allGenes: [],
      options: [],
      // gene and cancer
      gene: 'LEP',
      cancer: 'BLCA',
      img64: "",
      loading: false,
      cancers: [],
      useUrlImage:true,
      allGene: false,
      Showhelp :false,//控制div块的显示和隐藏
      isTooltipVisible :false,//问号鼠标移入
      tooltipTop: 0, // 提示框距离顶部的距离
      tooltipLeft: 0 // 提示框距离左侧的距离
    }
  },
  methods: {
    // 模糊搜索
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
    async getPic() {
      this.show = true;
      this.loading = true;
      this.useUrlImage = false;
      this.img64 = "";

      try {
        const res = await this.$http.get("/trendapi/plot_trend?gene=" + this.gene);
        const pdfBase64 = res.data.split(",").pop(); // 处理前缀
        this.img64 = await this.renderPdfToPngBase64(pdfBase64);
      } catch (e) {
        this.$message.error("Failed to load PDF");
        console.error(e);
      } finally {
        this.loading = false;
      }
    },

    async renderPdfToPngBase64(base64Pdf) {
      const binary = atob(base64Pdf);
      const uint8Array = new Uint8Array(binary.length);
      for (let i = 0; i < binary.length; i++) {
        uint8Array[i] = binary.charCodeAt(i);
      }

      const pdf = await pdfjsLib.getDocument({ data: uint8Array }).promise;
      const page = await pdf.getPage(1); // 渲染第一页
      const scale = 2;
      const viewport = page.getViewport({ scale });

      const canvas = document.createElement("canvas");
      canvas.width = viewport.width;
      canvas.height = viewport.height;

      const context = canvas.getContext("2d");
      await page.render({ canvasContext: context, viewport }).promise;

      const pngDataUrl = canvas.toDataURL("image/png");
      return pngDataUrl.split(',')[1]; // 只返回 base64 部分
    },
    // getPic() {
    //   this.show = true;
    //   this.loading = true;
    //   this.useUrlImage = false;
    //   this.img64 = "";
    //   this.$http.get("/trendapi/plot_trend?gene=" + this.gene).then(res => {
    //     this.img64 = res.data;
    //     this.loading = false;
    //   });
    // },
    downloadImg() {
      let imgHref = this.api.dzxURL + "/down/surv/" + this.gene + "/" + this.cancer;
      let a = document.createElement('a');
      a.href = imgHref;
      a.click();
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
    //初始化方法
    init(){
      setTimeout(()=>{
        this.$http.get("http://47.97.192.100:8090/adi/gene").then(res => {
          this.allGenes = res.data;
        });
        this.cancers = ["BLCA", "BRCA", "CHOL", "COAD", "ESCA",
          "HNSC", "KICH", "KIRC", "KIRP", "LIHC",
          "LUAD", "LUSC", "PRAD", "READ", "STAD",
          "THCA", "UCEC"];
        this.img64 ="http://tmliang.cn/pic/adi/analysis/LEP_BLCA_surv.png";
        this.useUrlImage = true;
        this.show  = true;

        const img = new Image();
        img.onload = () =>{
          this.loading = false;
        }
        img.src = this.img64;
      },300);//延迟加载
    },
  },
  mounted() {
    this.loading = true;
    this.init();
  },
  activated() {
    this.loading = true;
    this.init();
    console.log('AnalysisCon1 activated ✅');
  },
  deactivated() {
    console.log('AnalysisCon1 activated X')
  }
}
</script>

<style scoped>
#surv{
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
</style>
