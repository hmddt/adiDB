<template>
  <div id="receptor">
    <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
      <br>
      <p>
          <span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Immunochemokine Receptor Analysis
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
        <el-button type="primary" class="hover-blue-btn" @click="getcheckpointPic">Click</el-button>
      </el-form>
    </div>


    <el-empty description="Wait For Your Click" v-show="!show" style="height: 600px"></el-empty>

    <div v-loading="loading" v-show="show" style="position: relative;"  >
      <div class="checkpoint-left" style=" background-color: #ffffff;height: 600px;">
        <!--免疫检查点图片图片-->
        <el-image
          style="height: 450px;margin-top: 50px"
          :src="useUrlImage ? png64 : ('data:image/png;base64,' + png64)"
          fit="contain">
        </el-image>
        <br>
        <el-button type="primary" round @click="downloadDiffImg">Download</el-button>
      </div>

<!--      <div class="checkpoint-right" style=" position: relative; margin-left: 2%; margin-top:100px;margin-bottom: 140px;padding: 10px;width: 39%; background-color: #ffffff;">-->
<!--        &lt;!&ndash;拿到checkpoint数据&ndash;&gt;-->
<!--        <span style="font-weight: bold;font-size: 15px"> Correlation with receptor </span>-->
<!--        <el-table-->
<!--          :stripe="true"-->
<!--          :data="receptor"-->
<!--          height="500"-->
<!--          border-->
<!--          style="width: 100%;height: 79%;top: 20px">-->
<!--          <el-table-column-->
<!--            prop="gene"-->
<!--            label="gene">-->
<!--          </el-table-column>-->
<!--          <el-table-column-->
<!--            prop="cancer"-->
<!--            label="cancer">-->
<!--          </el-table-column>-->
<!--          <el-table-column-->
<!--            prop="receptor"-->
<!--            label="receptor">-->
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
  name: "receptor",
  data() {
    return{
      png64:"",
      show: false,
      allGenes: [],
      options: [],
      receptor:[],
      // gene and cancer
      gene: 'LEP',
      useUrlImage:true,
      loading: false,
      allGene: false,
      Showhelp :false,//控制div块的显示和隐藏
      isTooltipVisible :false,//问号鼠标移入
      tooltipTop: 0, // 提示框距离顶部的距离
      tooltipLeft: 0, // 提示框距离左侧的距离
    }

  },
  methods:{
    //模糊搜索
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
    //获取免疫检查点图
    getcheckpointPic() {
      this.useUrlImage = false;
      this.show = true;
      this.loading = true;
      this.png64 = "";
      Promise.all([
        this.$http.get("http://47.97.192.100:8989/r/immu/receptor/" + this.gene)
      ]).then(([imgRes, dataRes]) => {
        this.png64 = imgRes.data;
        // 将 loading 设置为 false
        this.loading = false;
      });
    },
    downloadDiffImg(){
      let doc = new jsPDF({
        orientation: 'landscape', // 设置页面横向显示
        unit: 'px', // 使用像素作为单位
        format: [1886, 1028] // 设置页面尺寸
      });

      // 将图片插入到 PDF 文档中
      // 这里的 0, 0 表示图片在 PDF 文档的位置，根据需要进行调整
      doc.addImage('data:image/png;base64,' + this.png64, 'PNG', 0, 0);

      // 保存 PDF 文件
      let filename = this.gene + '_receptor_image.pdf';
      doc.save(filename);
    },
    //将表格内内容下载下来
    downloadDiffDataData(){
      let headerRow = ['Gene', 'Cancer', 'Receptor', 'Cor', 'Sig'];
      //将csv表格内内容格式化
      // let csvContent = headerRow.join(",") + "\n" // 添加标题行
      //   + this.checkpoint.map(row => Object.values(row).join(",")).join("\n");
      let csvContent = headerRow.join(",") + "\n"; // 添加标题行

      // 生成数据行
      let csvData = this.receptor.map(row => {
        // 过滤掉 id 属性，只取需要的属性值
        let { id, ...rowData } = row;
        return Object.values(rowData).join(",");
      });

      csvContent += csvData.join("\n");

      let blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      // 创建下载链接
      let link = document.createElement("a");
      let filename = this.gene+'_receptor.csv'
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
      setTimeout(()=>{
        this.loading = true;
        this.png64 = "http://tmliang.cn/pic/adi/analysis/LEP_receptor_image.png";
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
      },500)
    },

  },
  mounted() {
    setTimeout(()=>{
      this.$http.get("http://47.97.192.100:8090/adi/gene").then(res => {
        this.allGenes = res.data;
      });
    },200);
    this.init();
  },
  activated() {
    setTimeout(()=>{
      this.$http.get("http://47.97.192.100:8090/adi/gene").then(res => {
        this.allGenes = res.data;
      });
    },200);
    this.init();
  }
}
</script>

<style scoped>
#receptor{
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
