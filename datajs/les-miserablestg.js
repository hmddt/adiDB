
const axios = require('axios')

async function loadData() {
  try {
    const response = await axios.get('http://tmliang.cn/pic/adi/json/allclassifiedData.json');
    const data = response.data;
    return data;
  } catch (error) {
    console.error('Error loading data:', error);
  }
}

async function testByGene(tfValue) {
  // const dataArray = require('./allclassifiedData.json');
  const dataArrayRaw = await loadData();
  //去掉Unknown
  const dataArray = dataArrayRaw.filter(item => item.Function !== 'Unknown');

  // 过滤出 TF 匹配的数据
  let tfMatches = dataArray.filter(item => item.TF === tfValue);
  // 过滤出 TG (Target_gene) 匹配的数据
  let tgMatches = dataArray.filter(item => item.Target_gene === tfValue);
// 从 tfMatches 和 tgMatches 提取所有的 TF 字段
  let relatedTFsFromTFMatches = tfMatches.map(item => item.TF);
  let relatedTFsFromTGMatches = tgMatches.map(item => item.TF);

  // 合并并去重
  let allRelatedTFs = [...new Set([...relatedTFsFromTFMatches, ...relatedTFsFromTGMatches])];
  let allRelatedTFMatches = dataArray.filter(item => allRelatedTFs.includes(item.TF));
  console.log("所有有关TF的数据：", relatedTFsFromTFMatches);
  console.log("所有有关tg的数据：", relatedTFsFromTGMatches);
  return {
    allRelatedTFs,
    TFLength: allRelatedTFs.length,
    allRelatedTFMatches, //所有TF匹配的具体数据
    TFMatches: allRelatedTFMatches.length, //所有删选结果的条数，用于分页显示
  };
}


async function filterDataByTF(tfValue) {
  // const dataArray = require('./allclassifiedData.json');
  const dataArray = await loadData();

  // 首先在 TF 字段中查找
  let filteredData = dataArray.filter(item => item.TF === tfValue);

  if (filteredData.length === 0) {
    // 如果在 TF 中找不到，则在 Target_gene 中查找
    const foundTarget = dataArray.find(item => item.Target_gene === tfValue);
    if (foundTarget) {
      const targetTF = foundTarget.TF; // 获取对应的 TF 值
      console.log(`未在 TF 中找到 "${tfValue}"，改为根据 Target_gene 查找对应的 TF: "${targetTF}"`);

      // 使用找到的 TF 值重新查找数据
      filteredData = dataArray.filter(item => item.TF === targetTF);
    } else {
      console.log(`未找到与 "${tfValue}" 相关的 TF 或 Target_gene 数据。`);
      return [];
    }
  }

  // 转换为标准的 JavaScript 对象
  const transformedData = filteredData.map(item => {
    return Object.fromEntries(Object.entries(item));
  });

  console.log('转换后的数据为:', transformedData);
  return transformedData;
}



