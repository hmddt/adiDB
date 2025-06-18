<template>
<div id="home">
  <!--首页背景-->
  <div   class="app-backimg">
    <div class="app-backing-img">
      <div class="blur-background">
        <div class="blur-background-1" style="text-align: left; margin-bottom: 40px; margin-top: -20px;">

          <div style="display: flex">
            <img src="../assets/home/logo/favicon.png" style="max-height: 200px;">
            <p style="margin-top: 65px">
              <span
                style="color: #2a5eaa;font-size: 54px;   -webkit-background-clip: text;  line-height: 1.2;font-weight:bold">
                Welcome to  &nbsp;<span style="color: #2a5eaa">Adipokine</span><span style="color: #6B1E6B">Dis</span>
                <!--      名字不涉及DB-->
              </span>
            </p>
            <p
              style="font-size: 36px; color: #2d3436; font-weight: bold; line-height: 1.4; text-shadow: 1px 1px 5px rgba(0, 0, 0, 0.1);">

            </p>
          </div>
          <!-- 优化标题样式 -->
          <div style="margin-left: 30px">
            <p
              style="font-size: 18px; line-height: 1.6; letter-spacing: 0.6px; margin-top: -10px; font-weight: bold; text-align: justify; color: #2d3436;">
              <span style="color: #3a8ee6; font-weight: bold;">Adipokines</span>, released by adipose tissue, have a critical role in multiple biological processes,
              physiological and pathophysiological processes. AdipokineDis, focusing on adipokines
              and diseases based on the molecular features of adipokines, especially for canonical
              and novel adipokines (ncRNAs), provides insights into disease progression and therapeutic
              potential, aiming to accelerate drug development and facilitate personalized treatment
              strategies based on adipokine profiles.

            </p>
          </div>

        </div>
        <div class="app-backing-img-text">
          <!---搜索框，搜索脂肪细胞因子-->
          <div class="home-select">
            <div style="padding: 20px;">
              <span style="font-size: 22px;color: #151515;margin-left:0;font-weight: bold">Gene/Protein Search:</span>
              <div style="margin-top: 10px; text-align: left">
                <el-select
                  v-model="gene"
                  filterable
                  remote
                  placeholder="please enter gene symbol"
                  :remote-method="remoteMethod"
                  style="width: 700px"
                >
                  <!-- remote-method封装好的钩子函数。当用户在输入框中输入内容的时候，会触发这个函数的执行，
                  把输入框对应的值作为参数带给回调函数，loading的意思就是远程搜索的时候等待的时间，即：加载中-->
                  <el-option
                    v-for="option in options"
                    :label="option"
                    :value="option"
                    :key="option">
                  </el-option>
                </el-select>
                <el-button class="hover-blue-btn" type="primary" style="height: 4%;margin-left: 10px" @click="SearchGene">Search</el-button>
              </div>
              <div style="text-align: left;margin-top: 20px">
          <span style="font-size: 15px;margin-left: 0%;font-weight: bold;color: #3a8ee6">Examples:
        </span>
                <span style="font-size: 13px;font-weight: bold;cursor: pointer" @click="examplesgene('LEP')" @mouseenter="examplesstyle1 = true" @mouseleave = "examplesstyle1 =false"
                      :class="{'examplesstyle': examplesstyle1}">LEP</span>
                <span> , </span>
                <span style="font-size: 13px;font-weight: bold;cursor: pointer" @click="examplesgene('RBP4')" @mouseenter="examplesstyle2 = true" @mouseleave = "examplesstyle2 =false"
                      :class="{'examplesstyle': examplesstyle2}">   RBP4</span>
            </div>

            </div>
          </div>
        </div>
      </div>
      <div class="card-container">
        <el-card class="but-card" >
          <p style="color: #313131">Canonical adipokines</p>
          <hr>
          <p style="color: #153570;font-size: 28px;">99</p>

          <!--        <div  style="padding: 5px;width: 100px;height: 100px"></div>-->
        </el-card>
        <el-card class="but-card" >
          <p style="color: #313131">Novel adipokines (ncRNAs)</p>
          <hr>
          <p style="color: #153570;font-size: 28px;margin-top: -3px">61</p>
          <!--        <div  style="padding: 5px;width: 100px;height: 100px"></div>-->
        </el-card>
        <el-card class="but-card" >
          <p @click="ClickHomeCard('browser')">Browse</p>
          <hr>
          <img src="../assets/home/Browse-min.png" style="padding: 5px;width: 100px;height: 100px" @click="ClickHomeCard('browser')">
          <!--        <div  style="padding: 5px;width: 100px;height: 100px"></div>-->
        </el-card>
        <el-card  class="but-card">
          <p @click="ClickHomeCard('analysis')">Multiomics</p>
          <hr>
          <img src="../assets/home/Multimics-min.png" style="padding: 5px;width: 100px;height: 100px" @click="ClickHomeCard('analysis')">
          <!--        <div  style="padding: 5px;width: 100px;height: 100px"></div>-->
        </el-card>
        <el-card class="but-card">
          <p @click="ClickHomeCard('TF')">Network</p>
          <hr>
          <img src="../assets/home/Network.png" style="padding: 5px;width: 100px;height: 100px" @click="ClickHomeCard('TF')">
          <!--        <div  style="padding: 5px;width: 100px;height: 100px"></div>-->
        </el-card>
        <el-card class="but-card">
          <p @click="ClickHomeCard('evolution1')">Evolution</p>
          <hr>
          <img src="../assets/home/Evolution-min.png" style="padding: 5px;width: 100px;height: 100px" @click="ClickHomeCard('evolution1')">
          <!--        <div  style="padding: 5px;width: 100px;height: 100px"></div>-->
        </el-card>
      </div>

    </div>
    <br>
  </div>
  <div>

    <div class="app-backing-img-but">
      <div class="app-backing-img-but-card1">


        <!-- 预览图 -->
        <img
          v-if="!imgLoaded"
          :src="previewSrc"
          alt="Preview"
          style="width: 13500px; filter: blur(8px); transition: opacity 0.3s;" />

        <!-- 高清图加载完成后替换 -->
        <img
          :src="fullSrc"
          alt="Gene Expression Profile"
          style="width: 1350px;"
          @load="imgLoaded = true"
          :style="{ opacity: imgLoaded ? 1 : 0, transition: 'opacity 0.5s ease' }" />
        <div >
          <p class="img-title"><span>Adipogenesis Mechanism Diagram </span></p>
        </div>
      </div>

    </div>

    <div class="app-backing-img-mid-card1">
      <el-carousel :interval="0" arrow="always"  height="480px" indicator-position="none">
        <el-carousel-item v-for="(group, index) in groupedImages[0]" :key="index">
          <div class="carousel-slide">
            <div class="image-block" v-for="img in group" :key="img.src">

                <img v-lazy="img.src" :alt="img.alt"  class="carousel-image" @click="openImageDialog(img)" />

              <p class="img-title">{{ img.title }}</p>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>

      <el-carousel :interval="0" arrow="always"  height="600px" indicator-position="none">
        <el-carousel-item v-for="(group, index) in groupedImages[1]" :key="index">
          <div class="carousel-slide1">
            <div class="image-block" v-for="img in group" :key="img.src">

