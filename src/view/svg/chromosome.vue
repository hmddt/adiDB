<template>
  <div class="chart_container">
    <p style="font-size: 24px;font-weight: bold">current gene: {{tooltip.text}}</p>
    <div ref="svgContainer" class="svg-container">
      <div
        v-show="tooltip.visible"
        :style="{ top: `${tooltip.y}px`, left: `${tooltip.x}px` }"
        class="tooltip"
      >
        {{ tooltip.text}}
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: "chromosome",
  data() {
    return {
      svgPath: require('@/assets/svg/modified_chromosome1.svg'),
      tooltip: {
        visible: false, // 控制提示框的显示
        text: 'LEP', // 提示框的内容
        x: 0, // 鼠标位置 X
        y: 0, // 鼠标位置 Y
      },
      defaultStyles: {}, // 存储初始样式
    };
  },
  mounted() {
    this.loadSvg();
  },
  methods:{
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
      const svgElements = this.$refs.svgContainer.querySelectorAll("[id]");

      svgElements.forEach(element => {
        const id = element.getAttribute("id");
        if (id) {
          // 存储初始样式
          this.defaultStyles[id] = {
            fill: element.style.fill || "",
            stroke: element.style.stroke || "",
          };

          // 绑定事件
          element.addEventListener("mouseenter", (event) => {
            this.showTooltip(element, event); // 传递 element 而不是 id
            this.highlightPath(element); // 高亮显示
          });
          element.addEventListener("mouseleave", () => {
            this.hideTooltip();
            this.resetPathStyle(element, id); // 恢复样式
          });
          // 新增点击事件
          element.addEventListener("click", (event) => {
            const geneName = element.getAttribute("id");
            if (geneName) {
              // 触发自定义事件，传递基因名称
              this.$emit("gene-clicked", geneName);
            }
          });
        }
      });
    },

    showTooltip(element, event) {
      console.log("Highlighting element:", element);  // 确保这个日志打印出来
      // 设置提示框内容和位置
      const id = element.getAttribute("id");  // 从 element 获取 id
      this.tooltip.text =  id ||'gene';
      this.tooltip.x = event.pageX + 10; // 提示框偏移位置
      this.tooltip.y = event.pageY + 10;
      this.tooltip.visible = true;


      // 输出调试信息，确保内容和位置正确
      console.log("Tooltip Visible:", this.tooltip.visible);
      console.log("Tooltip Text:", this.tooltip.text);
      console.log("Tooltip Position:", this.tooltip.x, this.tooltip.y);
    },
    hideTooltip() {
      // 隐藏提示框
      this.tooltip.visible = false;
    },
    highlightPath(element) {
      // 只修改路径元素的样式，不影响文本
      if (element.tagName === "path" || element.tagName === "rect" || element.tagName === "circle") {
        element.style.fill = "#ff0000"; // 改为红色
        element.style.stroke = "#ff0000"; // 添加红色描边
        element.style.strokeWidth = "2px"; // 增加描边宽度
      }
      // if (element.id === "C1QL3") {
      //   element.style.fill = "black"; // 改为红色
      //   element.style.stroke = "black"; // 添加红色描边
      //   element.style.strokeWidth = "2px"; // 增加描边宽度
      // }
    },

    resetPathStyle(element, id) {
      // 恢复初始样式
      const defaultStyle = this.defaultStyles[id];
      if (defaultStyle) {
        element.style.fill = defaultStyle.fill;
        element.style.stroke = defaultStyle.stroke;
      }
    },
  }
}
</script>

<style scoped>
.tooltip {
  position: absolute;
  background-color: rgba(0, 0, 0, 0.7);
  color: #fff;
  padding: 5px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none; /* 防止 tooltip 捕获鼠标事件 */
  z-index: 1000;
}
.svg-container svg {
  width: 200%;
  height: 200%;
}


</style>
