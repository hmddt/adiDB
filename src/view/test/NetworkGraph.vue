<template>
  <div class="network-container">
    <div ref="chart" class="chart"></div>
  </div>
</template>

<script>
import * as echarts from 'echarts';
import chartData from '../../../datajs/prediction-sl/prediction-sl.json'; //

export default {
  name: 'NetworkGraph',
  data() {
    return {
      chartInstance: null,
      geneList: new Set([
        "LEP", "RBP4", "ANGPTL2", "TNF", "IL6", "CCL2", "CXCL5", "NAMPT", "SFRP5",
        "CRP", "SIRT1", "IL10", "SOCS3", "CXCL1", "WISP2", "NMB", "SLC2A4", "VCAM1",
        "SERPINA12", "DPP4", "FGF21", "C19orf80", "BMP4", "IRS1", "PTPN1", "FABP4",
        "VEGFA", "C3", "RETN", "ADIPOQ", "LRG1", "ISM1", "C1QTNF9", "FAM19A5", "ORM1",
        "DGAT1", "AZGP1", "C1QTNF1", "C1QTNF3", "C1QTNF5", "FAM132A", "C1QL3", "C1QTNF6",
        "APLN", "C20orf27", "PTGDS", "LCN2", "ACE", "ANGPTL4", "SFRP4", "WISP1", "NRG4",
        "FSTL1", "FBN1", "CAV1", "HGF", "APOM", "PCOLCE", "CXCL14", "SERPINF1", "TGFB2",
        "GDF10", "SSTR2", "FNDC4", "DPT", "GREM1", "GHRL", "HMGB1", "GM2A", "SPP1", "CFD",
        "GRN", "METRNL", "ITLN1", "SAA1", "DLL1", "CLU", "GPC4", "ANGPTL6", "GPX3", "DLK1",
        "BMP7", "AHSG", "NUCB2", "TIMP1", "TGFB1", "LGALS3", "IL1B", "IL18", "RARRES2",
        "C1QTNF2", "C1QTNF7", "C1QTNF4", "ITIH5", "VEGFD", "CFH", "CRYAB", "CILP", "HMOX1"
      ])
    };
  },
  mounted() {
    this.initChart();
    window.addEventListener('resize', this.resizeChart);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeChart);
    if (this.chartInstance) {
      this.chartInstance.dispose();
    }
  },
  methods: {
    initChart() {
      const highlightedNodes = chartData.nodes.map(node => {
        const isTargetGene = this.geneList.has(node.name);
        return {
          ...node,
          itemStyle: {
            color: isTargetGene ? '#e74c3c' : (node.itemStyle && node.itemStyle.color) || '#500816'
          }
        };
      });

      this.chartInstance = echarts.init(this.$refs.chart);
      this.chartInstance.setOption({
        tooltip: {},
        title: {
          text: "Adipokines related Synthetic Lethality Network (Prediction )",
          left: "20px",
          top:"10px",
          textStyle: {
            fontSize:24,
            color: '#2b6cb0',   // 字体颜色
          },
        },

        // legend: [{
        //   data: chartData.categories.map(c => c.name)
        // }],
        series: [{
          type: 'graph',
          layout: 'force',
          data: highlightedNodes,
          links: chartData.links,
          categories: chartData.categories,
          roam: true,
          label: {
            show: true,
            position: 'right'
          },
          force: {
            repulsion: 100,
            edgeLength: 80
          },
          lineStyle: {
            color: 'source',
            curveness: 0.2
          }
        }]
      });
    },
    resizeChart() {
      if (this.chartInstance) {
        this.chartInstance.resize();
      }
    }
  }
};
</script>

<style scoped>
.network-container {
  width: 100%;
  height: 100%;
  background: #ffffff;
}
.chart {
  width: 100%;
  height: 100vh;
}
</style>
