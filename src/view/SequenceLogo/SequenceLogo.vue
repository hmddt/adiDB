<template>
  <div class="sequence">
    <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
      <p><span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Sequence Logo</span></p>
      <p style="font-size: 13px; color: #999; margin-top: 0; padding-right: 10px;"><span>*Sequence comparison logo for RNA, DNA, and proteins.</span></p>
    </div>
    <br>
    <div style="text-align: left;margin-left: 60px">
<!--      这部分选择上传的文件-->
      <textarea
        v-model="inputSequences"
        rows="10"
        cols="200"
        style="width: 1200px;height: 200px;"
        placeholder="Please enter the standard FASTA format (multiple lines allowed):\n>sequence1\nUGAGGUAGUAGG...\n>sequence2\n..."
      ></textarea>
      <br>
<!--      选择上传文件-->
      <label class="custom-file-upload">
        Choose File
        <input type="file" accept=".fasta,.fa,.txt" @change="handleFileUpload" />
      </label>
      <span style="margin-left: 10px">{{ selectedFileName || 'No file chosen' }}</span>
    </div>


    <br />
    <el-button class="hover-blue-btn" @click="generateLogo">Generate sequences Logo</el-button>
    <el-button class="hover-blue-btn" @click="fillExample" style="margin-left: 20px">example</el-button>
    <el-dropdown @command="handleDownloadChoice">
      <el-button class="hover-blue-btn" style="margin-left: 20px">
        Download <i class="el-icon-arrow-down el-icon--right"></i>
      </el-button>
      <el-dropdown-menu slot="dropdown">
        <el-dropdown-item command="svg">Download as SVG</el-dropdown-item>
        <el-dropdown-item command="png">Download as PNG</el-dropdown-item>
        <el-dropdown-item command="pdf">Download as PDF</el-dropdown-item>
      </el-dropdown-menu>
    </el-dropdown>

    <br/>
    <div class="logo-scroll-container">
      <svg
        :width="svgWidth + 60"
        :height="svgHeight + 90"
        style="margin-top: 20px; background: #fff; border: 1px solid #ccc"
      >
        <!-- y轴 -->
        <g>
          <line
            v-for="(i, index) in 5"
            :key="'line-' + index"
            :x1="60"
            :x2="svgWidth + 50"
            :y1="svgHeight - index * 40 + 30"
            :y2="svgHeight - index * 40 + 30"
            stroke="#ccc"
            stroke-dasharray="2,2"
          />
          <text
            v-for="(i, index) in 5"
            :key="'label-' + index"
            x="55"
            :y="svgHeight - index * 40 + 30"
            font-size="12"
            text-anchor="end"
            dominant-baseline="middle"
          >
            {{ (index * 0.5).toFixed(1) }}
          </text>
          <text
            x="20"
            :y="svgHeight / 2 + 30"
            font-size="14"
            :transform="`rotate(-90, 20, ${svgHeight / 2 + 30})`"
            text-anchor="middle"
          >
            bits
          </text>
          <line
            :x1="60"
            :x2="svgWidth + 50"
            :y1="svgHeight + 30"
            :y2="svgHeight + 30"
            stroke="#000"
            stroke-width="1"
          />
        </g>

        <!-- logo 主体 -->
        <g
          v-for="(column, colIndex) in logoData"
          :key="colIndex"
          :transform="`translate(${colIndex * columnWidth + 90}, ${svgHeight + 30})`"
        >
          <g
            v-for="(item, i) in column"
            :key="i"
            :transform="`translate(0, ${-item.yOffset}) scale(1, ${item.height / 100})`"
          >
            <use :href="`#glyph-${item.base}`" :fill="baseColors[item.base] || '#000'" />
          </g>
          <text :x="0" :y="20" font-size="10" text-anchor="middle">{{ colIndex + 1 }}</text>
        </g>

        <!-- 碱基字形 -->
        <defs>
          <g v-for="base in Object.keys(baseColors)" :key="base" :id="`glyph-${base}`">
            <text font-family="monospace" font-size="100" text-anchor="middle" x="0" y="0">{{ base }}</text>
          </g>
        </defs>
      </svg>
    </div>
    <div style="margin-top: 20px">
      <input
        type="range"
        class="custom-slider"
        :min="0"
        :max="maxScroll"
        v-model="scrollValue"
        @input="onScrollSlider"
        style="width: 100%"
      />
    </div>

  </div>
</template>

