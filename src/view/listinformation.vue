<template>
  <div id="listInformation">
    <br>
    <!-- 加载页面 -->
    <div v-if="loading" class="loading-screen">
      <div class="loading-message"><i class="el-icon-loading"></i></div>
    </div>
    <!-- 基因信息展示部分 -->
    <div v-else class="list-detail-body">
      <div style=" height: 40px; width: 550px; margin-left: 20px; margin-bottom: 30px; display: flex; align-items: center;">
        <h1 style="text-align: left;margin-left: 10px;">
          <span style="font-style: italic;">{{this.rnadata.gene}}</span>
          Gene Information
        </h1>
      </div>

<!--      将基因名字作为参数传递给3Dmol-->
      <div class="list--detail-body-table">

        <div class="basic-information">
          <!--        这个表格是基础信息的表格-->
          <div class="basic-information-table">
            <p style="margin-left: 50px;font-size: 24px">{{this.rnadata.gene}} Gene Basic Information</p>
            <table class="list--detail-body-tablebody">
              <tbody>
              <tr>
                <th>Gene:</th>
                <td>
                  <button style="color:#3a8ee6;margin-left: 16px; border: 0;font-size:16px;background-color: #ffffff;font-weight: bold;font-size: 18px"  :underline="false" @click="genecard">
                    {{this.rnadata.gene}}
                  </button>
                </td>
              </tr>
              <tr style="background-color: #fff">
                <th>Related Gene Symbol:</th>
                <td><div style="margin-left: 20px">{{this.rnadata.RelatedGeneSymbol}}</div></td>
              </tr>
              <tr style="background-color: #f6f6f6">
                <th>Species:</th>
                <td><div style="margin-left: 20px;font-style: italic">{{this.rnadata.Species}}</div></td>
              </tr>
              <tr>
                <th>Ensemble ID:</th>
                <td style="color: #3a8ee6;">
                  <button style="color:#3a8ee6;margin-left: 16px; border: 0;font-size:16px;background-color: #ffffff"  :underline="false" @click="genecard">
                    {{this.rnadata.ensembl}}
                  </button>
                </td>
              </tr>
              <tr style="background-color: #f6f6f6">
                <th>Function:</th>
                <td><div style="margin-left: 20px">{{this.rnadata.function}}</div></td>
              </tr>
              <tr>
                <th>Article Title:</th>
                <td><div style="margin-left: 20px">{{this.rnadata.ArticleTitle}}</div></td>
              </tr>
              <tr style="background-color: #f6f6f6">
                <th>Year of Publication:</th>
                <td><div style="margin-left: 20px">{{this.rnadata.YearofPublication}}</div></td>
              </tr>
              <tr>
                <th>Abstract:</th>
                <td>
                  <div style="margin-left: 20px">
                    {{this.rnadata.Abstract}}
                  </div>
                </td>
              </tr>
              <tr style="background-color: #f6f6f6">
                <th>PMID:</th>
                <td>
                  <button style="color:#3a8ee6;margin-left: 16px; border: 0;font-size:16px;background-color: #f6f6f6"  :underline="false" @click="clickview">
                    {{this.rnadata.pmid}}
                  </button>
                </td>
              </tr>
              </tbody>
            </table>
            <br/>
          </div>

          <div class="threeDmol-container">
<!--            3D结构视图-->
            <ThreeDMolViewer :pdbFileName = "this.rnadata.gene + '.pdb'"></ThreeDMolViewer>
          </div>

        </div>
        <br>
        <div class="expression-information" v-show="!hasMGI">
          <p style="margin-left: 50px;font-size: 24px">Expression Information of Adipose Tissues</p>
          <div style="  display: flex;justify-content: center;padding: 30px">

            <!--          右边放基因表达谱-->
            <div style="text-align: center;height: 520px;background: #ffffff;border: 2px solid #ddd; border-radius: 8px; box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.2);" >
              <p style="font-size: 22px"><span > Average Expression of {{this.rnadata.gene}} in Two Adipose Tissue</span></p>
              <img :src="'http://tmliang.cn/pic/adi/Rresult/gene_expression/Expression_' + this.rnadata.gene + '.png'"
                   alt="Gene Expression Profile"
                   style=" height:450px;"/>
            </div>
            <div style="height: 500px;width: 400px;margin-left: 100px">
              <nasvg ></nasvg>
            </div>
          </div>

        </div>
        <div class="disease-information" v-show="!hasMGI">
<!--          <p>不同疾病中基因表达：现考虑包含  Breast Cancer 、-->
<!--          Colorectal Cancer-->
<!--          Endometrial Cancer-->
<!--          Liver Cancer-->
<!--          prostate cancer-->
<!--          Diabetes-->
<!--          表达有两类：单基因 ，以及所有脂肪因子相关基因表达热图（可切换查看 默认先展示单基因）</p>-->
          <div class="disease-list">
            <!-- 横向滚动显示所有疾病 -->
<!--            <div-->
<!--              v-for="(disease, index) in diseases"-->
<!--              :key="index"-->
<!--              :class="['disease-item', { active: selectedDisease === disease }]"-->
<!--              @click="selectDisease(disease)"-->
<!--            >-->
<!--              {{ disease }}-->
<!--            </div>-->

            </div>
          <div >
            <img :src="'http://tmliang.cn/pic/adi/browse/expression/'+ this.rnadata.gene+'_expression.png'"
                 style="width: 1300px;">
          </div>

        </div>
<!--        <div class="drug-information">-->
<!--          如果有药物相关则展示  药物为肥胖类相关药物 ，第一部分介绍药物-->
<!--          第二部分展示分子对接（如果有）-->
<!--        </div>-->
      </div>
      <br/>
    </div>
  </div>

