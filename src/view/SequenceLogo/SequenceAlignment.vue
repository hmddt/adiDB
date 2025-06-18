<template>
  <div class="sequence" v-loading="loadingAlignment">
    <div style="text-align: left ;margin-left: 60px;margin-top: 20px">
      <p><span style="font-weight: bold;font-size: 24px;color: #3a8ee6">Sequence Alignment</span></p>
      <p style="font-size: 13px; color: #999; margin-top: 0; padding-right: 10px;"><span>*Sequence comparison logo for RNA, DNA, and proteins.</span></p>
    </div>
    <br>
    <div style="text-align: left;margin-left: 60px">
<!--      上传文件-->
      <textarea
        v-model="inputSequences"
        rows="10"
        cols="200"
        style="width: 1200px;height: 200px;"
        placeholder="Paste FASTA formatted sequences here:\n>sequence1\nUGAGGUAGUAGG...\n>sequence2\n..."
      ></textarea>
      <br>
      <!-- 上传 -->
      <label class="custom-file-upload">
        Choose File
        <input type="file" accept=".fasta,.fa,.txt" @change="handleFileUpload" />
      </label>
      <el-button class="hover-blue-btn1" @click="submitAlignment">Submit for Alignment</el-button>
      <span style="margin-left: 10px">{{ selectedFileName || 'No file chosen' }}</span>
    </div>
    <br />
    <p style=" text-align: left;margin-left: 60px;font-size: 13px; color: #b74848; margin-top: 0; padding-right: 10px;"><span>!Submitted text must be under 2MB.</span></p>
    <br/>
    <br/>
    <!-- 操作按钮 -->
<!--      <el-button class="hover-blue-btn" @click="fillExample">Example</el-button>-->
    <br/>
    <!-- 结果展示 -->
    <el-card v-if="alignmentResult" style="margin-top: 30px">
      <div class="result-block">
        <div style="text-align: left;margin-left: 60px">
          <p style="font-weight: bold;font-size: 22px;color: #3a8ee6">Alignment Result Preview</p>
          <div class="download-section">
            <a
              :href="`http://47.97.192.100:8090/msa/download/${resultFileName}`"
              target="_blank"
              download
            >
              <span style="color: #3a8ee6;font-weight: bold">Download</span>
            </a>
            <a
              :href="`http://47.97.192.100:8090/msa/download/${resultFileName}`"
              target="_blank"
              download
              class="download-link"
            >
              <span style="margin-left: 10px">{{ resultFileName }}</span>
            </a>
          </div>
        </div>
        <br>
        <pre class="fasta-output">{{ alignmentResult }}</pre>
        <br>
      </div>

    </el-card>

  </div>

</template>