<!--              <img :src="img.src" :alt="img.alt"  class="carousel-image" @click="openImageDialog(img)" />-->
              <img v-lazy="img.src" :alt="img.alt"  class="carousel-image" @click="openImageDialog(img)" >

              <p class="img-title">{{ img.title }}</p>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>

      <!-- 弹窗预览 -->
      <el-dialog
        :visible.sync="imageDialogVisible"
        width="60%"
        top="5vh"
        :modal-append-to-body="true"
        :close-on-click-modal="true"
        class="image-preview-dialog"
      >
        <img :src="currentImage.src" :alt="currentImage.alt"  class="dialog-image" style="width: 100%; border-radius: 12px;" />
      </el-dialog>
    </div>


    <!--    染色体定位-->
    <div style="background: white;">
      <div>
        <p class="img-title" style="font-size: 20px;margin-top: -140px;z-index: 999" ><span >Chromosomal Localization Map </span></p>
        <p style="text-align: center; font-size: 13px; color: #999; margin-top: 0; padding-right: 10px;">
          * Clicking on the nodes in the dyeing diagram allows you to see the specific information of the current gene.
        </p>
      </div>

      <div class="svg-container1">
        <div  style="height: 640px;width: 600px;background: #ffffff;margin-left: -60px">
          <chromosome
            @gene-clicked = "handleGeneClick"
            style="max-height: 1000px ;" ></chromosome>
        </div>

        <!--{ "name" "Ensembl" "Function", "PMID""Chr""Start" "End", "Type"}-->
        <div style="margin-left: 30px;height: 700px;width: 600px" >
          <table border="1" cellpadding="8" cellspacing="0" class="svg-container1-table" >
            <thead>
            <tr>
              <th colspan="2">{{ this.chromeGene.name }} Basic Information</th>
            </tr>
            </thead>
            <tbody>
            <tr>
              <td style="width: 150px">Gene Symbol</td>
              <td>{{ this.chromeGene.name }}</td>
            </tr>
            <tr>
              <td>Protein</td>
              <td>{{ this.chromeGene.Protein || 'N/A' }}</td>
            </tr>
            <tr>
              <td>Ensembl ID</td>
              <td>{{ this.chromeGene.Ensembl }}</td>
            </tr>
            <tr>
              <td>Function</td>
              <td style="height:160px">{{ this.chromeGene.Function }}</td>
            </tr>
            <tr>
              <td>Chromosome</td>
              <td>{{ this.chromeGene.Chr }}</td>
            </tr>
            <tr>
              <td>Start</td>
              <td>{{ this.chromeGene.Start }}</td>
            </tr>
            <tr>
              <td>End</td>
              <td>{{ this.chromeGene.End }}</td>
            </tr>
            <tr>
              <td>Type</td>
              <td>{{ this.chromeGene.Type }}</td>
            </tr>
            </tbody>
          </table>

        </div>
      </div>

    </div>

  </div>




  <el-dialog
    title="Gene basic  information"
    :visible.sync="centerDialogVisible"
    width="50%"
    center>
    <div v-if="selectedGene">
      <p><strong style="font-size: 16px">Gene Name:</strong> {{selectedGene.name}} </p>
      <br>
      <p><strong style="font-size: 16px">Ensembl:</strong>{{selectedGene.Ensembl}}</p>
      <br>
      <p><strong style="font-size: 16px">Function:</strong>{{selectedGene.Function}}</p>
      <br>
      <p><strong style="font-size: 16px">PMID:</strong>{{selectedGene.PMID}}</p>
    </div>
    <div style="text-align: center; margin-top: 20px">
          <span slot="footer" class="dialog-footer" style="position:relative;margin-top: 20px">
            <el-button  @click="centerDialogVisible = false">close</el-button>
          </span>
    </div>
  </el-dialog>

