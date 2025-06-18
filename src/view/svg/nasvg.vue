<template>
  <div class="chart-container">
    <div ref="svgContainer" class="svg-container"></div>
    <!-- 提示框 -->
    <div
      v-if="tooltip.visible"
      :style="{ top: `${tooltip.y}px`, left: `${tooltip.x}px` }"
      class="tooltip"
    >
      {{ tooltip.text }}
    </div>
    <p> <span>Normal human adipose tissue</span></p>
  </div>
</template>

<script>
export default {
  name: "nasvg",
  data() {
    return {
      svgPath: require('@/assets/svg/na.svg'),
      tooltip: {
        visible: false, // 控制提示框的显示
        text: "", // 提示框的内容
        x: 0, // 鼠标位置 X
        y: 0, // 鼠标位置 Y
      },
      defaultStyles: {}, // 存储初始样式
    };
  },
  mounted() {
    this.loadSvg();
  },
  methods: {
    async loadSvg() {
      try {
        const response = await fetch(this.svgPath);
        const svgContent = await response.text();

        // 插入 SVG 到容器中
        this.$refs.svgContainer.innerHTML = svgContent;

        // 获取 SVG 元素
        const svgElement = this.$refs.svgContainer.querySelector("svg");
        this.bindEvents();
      } catch (error) {
        console.error("加载 SVG 文件失败:", error);
      }
    },
    bindEvents() {
      // 目标路径的 ID 列表
      const paths = [
        { id: "#path1-7", label: "Left Chest Fat" },
        { id: "#path2-3", label: "Right Chest Fat" },
        { id: "#内脏脂肪组织", label: "Visceral Fat Tissue" },
        { id: "#皮下白色脂肪", label: "Subcutaneous White Fat" },
        { id: "#棕色脂肪组织", label: "Brown Fat Tissue (Neck)" },
        { id: "骨骼脂肪", label: "Bone Fat Tissue" }
      ];

      paths.forEach((path) => {
        const element = this.$refs.svgContainer.querySelector(path.id);
        if (element) {
          // 保存初始样式
          this.defaultStyles[path.id] = {
            fill: element.style.fill || "",
            stroke: element.style.stroke || "",
          };

          // 添加鼠标事件
          element.addEventListener("mouseenter", (event) => {
            this.showTooltip(path.label, event);
            this.highlightPath(element);
          });
          element.addEventListener("mouseleave", () => {
            this.hideTooltip();
            this.resetPathStyle(element, path.id);
          });
        }
      });
    },
    showTooltip(text, event) {
      // 设置提示框内容和位置
      this.tooltip.text = text;
      this.tooltip.x = event.pageX + 10; // 提示框偏移位置
      this.tooltip.y = event.pageY + 10;
      this.tooltip.visible = true;
    },
    hideTooltip() {
      // 隐藏提示框
      this.tooltip.visible = false;
    },
    highlightPath(element) {
      // 鼠标移入时改变样式
      element.style.fill = "#ff0000"; // 改为红色
      element.style.stroke = "#ff0000"; // 添加黑色描边
      element.style.strokeWidth = "2px"; // 增加描边宽度
    },
    resetPathStyle(element, id) {
      // 恢复初始样式
      const defaultStyle = this.defaultStyles[id];
      if (defaultStyle) {
        element.style.fill = defaultStyle.fill;
        element.style.stroke = defaultStyle.stroke;
      }
    },
  },
};
</script>

<style scoped>
.chart-container {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
}

.svg-container {
  width: 100%;
  height: auto;
}

.svg-container svg {
  width: 100%;
  height: auto;
}

.tooltip {
  position: absolute;
  background-color: rgba(0, 0, 0, 0.75);
  color: white;
  padding: 5px 10px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none; /* 禁止鼠标事件 */
  white-space: nowrap;

}
</style>