</template>

<script>
import nasvg from "./svg/nasvg.vue";
import Nasvg from "./svg/nasvg.vue";
import ThreeDMolViewer from "./genedetail/3Dmol.vue"
export default {
  name: "listinformation",
  components: {ThreeDMolViewer, Nasvg},
  created:function () {
    this.getadidata(this.$route.query.gene);
  },
  methods: {
    clickview: function () {
      window.open('https://pubmed.ncbi.nlm.nih.gov/'+this.rnadata.pmid+'/')
    },
    genecard: function () {
      if (this.rnadata.ensembl.includes("MGI")) {
        window.open(`https://www.informatics.jax.org/quicksearch/summary?queryType=exactPhrase&query=`+this.rnadata.ensembl);
      } else {
        window.open (`https://www.genecards.org/cgi-bin/carddisp.pl?gene=`+this.rnadata.gene);
      }
    // window.open('https://www.genecards.org/cgi-bin/carddisp.pl?gene='+this.rnadata.ensembl)
    },
    getadidata: function (gene) {
      this.loading = true; // 开始加载数据时设置为true
      this.$http.get("http://47.97.192.100:8090/r/tissueExpression/"+gene).then((res)=>{
        this.imgsrv = res.data;
        }
      )
      this.$http.get("http://47.97.192.100:8090/adi/usegene/"+ gene).then((res) => {
        this.rnadata = res.data;
        this.loading = false; // 数据加载完毕，设置为false
      }).catch((error) => {
        console.error(error);
        this.loading = false; // 即使发生错误，也需要关闭加载状态
      });
    },
    selectDisease(disease) {
      this.selectedDisease = disease;  // 选择疾病
    },
    toggleExpressionType(type) {
      this.expressionType = type;  // 切换基因表达类型
    },
  },
  data() {
    return {
      rnadata: [],
      diseases: [
        'Breast Cancer',
        'Colorectal Cancer',
        'Endometrial Cancer',
        'Liver Cancer',
        'Prostate Cancer',
        'Diabetes'
      ],  // 所有疾病
      selectedDisease: 'Breast Cancer',  // 默认选择乳腺癌
      expressionType: 'single',  // 默认展示单基因
      loading: true, // 初始化为true，表示正在加载
      imgsrv:'',
    }
  },
  computed: {
    hasMGI() {
      return this.rnadata.ensembl && this.rnadata.ensembl.includes("MGI");
    }
  }

}
</script>

<style scoped>
#listInformation {
  position: relative;
  width: 1400px;
  margin: 0 auto;
  background-color: #ffffff;
  text-align: left;
}

/* 加载页面的样式 */
.loading-screen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.loading-message {
  font-size: 24px;
  color: #333;
}

/* 表格样式 */
.list--detail-body-table {
  position: relative;
  width: 1250px;
  border-radius: 5px;
  background-color: #ffffff;
  margin-bottom: 100px;
}

.list--detail-body-tablebody {
  position: relative;
  top: 6%;
  left: 3.4%;
  width: 980px;
  height: 98%;
}

th {
  text-align: left;
  text-indent: 10px;
  font-size: 16px;
  width: 20%;
  font-weight: initial;
  color: #6c6c6c;
}

td {
  width: 70%;
  font-size: 16px;
  text-align: left;
  color: #2f2f2f;
}

button:hover {
  text-decoration: underline; /* 添加下划线 */
}

/*基础信息表格样式*/
.basic-information{
  display: flex;
  width: 1400px;
  align-items: flex-start;
  border-radius: 15px;
  border: 1px solid #ebeef5; /* el-card 的边框颜色 */
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1); /* el-card 的阴影 */
  background-color: #ffffff; /* el-card 的背景色 */
  transition: box-shadow 0.3s; /* 提升交互体验 */
}


.expression-information{

  border-radius: 15px;
  width: 1400px;
  border: 1px solid #ebeef5; /* el-card 的边框颜色 */
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1); /* el-card 的阴影 */
  background-color: #ffffff; /* el-card 的背景色 */
  transition: box-shadow 0.3s; /* 提升交互体验 */
}

.drug-information{
  min-height: 500px;
  border-radius: 15px;
  min-width: 1400px;
  border: 1px solid #ebeef5; /* el-card 的边框颜色 */
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1); /* el-card 的阴影 */
  background-color: #ffffff; /* el-card 的背景色 */
  transition: box-shadow 0.3s; /* 提升交互体验 */
}

.disease-information{
  min-height: 500px;
  border-radius: 15px;
  margin-top: 30px;
  min-width: 1400px;
  border: 1px solid #ebeef5; /* el-card 的边框颜色 */
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1); /* el-card 的阴影 */
  background-color: #ffffff; /* el-card 的背景色 */
  transition: box-shadow 0.3s; /* 提升交互体验 */
}



.threeDmol-container {
  width: 400px;      /* 设置 3D 视图的固定宽度 */
  height: 400px;     /* 设置 3D 视图的固定高度 */
  border: 1px solid #e6e6e6;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 85px;
  margin-left: 40px;
  /*background-color: #f0f2f5;  !* 增加背景色，便于观察布局 *!*/
}

/*基因疾病模块样式 */
.disease-list {
  display: flex;
  overflow-x: auto;
  cursor: pointer;
  height: 100%;
  margin-left: 20px;
}
.disease-item.active {
  color: #3a3a3a;  /* 白色文字 */
  font-weight: bold; /*选中时加粗*/
  font-size: 17px;

}



</style>
