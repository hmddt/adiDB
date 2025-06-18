<template>
<!--这个工具用于查看PDB完全样式看，可以根据选项控制PDB的显示-->
  <div class="pdb-container">
    <!--    定位染色体-->

    <div class="reference-sequence">
      <span class="label">Reference Sequence</span>
      <div class="sequence-bar">
        <div v-for="(region, index) in annotations" :key="index"
             class="region"
             :class="region.type"
             :style="{ width: region.width + '%', left: region.start + '%' }">
        </div>
      </div>
    </div>
    <div class="legend">
      <div v-for="(item, index) in legend" :key="index" class="legend-item">
        <span :style="{ background: item.color }" class="legend-color"></span>
        <span>{{ item.label }}</span>
      </div>
    </div>
    <div class="three-mol-detail-1">
<!--      总的框架 包括上方标题
左侧显示页面（上面有黑色标题 下方黑色背景显示框）
右侧 控制台 display：flex-->
      <p class="three-mol-detail-1-p1"> {{this.pdbFileName.replace('.pdb','')}} 3D Structure Detail Display</p>
      <div class="three-mol-detail-1-1d">

      </div>
    </div>
    <div id="pdb-viewer" ref="pdbViewer"></div> <!-- 使用 ref 来引用容器 -->
  </div>
</template>

<script>
export default {
  name: "3DmolDetail",
  props:{
    pdbFileName:{
      type:String,
      required:true,
    }
  },
  data() {
    return {
      viewer: null,
      pdbFileName: "LEP.pdb", // 假设这是外部传入的文件名，可以动态修改
      pdbData: "", // 存储加载的 PDB 数据
      annotations: [
        { type: 'unmodeled', start: 10, width: 20 },
        { type: 'artifact', start: 35, width: 10 },
        { type: 'hydropathy', start: 50, width: 30 },
        { type: 'disorder', start: 70, width: 25 },
        { type: 'disordered-binding', start: 90, width: 20 }
      ],
      legend: [
        { label: 'Unmodeled', color: '#888' },
        { label: 'Artifact', color: '#A52A2A' },
        { label: 'Hydropathy', color: '#4682B4' },
        { label: 'Disorder', color: '#FF6347' },
        { label: 'Disordered Binding', color: '#6A5ACD' }
      ]
    };
  },
  mounted() {
    // 使用 Vue 的 $nextTick 确保容器已经渲染好再初始化 3Dmol
    this.$nextTick(() => {
      this.initViewer(this.pdbFileName);
    });
  },
  methods: {
    // 初始化3DmolViewer
    initViewer(fileName) {
      if ($3Dmol) {
        this.viewer = $3Dmol.createViewer(this.$refs.pdbViewer, {
          backgroundColor: "white",
        });
        this.loadPDBFile(fileName);  // 加载指定的PDB文件
        console.log("3Dmol 加载成功！");
      } else {
        console.error("3Dmol.js is not loaded!");
      }
    },
    // 加载PDB文件
    loadPDBFile(fileName) {
      const filePath = `http://tmliang.cn/pic/adi/PDB/${fileName}`;
      fetch(filePath) // 确保 PDB 文件路径正确
        .then((response) => response.text())
        .then((data) => {
          this.renderPDB(data); // 渲染PDB模型
        })
        .catch((error) => console.error("Failed to load PDB file:", error));
    },
    // 渲染PDB数据
    renderPDB(pdbData) {
      if (!this.viewer) {
        console.error("Viewer is not initialized");
        return;
      }
      this.viewer.clear();  // 清除之前的模型
      this.viewer.addModel(pdbData, "pdb");  // 添加新的PDB模型
      this.viewer.setStyle({}, {
        cartoon: {color: 'spectrum'}
      });
//       this.viewer.setStyle({protein: true}, {
//         cartoon: {color: "spectrum"}  // 仅显示蛋白质 cartoon
//       });
//
// 显示药物的 stick 结构
      this.viewer.setStyle({hetflag: true}, {
        stick: {radius: 0.2, color: "magenta"}  // 药物 stick 结构
      });


      this.viewer.zoomTo();  // 缩放至合适大小
      this.viewer.render();  // 渲染模型

      // 调整容器尺寸，确保图像始终居中显示
      this.adjustViewerSize();
    },

    // 确保3D模型适应容器并居中
    adjustViewerSize() {
      const viewerElement = this.$refs.pdbViewer;
      const viewerWidth = viewerElement.clientWidth;
      const viewerHeight = viewerElement.clientHeight;

      if (this.viewer) {
        this.viewer.zoomTo();  // 自动调整到最佳视角
        this.viewer.render();
      }
    },
  },
}
</script>

<style scoped>
.pdb-container {
  text-align: center;
  margin-top: 20px;
}

#pdb-viewer {
  width: 300px; /* 确保容器有固定的宽度 */
  height: 300px; /* 确保容器有固定的高度 */
  margin: auto;
  position: relative; /* 确保容器中的内容可以居中显示 */
}

/*页面最上方文字显示的样式*/
.three-mol-detail-1-p1{
  font-size: 26px;
  font-weight: bold;
}

/*页面中间模块显示的 左侧为pdb三维结构展示区，右侧为三维结构控制台*/


/*x序列注释*/
.annotation-container {
  padding: 10px;
  background: #fff;
  border-radius: 5px;
}
.reference-sequence {
  margin-top: 10px;
}
.label {
  font-weight: bold;
}
.sequence-bar {
  position: relative;
  height: 20px;
  background: #ddd;
  border-radius: 5px;
  margin-top: 5px;
}
.region {
  position: absolute;
  height: 100%;
  border-radius: 5px;
}
.unmodeled { background: #888; }
.artifact { background: #A52A2A; }
.hydropathy { background: #4682B4; }
.disorder { background: #FF6347; }
.disordered-binding { background: #6A5ACD; }
.legend {
  margin-top: 10px;
  display: flex;
  flex-wrap: wrap;
}
.legend-item {
  display: flex;
  align-items: center;
  margin-right: 15px;
}
.legend-color {
  width: 15px;
  height: 15px;
  display: inline-block;
  margin-right: 5px;
  border-radius: 3px;
}

</style>
