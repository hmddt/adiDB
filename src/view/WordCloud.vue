<!-- WordCloud.vue -->

<template>
  <div>
    <svg  :width="width" :height="height">
      <a class="fontA" v-for="(tag, index) in tags" :key="`tag-${index}`">
        <text
          :id="tag.id"
          :x="tag.x"
          :y="tag.y"
          :data-ensemble-id="tag.ID"
          :data-gene="tag.text"
          :font-size="12 * (600 / (600 - tag.z))"
          :fill-opacity="(400 + tag.z) / 600"
          @mousemove="listenerMove($event)"
          @mouseout="listenerOut($event)"
          @click="clickToPage"
        >
          {{ tag.text }}
        </text>
      </a>
    </svg>
<!--    <el-dialog-->
<!--      :visible.sync="dialogVisible"-->
<!--      modal="false"-->
<!--      width="80%"-->
<!--    >-->
<!--      <div style="border-style: solid; padding: 30px; border-radius: 20px; margin: 100px">-->
<!--        <Listcard ref="result" :id="id" :basicShow="dialogVisible"></Listcard>-->
<!--        <div style="text-align: center; margin-top: 20px">-->
<!--          <span slot="footer" class="dialog-footer" style="position:relative;margin-top: 20px">-->
<!--            <el-button @click="dialogVisible = false">close</el-button>-->
<!--          </span>-->
<!--        </div>-->
<!--      </div>-->
<!--    </el-dialog>-->
  </div>
</template>

<script>
import Listcard from "./Listcardl.vue";

export default {
  name: "WordCloud",
  components: {Listcard},
  props: {
    genes: Array, // 接收 genes 作为 props
  },
  data() {
    return {
      dialogVisible: false,
      ensembleID:"",
      id:'',
      gene:'',
      width: 650,
      height: 600,
      tagsNum: 0,
      RADIUS: 300,
      speedX: Math.PI / 360 / 1.5/2,
      speedY: Math.PI / 360 / 1.5/2,
      tags: [],
      timer: null,
    };
  },
  computed: {
    CX() {
      return this.width / 2;
    },
    CY() {
      return this.height / 2;
    },
  },
  created() {
    if (Array.isArray(this.genes) && this.genes.length > 0) {
      console.log("genes:", this.genes);
      this.initData();
      this.runTags();
    } else {
      console.error("genes is not a valid array or is empty");
    }
  },

  watch: {
    genes: {
      immediate: true, // 立即执行
      handler(newVal) {
        if (Array.isArray(newVal) && newVal.length > 0) {
          this.initData();
          this.runTags();
        }
      },
    },
  },
  methods: {
    initData() {
      let tags = [];
      this.tagsNum = this.genes.length;
      for (let i = 0; i < this.genes.length; i++) {
        let tag = {};
        let k = -1 + (2 * (i + 1) - 1) / this.tagsNum;
        let a = Math.acos(k);
        let b = a * Math.sqrt(this.tagsNum * Math.PI);
        tag.text = this.genes[i].gene;
        tag.ID = this.genes[i].id.toString();
        tag.x = this.CX + this.RADIUS * Math.sin(a) * Math.cos(b);
        tag.y = this.CY + this.RADIUS * Math.sin(a) * Math.sin(b);
        tag.z = this.RADIUS * Math.cos(a);
        tag.id = i;
        tags.push(tag);
      }
      this.tags = tags;
    },
    rotateX(angleX) {
      var cos = Math.cos(angleX);
      var sin = Math.sin(angleX);
      for (let tag of this.tags) {
        var y1 = (tag.y - this.CY) * cos - tag.z * sin + this.CY;
        var z1 = tag.z * cos + (tag.y - this.CY) * sin;
        tag.y = y1;
        tag.z = z1;
      }
    },
    rotateY(angleY) {
      var cos = Math.cos(angleY);
      var sin = Math.sin(angleY);
      for (let tag of this.tags) {
        var x1 = (tag.x - this.CX) * cos - tag.z * sin + this.CX;
        var z1 = tag.z * cos + (tag.x - this.CX) * sin;
        tag.x = x1;
        tag.z = z1;
      }
    },
    runTags() {
      if (typeof this.timer === "number") {
        clearInterval(this.timer);
        this.timer = null;
      }
      let timer = setInterval(() => {
        this.rotateX(this.speedX);
        this.rotateY(this.speedY);
      }, 17);
      this.timer = timer;
    },
    listenerMove(e) {
      if (e.target.id) {
        clearInterval(this.timer);
      }
    },
    listenerOut(e) {
      if (e.target.id) {
        this.runTags();
      }
    },
    clickToPage(e) {
      // // 获取点击的标签的 id
      // const clickedTagId = e.target.id;
      //
      // // 遍历所有标签，设置点击的标签不透明，其他标签透明
      // this.tags.forEach(tag => {
      //   if (tag.id === clickedTagId) {
      //     // 设置点击的标签不透明
      //     tag['fill-opacity'] = 1;
      //   } else {
      //     // 设置其他标签透明
      //     tag['fill-opacity'] = 0.2; // 你可以根据需要调整透明度值
      //   }
      // });
      this.id = e.target.getAttribute("data-ensemble-id");
      this.gene =e.target.getAttribute("data-gene");
      console.log(this.id);
      console.log(this.gene);
      this.$router.push({path:'/listinformation',query: { gene: this.gene}})

    },
  },
  mounted() {
    this.runTags();
  },
};
</script>

<style scoped>
.fontA {
  fill: #50a1b9;
  /*font-weight: bold;*/
}
.fontA:hover {
  fill: rgba(227, 66, 66, 0.92);
  cursor: pointer;
}
</style>