<script>
export default {
name: "SequenceAlignment",
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
      loadingAlignment:false,
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
  watch:{
    alignmentResult(newVal) {
      if (newVal) {
        this.loadingAlignment = false;
        console.log("Alignment result received.");
        // 你也可以在这里添加你想执行的操作，比如自动滚动、通知用户等
        this.$message.success("Alignment completed!");
      }
    }  },
  methods: {
    fillExample() {
      this.inputSequences = `>seq1\nUGAGGUAGUAGGUUGUAUAGUU\n>seq2\nUGAGGUAGUAGGUUGUAUAGUA\n>seq3\nUGAGGUAGUAGGUUGUAUAGUG`;
    },
    submitAlignment() {
      const trimmedInput = this.inputSequences.trim();

      if (!trimmedInput) {
        alert("Please paste sequences or choose a file.");
        return;
      }

      // 1. 文件大小限制 < 2MB
      const blobSize = new Blob([trimmedInput]).size;
      if (blobSize > 2 * 1024 * 1024) {
        alert("The input content exceeds 2MB. Please reduce the content.");
        return;
      }

      // 2. 格式校验：是否FASTA格式
      const formatValid = this.isValidFastaFormat(trimmedInput);
      if (!formatValid.success) {
        alert("FASTA format error:\n" + formatValid.message);
        return;
      }

      // 3. 校验是否有重复名称
      const duplicate = this.checkDuplicateHeaders(trimmedInput);
      if (duplicate) {
        alert("Duplicate sequence name found: " + duplicate);
        return;
      }

      // 合法则上传
      const blob = new Blob([trimmedInput], { type: 'text/plain' });
      const timestamp = new Date().toISOString().replace(/[-:T.]/g, "").slice(0, 14);
      const file = new File([blob], `fasta_${timestamp}.txt`);
      this.uploadToServer(file);
      this.loadingAlignment = true;
      alert("Success Submit For Alignment!")
    },
    isValidFastaFormat(text) {
      const lines = text.trim().split(/\r?\n/);
      let hasHeader = false;
      let hasSeq = false;

      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line.startsWith(">")) {
          hasHeader = true;
          if (line.length === 1) {
            return { success: false, message: `Line ${i + 1} has '>' but no sequence name.` };
          }
        } else if (line) {
          if (!hasHeader) {
            return { success: false, message: `Line ${i + 1} is a sequence line without a preceding '>'.` };
          }
          hasSeq = true;
        }
      }

      if (!hasHeader) return { success: false, message: "Missing FASTA headers (lines starting with '>')." };
      if (!hasSeq) return { success: false, message: "No sequence content found." };

      return { success: true };
    },
    checkDuplicateHeaders(text) {
      const headers = text
        .split(/\r?\n/)
        .map(line => line.trim())
        .filter(line => line.startsWith('>'))
        .map(h => h.slice(1).trim());

      const seen = new Set();
      for (let name of headers) {
        if (seen.has(name)) return name;
        seen.add(name);
      }
      return null;
    },


    handleFileUpload(event) {
      const file = event.target.files[0];
      if (!file) return;
      this.selectedFileName = file.name;
        const reader = new FileReader();
        reader.onload = (e) => {
          this.inputSequences = e.target.result;
        };
        reader.readAsText(file);

    },
    // submitAlignment() {
    //   if (this.inputSequences.trim()) {
    //     const blob = new Blob([this.inputSequences], { type: 'text/plain' });
    //     const timestamp = new Date().toISOString().replace(/[-:T.]/g, "").slice(0, 14); // e.g., 20250522142300
    //     const file = new File([blob], `fasta_${timestamp}.txt`);
    //     this.uploadToServer(file);
    //   } else if (!this.selectedFileName) {
    //     alert("Please paste sequences or choose a file.");
    //   }
    // },
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
}
</script>

<style scoped>
.sequence {
  background: #ffffff;
  width: 1400px;
  margin: 0 auto;
  min-height: 600px;
}
textarea {
  font-family: monospace;
}
.button-group button {
  margin: 6px 8px 6px 0;
  padding: 6px 12px;
}
.result-block {
  margin-top: 20px;
  background: #ffffff;
}
.fasta-output {
  white-space: pre-wrap;
  font-family: monospace;
  text-align: left;
  margin-left: 50px;
  background: #fff;
  padding: 10px;
  font-size: 16px;
  max-height: 300px;
  overflow-y: auto;
}

.hover-blue-btn1 {
  background-color: #2a5eaa;
  border-color: #2a5eaa;
  color: #fff;
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 3px;
  font-size: 15px;
}

.hover-blue-btn1:hover {
  background-color: #1f4c90 !important;
  border-color: #1f4c90 !important;
  /*transform: scale(1.05); !* 放大按钮 *!*/
}

.custom-file-upload {
  display: inline-block;
  padding: 6px 12px;
  cursor: pointer;
  background-color: #2a5eaa;
  border: 1px solid #ccc;
  color: white;
  font-weight: bold;
  border-radius: 4px;
}
.custom-file-upload input[type="file"] {
  display: none;
}
.download-link {
  display: inline-block;
  margin-top: 10px;
  color: #3a8ee6;
  font-weight: bold;
  cursor: pointer;
}
.download-link:hover {
  color: #1f4c90;
}

</style>