function transformData(inputData) {
  const fs = require('fs');
  const nodes = [];
  const links = [];
  const tfColor = '#2a5eaa';   // 蓝色
  const tgColor = '#27ae60';   // 绿色
  const categories = [
    { name: "TF" },
    { name: "Target gene" }
  ];

  const nodeMap = new Map(); // 用于检查节点是否已存在
  let nodeId = 0; // 节点 ID 累计值

  inputData.forEach((item) => {
    // 添加或更新 TF 节点
    if (!nodeMap.has(item.TF)) {
      nodeMap.set(item.TF, { id: nodeId, category: 0 }); // TF 类别
      nodes.push({
        id: String(nodeId),
        name: item.TF,
        symbolSize: 15, // 示例大小
        x: Math.random() * 500 - 250, // 随机 x 坐标
        y: Math.random() * 500 - 250, // 随机 y 坐标
        value: Math.random() * 30 + 10, // 示例值
        category: 0, // TF 的类别
        itemStyle: {
          color: tfColor
        }
      });
      nodeId++;
    } else {
      // 如果节点已存在且是 Target_gene，则更新为 TF
      const existingNode = nodeMap.get(item.TF);
      if (existingNode.category === 1) {
        existingNode.category = 0;
        const nodeToUpdate = nodes.find(node => node.id === String(existingNode.id));
        if (nodeToUpdate) {
          nodeToUpdate.category = 0;
          nodeToUpdate.symbolSize = 19.12381; // 更新为 TF 的大小
          nodeToUpdate.value = Math.random() * 30 + 10; // 更新为 TF 的值
        }
      }
    }

    // 添加 Target_gene 节点
    if (!nodeMap.has(item.Target_gene)) {
      nodeMap.set(item.Target_gene, { id: nodeId, category: 1 }); // Target_gene 类别
      nodes.push({
        id: String(nodeId),
        name: item.Target_gene,
        symbolSize: 10, // 示例大小
        x: Math.random() * 100-10, // 随机 x 坐标
        y: Math.random() * 100-10, // 随机 y 坐标
        value: item.Target_gene_Entrez, // 示例值
        category: 1, // Target_gene 的类别
        itemStyle: {
          color: tgColor
        }
      });
      nodeId++;
    }
    // 处理 Function 字段，优先级为 "Activation" > "Repression" > "Unknown"
    let functionType = item.Function;


    // 计算每条边的颜色
    let lineColor = getColorByFunction(functionType);


    // 添加链接
    links.push({
      source: String(nodeMap.get(item.TF).id),
      target: String(nodeMap.get(item.Target_gene).id),
      info: `Source: ${item.TF}, Target: ${item.Target_gene}, Function: ${functionType|| 'Unknown'}`,
      lineStyle: {
        color: lineColor // 设置边的颜色
      }
    });
  });

  return { nodes, links, categories };
}
// 根据 function 的值定义颜色
function getColorByFunction(functionName) {
  switch (functionName) {
    case 'Activation':
      return '#a60b0b'; // 红色
    case 'Repression':
      return '#254791'; // 蓝色
    case 'Unknown':
      return '#aaa'; // 黑色
    default:
      return '#cccccc'; // 默认颜色（如果没有匹配到函数）
  }
}

// 处理初始化数据
const fs = require('fs');
const path = require('path');
//处理json文件
// function mountedTfDataProTxt(filePath, jsonOutputName = 'converted_tf_data.json') {
//   try {
//     const content = fs.readFileSync(filePath, 'utf8'); // 读取文本内容
//     const lines = content.trim().split('\n'); // 按行分割
//     const headers = lines[0].split('\t').map(h => h.trim()); // 表头
//
//     const dataArray = lines.slice(1).map(line => {
//       const values = line.split('\t').map(v => v.trim());
//       const row = {};
//       headers.forEach((header, index) => {
//         row[header] = values[index] ?? '';
//       });
//       return row;
//     });
//
//     const outputPath = path.join(__dirname, jsonOutputName);
//     fs.writeFileSync(outputPath, JSON.stringify(dataArray, null, 2), 'utf8');
//     console.log(`✅ JSON 文件已保存至: ${outputPath}`);
//     return dataArray;
//
//   } catch (err) {
//     console.error("❌ 文件处理失败:", err);
//     return [];
//   }
// }
// const txtPath = path.join(__dirname, './tfnetwork/matched_TFrna.txt');
// mountedTfDataProTxt(txtPath, 'matched_TFrna.json');
// 已经处理好的内容 生成初始节点的json文件

// function mountedAdiNetwork(){
//   const input = require('./tfnetwork/matched_TFrna.json');
//   const inputResult = transformData(input);
//   console.log(JSON.stringify(inputResult,null,2));
//   const outputPath = path.join(__dirname, 'mountedAdiNetwork.json');
//   fs.writeFileSync(outputPath, JSON.stringify(inputResult, null, 2), 'utf8');
//   console.log(`✅ JSON 文件已保存至: ${outputPath}`);
// }
// mountedAdiNetwork();





module.exports = { testByGene,filterDataByTF,transformData };
// console.log(module)
//  const  input = filterDataByTF('CLOCK')
// console.log(input)
//  transformData(input)
// console.log(transformData(input))

// console.log(testByGene('RORA'))