</div>
</template>

<script>
import WordCloud from "./WordCloud.vue";
import * as THREE from 'three'
import BIRDS from 'vanta/src/vanta.birds'
import WordCloud2 from "./genedetail/wordCloud2.vue";
import adiDiseaseJson from "./../../datajs/adi-disease.json"
import chromeadigene from "./../../datajs/chromeadigene/chromeadigene.json"
import Chromosome from "./svg/chromosome.vue";

export default {
  name: "home",
  components:{
    Chromosome,
    WordCloud2,
    WordCloud,
  },
  data() {
    return{
      allgene:[],//全部脂肪细胞因子
      options:[],
      adiDisease:[],//初始化获取词云json文件  ，数据格式：name   vlaue
      gene:'',
      allGeneData:[],
      centerDialogVisible :false,
      selectedGene : null,
      examplesstyle1 : false, //示例1鼠标移入效果
      examplesstyle2 : false, //示例2鼠标移入效果
      chromeGene:[],
      chromeadigene:[],
      foundChromeGene:[],
      imgLoaded: false,
      previewSrc: "http://tmliang.cn/pic/adi/homeimg/机制图-min.png", // 模糊预览图
      fullSrc: "http://tmliang.cn/pic/adi/homeimg/机制图-1.png",         // 高清图


      imageDialogVisible: false,
      currentImage: {},
      previewImages: [
        {
          src: "http://tmliang.cn/pic/adi/homeimg/Fasn-evolution.png",
          alt: "FASN",
          title: "FASN Evolution"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/首页-人体+表达1.png",
          alt: "Expression",
          title: "Human Body Expression"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/糖尿病-细胞.png",
          alt: "Diabetes Cell",
          title: "Diabetes Cell Expression"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/肝癌-细胞.png",
          alt: "Liver Cancer Cell",
          title: "Liver Cancer Cell Expression"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/mmu-chromosome.png",
          alt: "mmu Chromosome",
          title: "mmu Chromosome"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/ncRNA-network.png",
          alt: "ncRNA network",
          title: "ncRNA network"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/node-TF.png",
          alt: "TF network",
          title: "TF network"
        },
        {
          src: "http://tmliang.cn/pic/adi/homeimg/sl-node.png",
          alt: "Synthetic Lethality Network",
          title: "Synthetic Lethality Network"
        }
      ],
      previewImages2: [

      ],


    }

  },
  methods:{
    remoteMethod(query) {
      // 如果用户输入内容了，就发请求拿数据，远程搜索模糊查询
      if (query !== "") {
        this.options = this.allgene.filter((item) => {
          // 大于-1说明只要有就行，不论是不是开头也好，中间也好，或者结尾也好
          return item.toLowerCase().indexOf(query.toLowerCase()) > -1
        })
      } else {
        this.options = [];
      }
    },
    examplesgene(example){
      this.gene = example;
    },
    SearchGene(){
      this.$router.push({path:'/listinformation',query: { gene: this.gene}})
    },
    ClickHomeCard(cardName){
      this.$router.push({path:'/'+cardName});
    },
    handleGeneClick(geneName){
      const foundGene = this.allGeneData.find(
        (gene) => gene.gene === geneName
      );
      const foundChromeGene =this.chromeadigene.find(item => item.Gene === geneName);
      if (foundGene && foundChromeGene) {
        this.chromeGene = {
          name: foundGene.gene,
          Protein: foundGene.protein,
          Ensembl: foundGene.Ensembl,
          Function: foundGene.Function,
          Chr :foundChromeGene.Chr,
          Start :foundChromeGene.Start,
          End:foundChromeGene.End,
          Type:foundChromeGene.Type,

        };
      } else {
        this.$message.error(`Gene "${geneName}" not found in database.`);
        // this.chromeGene = foundGene;

      }
    },
    openImageDialog(img) {
      this.currentImage = img;
      this.imageDialogVisible = true;
    },
  },
  computed: {
    groupedImages() {
      const chunkSize = 4;
      const firstHalf = this.previewImages.slice(0, 4);
      const secondHalf = this.previewImages.slice(4);

      const chunk = arr => {
        const result = [];
        for (let i = 0; i < arr.length; i += chunkSize) {
          result.push(arr.slice(i, i + chunkSize));
        }
        return result;
      };

      return [chunk(firstHalf), chunk(secondHalf)];
    }
  },

  mounted() {
    this.adiDisease = adiDiseaseJson;
    this.chromeadigene = chromeadigene;
    this.chromeGene={"name": "LEP",
      "Protein": "Leptin",
      "Ensembl": "ENSG00000174697",
      "Function": "Leptin activates anorexigenic and orexigenic neurons that are responsible for the inhibition and stimulation of feeding, respectively",
      "Chr": "7",
      "Start": "128241278",
      "End": "128257629",
      "Type": "protein_coding"};
    this.$http.get('http://47.97.192.100:8090/adi/gene').then(res => {
      this.allgene = res.data;
    });
    this.$http.get('http://47.97.192.100:8090/adi/allToAbstract/full').then(res => {
      this.allGeneData = res.data
    });
    this.vantaEffect = BIRDS({
      el: this.$refs.vantaRef,
      THREE: THREE,
      backgroundColor: 0xeeeeee , // 设置透明背景
      mouseControls: true,
      touchControls: true,
      gyroControls: false,
      birdSize: 1.40,
      wingSpan: 16.00,
      speedLimit: 3.00,
      separation: 23.00,
      alignment: 24.00,
      cohesion: 16.00,
      quantity: 2.00,
    });


  },
  beforeDestroy() {
    if (this.vantaEffect) {
      this.vantaEffect.destroy()
    }
  }
}
</script>

