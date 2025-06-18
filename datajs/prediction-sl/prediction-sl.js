const fs = require('fs');
const path = require('path');

//Txt文件路径
const inputFilePath = path.join(__dirname,'node-prediction-sl.txt');
const outputFilePath = path.join(__dirname,'prediction-sl.json');

//读取文件内容
const rawText = fs.readFileSync(inputFilePath,`utf-8`).trim();

//折行处理
const lines = rawText.split(`\n`);

//准备数据结构
const nodes = [];
const links = [];
const nodeSet = new Set();

//跳过第一行
lines.slice(1).forEach(line=>{
  const [source, target] = line.trim().split(/\s+/);
  //添加源节点
  if(!nodeSet.has(source)){
    nodeSet.add(source);
    nodes.push({
      id:source,
      name:source,
      symbolSize:10,
      category:0,
      itemStyle:{color:`#9cbb83`}
    });
}
  //添加目标节点
  if(!nodeSet.has(target)){
    nodeSet.add(target);
    nodes.push({
      id:target,
      name:target,
      symbolSize:10,
      category:1,
      itemStyle:{color: `#9cbb83`}
    });
  }
  //添加连接线
  links.push({
    source,target,
    info:`Source:${source},Target:${target}`
  });
});
  //合并json数据
  const jsondata={
    nodes,
    links,
    categories:[
      {name:'geneA'},
      {name: 'geneB'}
    ]
  };
  // fs.writeFileSync(outputFilePath,JSON.stringify(jsondata,null,2),`utf-8`);
  // console.log(`json文件已生成，${outputFilePath}`);
console.log(module)




