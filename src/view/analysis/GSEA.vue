<template>
  <div id="gsea">
    <div>
      <!--对mrna表达介绍-->
      <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
        <br>
        <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">ssGSEA
          </span>
          <i class="el-icon-question" style="color: #3a8ee6;cursor: pointer; /* 添加指针样式，表明是可交互的 */" @click="Showhelp = !Showhelp" @mouseenter="showTooltip" @mouseleave="hideTooltip"></i>
        </p>
        <div v-if="isTooltipVisible" :style="{ top: tooltipTop + 'px', left: tooltipLeft + 'px' }" class="tooltip">
          learn more about ssGSEA
        </div>
        <br>
        <div v-show="Showhelp" style="font-size: 13px;line-height: 1.5;color: #4d4d4d">
          <p>
            <span style="color: #e6903a"> > </span>
            <span>
            The function of this module is to analyse differences in 28 immune cell enrichment in specified cancers in patients with varying expression of genes.
          </span>
          </p>
          <p>
            <span style="color: #e6903a"> > </span>
            This module uses the same grouping method as the Survival sub-module, where the tumour samples are divided into groups of high and low expression of the gene, and then ssGSEA analysis is performed based on the set of 28 immune cell genes to obtain the enrichment of the 28 immune cells in the different groups of patients.
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
        <el-button type="primary" class="hover-blue-btn" @click="getPic">Click</el-button>
      </el-form>
    </div>
    <!--结果展示模块-->
    <el-empty description="Wait For Your Click" v-show="!show" style="height: 600px"></el-empty>
    <div v-loading="loading" v-show="show">
      <!--Surv-->
      <el-image
        style=" height: 600px;"
        :src="useUrlImage ? img64 : ('data:image/png;base64,' + img64)"
        fit="contain">
      </el-image>
      <br>
      <el-button type="primary" round @click="downloadImg">Download</el-button>
    </div>
  </div>
</template>

<script>
import ImmuneCon1 from "./immune/immune-con1.vue";
  export default {
    name: "ssGSEA",
    components:{
      ImmuneCon1,
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
        allGene: false,
        Showhelp :false,//控制div块的显示和隐藏
        isTooltipVisible :false,//问号鼠标移入
        tooltipTop: 0, // 提示框距离顶部的距离
        tooltipLeft: 0, // 提示框距离左侧的距离
        useUrlImage:true,
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
      getPic() {
        this.useUrlImage = false;
        this.show = true;
        this.loading = true;
        this.img64 = "";
        this.$http.get(this.api.rURL + "/gsea/" + this.gene + "/" + this.cancer).then(res => {
          this.img64 = res.data;
          this.loading = false;
        });
      },
      downloadImg() {
        let imgHref = this.api.dzxURL + "/down/gsea/" + this.gene + "/" + this.cancer;
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
      init(){
        this.loading = true;
        setTimeout(()=>{
          this.$http.get("http://47.97.192.100:8090/adi/gene").then(res => {
            this.allGenes = res.data;
          });
          this.cancers = ["BLCA", "BRCA", "CHOL", "COAD", "ESCA",
            "HNSC", "KICH", "KIRC", "KIRP", "LIHC",
            "LUAD", "LUSC", "PRAD", "READ", "STAD",
            "THCA", "UCEC"];
          this.img64 = "http://tmliang.cn/pic/adi/analysis/LEP_BLCA_ssgsea.png";
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
          img.src = this.img64;
        },300);
      }
    },
    mounted() {
      this.init();
    },
    activated() {
      this.init();
    }
  }
</script>

<style scoped>
#gsea{
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
