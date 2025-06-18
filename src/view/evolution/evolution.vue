<template>
<!--进化模块1 vue-->
  <div id="evolution1">
    <br>
    <div class="evolution-geneSelect">
      <span style="margin-right: 10px; font-size: 20px;font-weight: bold">Gene:</span>
<!--      基因选择器，选择的基因列表为有的部分-->
      <el-select v-model="gene" placeholder="Please select a gene.">
        <el-option
        v-for="item in geneOptions"
        :key="item.gene"
        :value="item.gene"
        :label="item.gene"
        style="font-weight: bold"
        >
        </el-option>
      </el-select>
    </div>
    <div class="evolution-container">
      <div  class="evolution-pngcontainer">

        <el-card v-if="isImageLoading" style="text-align:center; padding: 20px;min-height: 700px">
          <span style="font-size: 16px; color: #888;">Loading image...</span>
        </el-card>

        <el-card
          v-show="!isImageLoading"
          class="evolution-pngcontainer-card2"
          ref="leftCard">

          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
            <span style="font-size: 24px; font-weight: bold;margin-left: 15px">{{this.gene}} Evolution Tree</span>
            <div  style="display: flex; align-items: center;">
<!--              <span  :class="{ active: !isRectangularTree }" style="margin-right: 10px;font-size: 16px;color: #3a8ee6">Circular</span>-->
              <el-switch
                v-model="isRectangularTree"
                active-text="Cladogram"
                inactive-text="Circular"
                style="font-size: 16px;font-weight: bold"
                @change="handleTreeTypeChange">
              </el-switch>
            </div>
          </div>

          <img
            v-if="!isRectangularTree"
            :src="'http://tmliang.cn/pic/adi/evolution/' + this.gene + '_CDS_all'+ this.species+'.png'"
            alt="Phylogram Evolution Tree"
            @click="showPreview"
            @load = "onImageLoad"
            @error = "onImageError"
            style="width: 700px; margin-right: 100px; border: 2px solid #ddd; border-radius: 8px;"/>

          <img
            v-else
            :src="'http://tmliang.cn/pic/adi/evolution/' + this.gene + '_tree.png'"
            alt="Rectangular Phylogram Evolution Tree"
            @click="showPreview"
            @load = "onImageLoad"
            @error = "onImageError"
            style="width: 700px; margin-right: 100px; border: 2px solid #ddd; border-radius: 8px;"/>
        </el-card>
      </div>
      <div class="evolution-tablecontainer">
        <!--      表格容器-->
<!--        <el-table-->
<!--          :data="GeneallSpecies"-->
<!--          :height = "tableHeight"-->
<!--          style="width: 400px;border: 2px solid #d0d0d0;border-radius: 15px;font-size: 16px"-->
<!--          ref="speciesTable"-->
<!--        >-->
<!--          <el-table-column prop="index" label="ID" width="100">-->
<!--            <template #default="scope">-->
<!--              {{ scope.$index + 1 }}-->
<!--            </template>-->
<!--          </el-table-column>-->
<!--          <el-table-column prop="species" :label="speciesLabel"></el-table-column>-->

<!--        </el-table>-->
        <el-card>
          <p>Species group distribution map</p>
          <img src="http://tmliang.cn/pic/adi/evolution/wuzhong-0423.png" style="width: 350px"/>
        </el-card>

      </div>
    </div>
    <el-dialog
      :visible.sync="previewVisible"
      top="5vh"
      :modal="true"
      :append-to-body="true"
      custom-class="preview-dialog"
    >
      <img
        :src="previewImage"
        alt="Zoomed Evolution Tree"
        style=" height: 80vh;border-radius: 8px;"
      />
    </el-dialog>

  </div>
</template>

<script>
import geneList from '../../../datajs/evolution/EvolutionGeneList.json'
import allspeciesData from '../../../datajs/evolution/Gene-Species.json'
import ANGPTL4SpeciesData from '../../../datajs/evolution/ANGPTL4Gene-Species.json'
export default {
  name: "evolution",
  data(){
    return{
      gene: 'ANGPTL4' ,
      geneOptions:[],
      species:'38',
      tableHeight:680, //表格高度
      allspeciesData:allspeciesData,
      GeneallSpecies:ANGPTL4SpeciesData,
      isRectangularTree:false,
      isImageLoading: true,
      speciesLabel:"Species name (38 Species)",
      previewVisible: false,
      previewImage: '',

    }
  },
  mounted() {
    this.geneOptions = geneList;
    this.allspeciesData = allspeciesData;
    // 初始加载后设一次高度
    this.updateTableHeight();

    // 窗口大小变化时重设高度
    window.addEventListener("resize", this.updateTableHeight);
  },
  watch:{
    gene(newGene) {
      this.isImageLoading =true;
      const selectedGene = this.geneOptions.find(item => item.gene === newGene);
      this.species = selectedGene ? selectedGene.species : '';
      this.speciesLabel = "Species name (" + this.species+ " Species)"

      // 从本地 JSON 查找
      const geneFromLocal = this.allspeciesData.find(item => item.gene === newGene);
      // 把数组转换为对象数组
      this.GeneallSpecies = geneFromLocal
        ? geneFromLocal.species.map((name, index) => ({ id: index + 1, species: name }))
        : [];



      // 强制重新计算表格布局
      this.updateTableHeight();
    }
},
  beforeDestroy() {
    window.removeEventListener("resize", this.updateTableHeight);
  },
  methods:{
    handleTreeTypeChange(val) {
      this.isRectangularTree = val;
      this.isImageLoading = true;
      this.updateTableHeight();
      // 可以根据需要添加其他逻辑
    },
    onImageLoad() {
      this.isImageLoading = false;
      this.updateTableHeight();
      console.log('图片加载成功');
      // 你可以添加 loading 状态控制、提示用户等逻辑
    },
    onImageError() {
      this.isImageLoading = false;
      console.log('图片加载失败');
      // 显示提示、替换为默认图像，或记录日志
    },
    updateTableHeight() {
      this.$nextTick(() => {
        const card = this.$refs.leftCard;
        if (card) {
          // 获取卡片容器的高度并更新 tableHeight
          this.tableHeight = card.$el.offsetHeight;

          // 强制重新计算表格的布局
          this.$nextTick(() => {
            if (this.$refs.speciesTable && this.$refs.speciesTable.doLayout) {
              this.$refs.speciesTable.doLayout();
            }
          });
        }
      });
    },
    showPreview() {
      this.previewImage = this.isRectangularTree
        ? `http://tmliang.cn/pic/adi/evolution/${this.gene}_tree.png`
        : `http://tmliang.cn/pic/adi/evolution/${this.gene}_CDS_all${this.species}.png`;
      this.previewVisible = true;
    },

  },
 }
</script>

<style scoped>
#evolution1{
width: 1400px;
margin: 0 auto;
  background: #ffffff;

}

.preview-dialog .el-dialog__body {
  padding: 0;
}

.evolution-geneSelect{
  display: flex;
  justify-content: center;
  align-items: center;

}

.evolution-container{
  display: flex;
  margin-top: 50px;
}

.evolution-pngcontainer{
  width: 1200px;
}
.evolution-pngcontainer span{
  font-size: 24px;
  font-weight: bold;
}

.evolution-pngcontainer img{
  margin-top: 20px;
}

.evolution-tablecontainer{
  margin-left: 20px;
  background: #ffffff;
}

</style>