<script>
import jsPDF from "jspdf";
export default {
  name: "SequenceLogoSVG",
  data() {
    return {
      inputSequences: "",
      validatedSequences: [],
      selectedFileName: "",
      logoData: [],
      svgWidth: 1350,
      svgHeight: 200,
      columnWidth: 50,
      scrollValue: 0,
      maxScroll: 0,
      resultFileName: "",
      baseColors: {
        A: '#9b1912', U: '#134991', T: '#134991', C: '#478813', G: '#cea01a',
        D: '#FF6666', E: '#FF3333', K: '#3399FF', R: '#3366CC',
        N: '#66CC66', Q: '#66CC99',
        S: '#560521', Y: '#FF9900',
        H: '#9966FF', F: '#FF66CC', L: '#CC9966', I: '#CC6600',
        V: '#999900', M: '#66CCCC', W: '#9999FF', P: '#CCCCCC',
        X: '#999999', B: '#CCCCFF', Z: '#FFCCCC', '*': '#000000'
      }
    };
  },
  methods: {
    fillExample() {
      this.inputSequences = `>seq1
UGAGGUAGUAGGUUGUAUAGUU
>seq2
UGAGGUAGUAGGUUGUAUAGUA
>seq3
UGAGGUAGUAGGUUGUAUAGUG`;
    },

    handleFileUpload(event) {
      const file = event.target.files[0];
      if (!file) return;
      this.selectedFileName = file.name;

      if (this.mode === 'alignment') {
        this.uploadToServer(file);
      } else {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.inputSequences = e.target.result;
        };
        reader.readAsText(file);
      }
    },
    uploadToServer(file) {
      const formData = new FormData();
      formData.append("file", file);

      fetch("http://47.97.192.100:8090/msa/upload", {
        method: "POST",
        body: formData
      })
        .then(res => res.json()) //  JSON 解析
        .then(json => {
          console.log(" Return JSON:", json);
          this.resultFileName = json.filename; // 从 JSON 中获取字段
        })
        .catch(err => {
          console.error(" Upload failed:", err);
          alert("If the upload fails, please check the network or service status.");
        });
    },
    handleDownloadChoice(format) {
      if (format === 'svg') {
        this.downloadSVG();
      } else if (format === 'png') {
        this.downloadPNG();
      } else if (format === 'pdf') {
        this.downloadPDF();
      }
    },


    downloadSVG() {
      const svg = this.$el.querySelector('svg');
      const serializer = new XMLSerializer();
      const svgBlob = new Blob([serializer.serializeToString(svg)], { type: "image/svg+xml" });
      const url = URL.createObjectURL(svgBlob);

      const link = document.createElement("a");
      link.href = url;
      link.download = "sequence_logo.svg";
      link.click();
      URL.revokeObjectURL(url);
    },

    downloadPNG() {
      const svgElement = this.$el.querySelector('svg');
      const serializer = new XMLSerializer();
      const svgString = serializer.serializeToString(svgElement);
      const canvas = document.createElement("canvas");

      // 设置 canvas 尺寸与 SVG 相同
      canvas.width = svgElement.width.baseVal.value;
      canvas.height = svgElement.height.baseVal.value;

      const ctx = canvas.getContext("2d");
      const img = new Image();

      const svgBlob = new Blob([svgString], { type: "image/svg+xml;charset=utf-8" });
      const url = URL.createObjectURL(svgBlob);

      img.onload = () => {
        ctx.drawImage(img, 0, 0);
        URL.revokeObjectURL(url);
        const pngUrl = canvas.toDataURL("image/png");

        const link = document.createElement("a");
        link.href = pngUrl;
        link.download = "sequence_logo.png";
        link.click();
      };

      img.src = url;
    },
    downloadPDF() {
      const svgElement = this.$el.querySelector('svg');
      const serializer = new XMLSerializer();
      const svgString = serializer.serializeToString(svgElement);

      const canvas = document.createElement("canvas");
      canvas.width = svgElement.width.baseVal.value;
      canvas.height = svgElement.height.baseVal.value;

      const ctx = canvas.getContext("2d");
      const img = new Image();

      const svgBlob = new Blob([svgString], { type: "image/svg+xml;charset=utf-8" });
      const url = URL.createObjectURL(svgBlob);

      img.onload = () => {
        ctx.drawImage(img, 0, 0);
        URL.revokeObjectURL(url);
        const imgData = canvas.toDataURL("image/png");

        const pdf = new jsPDF({
          orientation: "landscape",
          unit: "px",
          format: [canvas.width, canvas.height]
        });
        pdf.addImage(imgData, 'PNG', 0, 0, canvas.width, canvas.height);
        pdf.save("sequence_logo.pdf");
      };

      img.src = url;
    },

    generateLogo() {
      const result = this.parseFasta(this.inputSequences);
      if (!result.valid) {
        alert("Format error:\n" + result.errors.join("\n"));
        return;
      }

      this.validatedSequences = result.sequences;

      const lines = result.sequences;
      const length = lines[0].length;
      const bases = [...new Set(lines.join("").split(""))];

      const counts = Array(length).fill().map(() => Object.fromEntries(bases.map(b => [b, 0])));

      lines.forEach(seq => {
        for (let i = 0; i < length; i++) {
          const base = seq[i];
          counts[i][base]++;
        }
      });

      const logo = [];
      for (let i = 0; i < length; i++) {
        const total = bases.reduce((sum, b) => sum + counts[i][b], 0);
        const freqs = bases.map(b => ({ base: b, freq: counts[i][b] / total })).filter(b => b.freq > 0);

        const entropy = -freqs.reduce((sum, b) => sum + b.freq * Math.log2(b.freq), 0);
        const maxEntropy = Math.log2(4); // RNA
        const infoContent = Math.max(0, maxEntropy - entropy);

        const sorted = freqs.sort((a, b) => a.freq - b.freq);
        let yOffset = 0;
        const col = sorted.map(b => {
          const h = Math.max(b.freq * infoContent * 100, 10);
          const out = {
            base: b.base,
            height: h,
            yOffset: yOffset
          };
          yOffset += h;
          return out;
        });
        logo.push(col);
      }

      this.logoData = logo;
      this.svgWidth = this.columnWidth * logo.length;
      this.$nextTick(() => {
        const container = this.$el.querySelector('.logo-scroll-container');
        this.maxScroll = container.scrollWidth - container.clientWidth;
      });

    },
    onScrollSlider() {
      const container = this.$el.querySelector('.logo-scroll-container');
      container.scrollLeft = this.scrollValue;
    },
    parseFasta(text) {
      const lines = text.trim().split(/\r?\n/);
      const sequences = [];
      let current = '';

      for (let line of lines) {
        line = line.trim();
        if (line.startsWith('>')) {
          if (current) {
            sequences.push(current);
            current = '';
          }
        } else {
          current += line.toUpperCase(); // 合并成一条序列
        }
      }
      if (current) sequences.push(current);

      // 然后检查长度
      const lengths = new Set(sequences.map(seq => seq.length));
      if (lengths.size > 1) return { valid: false, errors: ['All sequences must be of the same length. Please go to the "Sequence Alignment" module to perform sequence alignment first.'], sequences };

      return { valid: true, sequences, errors: [] };
    }

  }
};
</script>

