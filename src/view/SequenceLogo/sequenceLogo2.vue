<template>
  <div class="sequence">
    <h2>Sequence Processing</h2>

    <!-- 模式切换 -->
    <label>
      <strong>Select Mode:</strong>
      <select v-model="mode">
        <option value="alignment">Alignment (backend)</option>
        <option value="logo">Logo Visualization (local)</option>
      </select>
    </label>

    <br /><br />

    <!-- 上传 -->
    <label class="custom-file-upload">
      Choose File
      <input type="file" accept=".fasta,.fa,.txt" @change="handleFileUpload" />
    </label>
    <span style="margin-left: 10px">{{ selectedFileName || 'No file chosen' }}</span>

    <br /><br />

    <!-- 输入 -->
    <textarea
      v-model="inputSequences"
      rows="10"
      cols="70"
      placeholder="Paste FASTA formatted sequences here:\n>sequence1\nUGAGGUAGUAGG...\n>sequence2\n..."
    ></textarea>

    <br />

    <!-- 操作按钮 -->
    <div class="button-group">
      <button v-if="mode === 'alignment'" @click="submitAlignment">Submit for Alignment</button>
      <button v-if="mode === 'logo'" @click="generateLogoFromText">Generate Logo from Text</button>
      <button v-if="mode === 'logo'" @click="generateLogoFromFile">Generate Logo from File</button>
      <button @click="fillExample">Example</button>
    </div>

    <!-- 结果展示 -->
    <div v-if="mode === 'alignment' && alignmentResult" class="result-block">
      <h3>Alignment Result Preview</h3>
      <pre class="fasta-output">{{ alignmentResult }}</pre>
      <a
        :href="`http://47.97.192.100:8090/msa/download/${resultFileName}`"
        target="_blank"
        download
      >
        <button>Download Aligned File</button>
      </a>
    </div>

    <div v-if="mode === 'logo'" class="logo-scroll-container">
      <svg
        :width="svgWidth + 60"
        :height="svgHeight + 70"
        style="margin-top: 20px; background: #fff; border: 1px solid #ccc"
      >
        <!-- y-axis -->
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

        <!-- logo content -->
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

        <!-- Base letters -->
        <defs>
          <g v-for="base in Object.keys(baseColors)" :key="base" :id="`glyph-${base}`">
            <text font-family="monospace" font-size="100" text-anchor="middle" x="0" y="0">{{ base }}</text>
          </g>
        </defs>
      </svg>
    </div>
  </div>
</template>

<script>
export default {
  name: "sequenceLogo2",
  data() {
    return {
      mode: "alignment", // or 'logo'
      inputSequences: "",
      selectedFileName: "",
      resultFileName: "",
      alignmentResult: "",
      validatedSequences: [],
      logoData: [],
      svgWidth: 800,
      svgHeight: 200,
      columnWidth: 50,
      baseColors: {
        A: '#9b1912', U: '#134991', T: '#134991', C: '#478813', G: '#cea01a',
        D: '#FF6666', E: '#FF3333', K: '#3399FF', R: '#3366CC',
        N: '#66CC66', Q: '#66CC99', S: '#560521', Y: '#FF9900',
        H: '#9966FF', F: '#FF66CC', L: '#CC9966', I: '#CC6600',
        V: '#999900', M: '#66CCCC', W: '#9999FF', P: '#CCCCCC',
        X: '#999999', B: '#CCCCFF', Z: '#FFCCCC', '*': '#000000'
      }
    };
  },
  methods: {
    fillExample() {
      this.inputSequences = `>seq1\nUGAGGUAGUAGGUUGUAUAGUU\n>seq2\nUGAGGUAGUAGGUUGUAUAGUA\n>seq3\nUGAGGUAGUAGGUUGUAUAGUG`;
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
    submitAlignment() {
      if (this.inputSequences.trim()) {
        const blob = new Blob([this.inputSequences], { type: 'text/plain' });
        const file = new File([blob], "input_from_text.txt");
        this.uploadToServer(file);
      } else if (!this.selectedFileName) {
        alert("Please paste sequences or choose a file.");
      }
    },
    uploadToServer(file) {
      const formData = new FormData();
      formData.append("file", file);

      fetch("http://47.97.192.100:8090/msa/upload", {
        method: "POST",
        body: formData
      })
        .then(res => res.json())
        .then(json => {
          this.resultFileName = json.filename;
          return fetch(`http://47.97.192.100:8090/msa/download/${json.filename}`);
        })
        .then(res => res.text())
        .then(text => {
          this.alignmentResult = text;
        })
        .catch(err => {
          console.error("Upload failed:", err);
          alert("Upload or preview failed.");
        });
    },
    generateLogoFromText() {
      if (!this.inputSequences.trim()) {
        alert("Paste FASTA data before generating logo.");
        return;
      }
      this.generateLogo();
    },
    generateLogoFromFile() {
      const input = document.createElement("input");
      input.type = "file";
      input.accept = ".fasta,.fa,.txt";
      input.onchange = (e) => {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (evt) => {
          this.inputSequences = evt.target.result;
          this.generateLogo();
        };
        reader.readAsText(file);
      };
      input.click();
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
          counts[i][seq[i]]++;
        }
      });
      const logo = [];
      for (let i = 0; i < length; i++) {
        const total = bases.reduce((sum, b) => sum + counts[i][b], 0);
        const freqs = bases.map(b => ({ base: b, freq: counts[i][b] / total })).filter(b => b.freq > 0);
        const entropy = -freqs.reduce((sum, b) => sum + b.freq * Math.log2(b.freq), 0);
        const maxEntropy = Math.log2(4);
        const infoContent = Math.max(0, maxEntropy - entropy);
        const sorted = freqs.sort((a, b) => a.freq - b.freq);
        let yOffset = 0;
        const col = sorted.map(b => {
          const h = Math.max(b.freq * infoContent * 100, 10);
          const out = { base: b.base, height: h, yOffset };
          yOffset += h;
          return out;
        });
        logo.push(col);
      }
      this.logoData = logo;
      this.svgWidth = this.columnWidth * logo.length;
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
          current += line.toUpperCase();
        }
      }
      if (current) sequences.push(current);
      const lengths = new Set(sequences.map(seq => seq.length));
      if (lengths.size > 1) return { valid: false, errors: ['All sequences must be of the same length'], sequences };
      return { valid: true, sequences, errors: [] };
    }
  }
};
</script>

<style scoped>
.sequence {
  background: #f9f9fb;
  padding: 1rem;
  font-family: sans-serif;
}
textarea {
  font-family: monospace;
}
.button-group button {
  margin: 6px 8px 6px 0;
  padding: 6px 12px;
}
.result-block {
  margin-top: 1em;
  background: #f0f8ff;
  padding: 1em;
  border: 1px solid #ccc;
}
.fasta-output {
  white-space: pre-wrap;
  font-family: monospace;
  background: #fff;
  border: 1px solid #ccc;
  padding: 10px;
  max-height: 300px;
  overflow-y: auto;
}
.logo-scroll-container {
  overflow-x: auto;
  max-width: 100%;
  border: 1px solid #ccc;
  margin-top: 1em;
}
.custom-file-upload {
  display: inline-block;
  padding: 6px 12px;
  cursor: pointer;
  background-color: #e0e0e0;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.custom-file-upload input[type="file"] {
  display: none;
}
</style>
