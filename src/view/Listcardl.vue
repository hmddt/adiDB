<template>
  <div class="list-detail-body">
<!--    补充：脂肪因子结构-->
<!--这个文件不用 已弃用-->
      <h1 style="text-align: center; margin: 10px;">{{this.rnadata.gene}} Gene Information</h1>
    <div class="list--detail-body-table" v-show="basicShow">
      <table class="list--detail-body-tablebody" >
        <tbody>
        <tr >
          <th>Gene:</th>
          <td style="color: #3a8ee6;"><div style="margin-left: 20px">{{this.rnadata.gene}}</div></td>
        </tr>
        <tr style="background-color: #f6f6f6">
          <th>Related Gene Symbol:</th>
          <td><div style="margin-left: 20px">{{this.rnadata.RelatedGeneSymbol}}</div></td>
        </tr>
        <tr>
          <th>Ensembl:</th>
          <td><div style="margin-left: 20px">{{this.rnadata.Ensembl}}</div></td>
        </tr>
        <tr style="background-color: #f6f6f6">
          <th>Function:</th>
          <td><div style="margin-left: 20px">{{this.rnadata.function}}</div></td>
        </tr>
        <tr>
          <th>ArticleTitle:</th>
          <td><div style="margin-left: 20px">{{this.rnadata.ArticleTitle}}</div></td>
        </tr>
        <tr style="background-color: #f6f6f6">
          <th>YearofPublication:</th>
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
        <tr>
          <th>Pmid:</th>
          <td>
            <button style="color:#3a8ee6;margin-left: 16px; border: 0;font-size:16px;background-color: #ffffff"  :underline="false" @click="clickview" >
              {{this.rnadata.pmid}}
            </button>
          </td>
        </tr>
        </tbody>
      </table>


    </div>

  </div>

</template>

<script>
// 这个文件不用
export default {
  name: "listdetail",
  props:["id","basicShow"],
  created:function (id) {
    this.getrnadata(this.id)//要获取this.id
  },
  data(){
    return{
      rnadata:[]
    }
  },
  methods:{

    clickview:function (){
      window.open('https://pubmed.ncbi.nlm.nih.gov/'+this.rnadata.pmid+'/')
    },
    getrnadata(id){
      this.$http.get("http://47.97.192.100:8090/adi/use/"+id).then((response)=>{
        this.rnadata=response.data
      })
    },
    initViewer() {
      this.viewer = $3Dmol.createViewer("pdb-viewer", { backgroundColor: "white" });
    },
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.renderPDB(e.target.result);
        };
        reader.readAsText(file);
      }
    },
    renderPDB(pdbData) {
      this.viewer.clear();
      this.viewer.addModel(pdbData, "pdb");
      this.viewer.setStyle({}, { cartoon: { color: "spectrum" } });
      this.viewer.zoomTo();
      this.viewer.render();
    }
  },



}
</script>

<style scoped>
body, div, dl, dt, dd, ul, ol, li, h1, h2, h3, h4, h5, h6, pre, form, fieldset, legend, input, textarea, button, p, blockquote, th, td
{margin: 0;}
body{text-align: center;font-family: Helvetica Neue,Helvetica,Arial,Microsoft Yahei,Hiragino Sans GB,Heiti SC,WenQuanYi Micro Hei,sans-serif;}
li{ list-style: none;}
a{text-decoration: none;
  color: #5a5a5a
}
img{border: none;}
.list-detail-body{
  position: relative;
  /*display: flex;*/
  /*flex-direction: column;*/
  /*justify-content: space-between;*/
  left: 0;

  width: 100%;
  height: 45vw;
}
.list--detail-body-table{
  position: relative;
  width: 100%;
  height: 90%;
  border-radius: 5px;
  background-color: #ffffff;
  margin-bottom: 100px;
}
/*表格在div块中的位置*/
.list--detail-body-tablebody{
  position: relative;
  top: 6%;
  left: 3.4%;
  width: 90%;
  height: 98%;
  border: 1px solid #c5c5c5;
  border-collapse: collapse;/*表格合成单一线框*/
}
th{
  text-align:left;
  text-indent: 10px;
  font-size: 16px;
  width: 20%;
  font-weight: initial;
  border: 1px solid #c5c5c5;
  color: #6c6c6c;
}
td{
  width: 70%;
  border: 1px solid #c5c5c5;
  font-size: 16px;
  text-align: left;
  /*text-indent: 7%;*/
  color: #2f2f2f;
}
/*.el-button-viewpaper{*/
/*  position: relative;*/
/*  top:63px;*/
/*  color: #4a91da;*/
/*  border-radius: 7px;*/
/*}*/
/*.el-button-viewpaper:focus{*/
/*  background: #ffffff;*/
/*}*/
</style>
<script setup>
</script>
