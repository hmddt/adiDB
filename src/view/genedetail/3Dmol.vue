<template>
  <div class="pdb-container">
<!--    定位染色体-->
    <h2>{{this.pdbFileName.replace('.pdb','')}} PDB 3D Structure</h2>
    <div id="pdb-viewer" ref="pdbViewer"></div> <!-- 使用 ref 来引用容器 -->
  </div>
</template>

<script>
export default {
  name: "ThreeDMolViewer",
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
};
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
</style>
