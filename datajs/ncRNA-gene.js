const axios = require('axios')

async function loadData() {
  try {
    const response = await axios.get('http://tmliang.cn/pic/adi/json/miRTarBase_SE_WR.json');
    const data = response.data;
    return data;
  } catch (error) {
    console.error('Error loading data:', error);
  }
}

async function TgNcRNA(dsvlaue,species,tgvlaue){
  if (dsvlaue === 'miR-gene-miRTarBase') {
    const data = await loadData();
    // 如果 tgvalue 为空字符串或特定关键词 'all'，返回所有物种匹配的数据
    if (!tgvlaue || tgvlaue === 'all') {
      return data.filter(item => item['Species (Target Gene)'] === species);
    }
    // 否则，返回匹配特定 Target Gene 和物种的数据
    return data.filter(item => item['Target Gene'] === tgvlaue && item['Species (Target Gene)'] === species);
  }

}

async function mirRNATg(dsvlaue, species, mirvlaue) {
  const data = await loadData();

  // 根据不同的dsvlaue进行条件判断和筛选
  if (dsvlaue === 'miR-gene-miRTarBase') {
    // 如果mirvlaue为空或者为'all'，返回所有物种的数据
    if (!mirvlaue || mirvlaue === 'all') {
      return data.filter(item => item['Species (Target Gene)'] === species);
    }
    // 否则，返回包含mirvlaue的miRNA数据，且匹配物种
    return data.filter(item => item.miRNA && item.miRNA.includes(mirvlaue) && item['Species (Target Gene)'] === species);
  }

  // 如果 dsvlaue 不是 'miR-gene-miRTarBase'，可以根据其他条件处理，返回空数组
  return [];
}


// 将匹配数据转换为 ECharts 网络图数据
function transformData(inputData) {
  const nodes = [];
  const links = [];
  const categories = [
    { name: "miRNA" },
    { name: "Target Gene" }
  ];

  const nodeMap = new Map(); // 用于去重并存储节点信息
  let nodeId = 0;

  inputData.forEach(item => {
    // 添加 miRNA 节点
    if (!nodeMap.has(item.miRNA)) {
      nodeMap.set(item.miRNA, { id: nodeId, category: 0 });
      nodes.push({
        id: String(nodeId),
        name: item.miRNA,
        symbolSize: 20, // miRNA 节点大小
        x: Math.random() * 500 - 250,
        y: Math.random() * 500 - 250,
        value: Math.random() * 20 + 10, // 示例值
        category: 0 // miRNA 分类
      });
      nodeId++;
    }

    // 添加 Target Gene 节点
    if (!nodeMap.has(item['Target Gene'])) {
      nodeMap.set(item['Target Gene'], { id: nodeId, category: 1 });
      nodes.push({
        id: String(nodeId),
        name: item['Target Gene'],
        symbolSize: 10, // Target Gene 节点大小
        x: Math.random() * 500 - 250,
        y: Math.random() * 500 - 250,
        value: item['Target Gene (Entrez ID)'], // 示例值
        category: 1 // Target Gene 分类
      });
      nodeId++;
    }

    // 添加链接
    links.push({
      source: String(nodeMap.get(item.miRNA).id),
      target: String(nodeMap.get(item['Target Gene']).id)
    });
  });

  return { nodes, links, categories };
}

module.exports = { TgNcRNA,mirRNATg,transformData };