<style scoped>
.sequence {
  background: #ffffff;
  width: 1400px;
  margin:  0 auto;
}
textarea {
  font-family: monospace;
}
.fasta-output {
  margin-top: 1em;
  background: #f4f4f4;
  padding: 1em;
  border: 1px solid #ccc;
  white-space: pre-wrap;
  font-family: monospace;
}
.logo-scroll-container {
  overflow-x: auto;
  margin-top: 30px;
  max-width: 1400px;   /* 或自定义宽度，如 1000px */
  border: 1px solid #ccc;
}
.custom-file-upload {
  display: inline-block;
  padding: 6px 12px;
  cursor: pointer;
  background-color: #2a5eaa;
  color: #fff;
  font-weight: bold;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-family: sans-serif;
}
.custom-file-upload input[type="file"] {
  display: none;
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
  color: white !important;
  border-color: #1f4c90 !important;
  transform: scale(1.05); /* 放大按钮 */}

.custom-slider {
  -webkit-appearance: none;
  width: 100%;
  height: 6px;
  background: #ccc;
  border-radius: 5px;
  outline: none;
}

/* 滑块轨道 */
.custom-slider::-webkit-slider-runnable-track {
  background: #c0c0c0; /* 主轨道颜色 */
  height: 6px;
  border-radius: 5px;
}
.custom-slider::-moz-range-track {
  background: #ffffff;
  height: 6px;
  border-radius: 5px;
}

/* 滑块按钮 */
.custom-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #1f4c90;
  cursor: pointer;
  border: 2px solid white;
  margin-top: -5px; /* 对齐轨道 */
}
.custom-slider::-moz-range-thumb {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #ffffff;
  cursor: pointer;
  border: 2px solid white;
}

</style>