<style scoped>

#home{
  position: relative;
  width: 1400px;
  margin:0 auto;
  background: white;
  /*background: #fafcfd;*/
}
.app-backimg{
  width: 100%;
  height: 600px;
  background-image: url("../assets/backimg5.png");
  background-size: cover;

}

.app-backing-img{
  /*height: 250px;*/
  width: 1400px;
  display: flex;
  justify-content: center; /* 水平居中 */
  /*align-items: center; !* 垂直居中 *!*/
  margin: 0 auto;

  /*background-color: rgb(241, 238, 233);*/
  border-radius: 20px;
}

.blur-background {
  height: 600px;
  margin-top: 30px;
  /*position: relative;*/

  /*z-index: 2; !* 保证内容位于模糊背景之上 *!*/
  /*background-image: url("../assets/home/Fasn-evolution.png");*/
  /*background-size: contain;*/
  /*background-position: right; !* 居中对齐 *!*/
  /*background-repeat: no-repeat; !* 防止重复 *!*/
  /*!*background: rgba(255, 255, 255,0.4); !* 半透明背景 *!*!*/
  /*backdrop-filter: blur(300px); !* 应用模糊效果 *!*/

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

.blur-background-1{
  width: 900px;
  position: relative;
  cursor: default;
}


.app-backing-img-text{
  position: relative;
  margin: -40px auto;
  /*搜索框格式*/
  display: flex;

  border-radius: 15px;
  height: 200px;
  align-items: center;
}

.home-select{
  width: 890px;
  text-align: left;
  margin-left: 10px;
  /*background: #e5ecf1;*/
  background: radial-gradient(circle at left, #e5ecf1, #dce9f3);
  border-radius: 20px;
  border: 2px solid #dce9f3;
}

/*下方组件格式*/

.but-card p{
  font-weight: bold;
}
.card-container {
  display: flex;
  margin-left: 50px;
  margin-top: 50px;
  width: 400px;
  cursor: pointer;
  height: 400px;
  flex-wrap: wrap; /* 允许换行 */
  gap: 20px; /* 卡片之间的间距 */
  justify-content: center; /* 水平居中 */
}


.but-card {
  flex: 1 1 calc(50% - 20px); /* 每行两个卡片，减去 gap 的值 */
  height: 150px;
  max-width: 150px; /* 限制卡片的最大宽度 */
  text-align: center; /* 文本居中 */
  display: flex;
  flex-direction: column; /* 垂直排列内容 */
  justify-content: center; /* 垂直居中 */
  align-items: center;
  background: linear-gradient( to top,#fff, #fbfbff);
  border-radius: 16px;
  border: 2px solid #2a5eaa !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 增加阴影效果 */
}

.but-card p {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 10px;

}

.but-card hr {
  width: 80%;
  border: 0;
  height: 1px;
  background: #ddd;
}
.but-card p{
  cursor: pointer;
}
.svg-container1{
  display: flex;
  padding: 10px 0;
  /*margin-top: -120px;*/
  justify-content: center;
  position: relative;
  height: 670px;
  background: #ffffff;
}
.svg-container1-table {
  width: 700px;
  cursor: default;
  margin-top: 60px;
  border-collapse: collapse;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 14px;
  background-color: #fff;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border-radius: 8px;
  overflow: hidden;
}

.svg-container1-table thead th {
  background-color: #2a5eaa; /* Element UI 蓝色 */
  color: white;
  font-weight: 600;
  text-align: left;
  padding: 12px;
  font-size: 24px;
}

.svg-container1-table td {
  padding: 12px;
  font-size: 18px;
  text-align: left;
  border: 2px solid #ebeef5;
  color: #606266;
}

.svg-container1-table tr:nth-child(even) td {
  background-color: #f9f9f9;
}

.svg-container1-table tr:hover td {
  background-color: #f0f9ff;
}

.app-backing-img-but {
  width: 100%;
  position: relative;
  background: white;
  display: flex;
  justify-content: center; /* 让子元素水平居中 */
  border-radius: 2px;
  margin: 0 auto;
  align-items: center;
}

.app-backing-img-but-card1 {
  max-width: 1500px;
  width: 100%;
  padding: 20px;
  text-align: center; /* 内容居中 */
}

.app-backing-card1-p{
  text-align: center;
  font-size: 26px;
  font-weight: 600;
  margin-left: 78px;
  color: #2b6cb0;
}


.app-backing-img-mid-card1 {
  padding: 10px 0;
  min-height: 320px;
  width: 100%;
  max-width: 1600px;
  margin: -30px auto;
  box-sizing: border-box;
  display: flow-root;
}


.carousel-slide {
  display: flex;
  justify-content: center;
  gap: 30px;
  padding: 60px 0 0 0;

  overflow: hidden;
}
.carousel-slide1 {
  display: flex;
  justify-content: center;
  gap: 30px;
  overflow: hidden;
}

.image-block {
  flex: 1 1 22%;
  max-width: 22%;
  height: 400px;
  display: flex;
  background: white;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
}

/*.image-wrapper {*/
/*  width: 100%;*/
/*  height: 500px; !* 统一高度，防止跳动 *!*/
/*  display: flex;*/
/*  align-items: center;*/
/*  justify-content: center;*/
/*  background-color: #fafafa;*/
/*  border-radius: 12px;*/
/*  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);*/
/*  overflow: hidden;*/
/*}*/
.carousel-image {
  width: 100%;
  height: 500px;
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: transform 0.3s ease;
  cursor: pointer;
}

.carousel-image:hover {
  transform: scale(1.05);
}


.image-wrapper img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  transition: transform 0.3s ease;
}

.image-wrapper img:hover {
  transform: scale(1.05);
}

.img-title {
  margin-top: 12px;
  font-size: 15px;
  font-weight: 600;
  color: #333;
  text-align: center;
  word-break: break-word;
  line-height: 1.4;
}

.dialog-image {
  display: block;
  margin: 0 auto;
  max-height: 80vh;   /* 限制最大高度为视口高 */
  max-width: 100%;
  object-fit: contain;
  border-radius: 12px;
}


</style>
