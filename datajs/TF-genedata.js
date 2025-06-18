//此文件是数据处理文件 把txt提取列名处理为json文件

const fs = require('fs');
const path = require('path');


// 文件路径
const filePath = "D:/数据库项目/睡眠相关数据库/R/TF/TRRUST/TF_gene.txt";

const filePath2 = "D:/数据库项目/睡眠相关数据库/R/TF/TRRUST/trrust_data.txt";
const jsonname = "classifiedData"; // 传入文件名字符串
const jsonname2 = "allclassifiedData"; // 传入文件名字符串
// 读取并转换数据为数组
function convertFileToArray(filePath,jsonname) {
  fs.readFile(filePath, 'utf8', (err, content) => {
    if (err) {
      console.error("文件读取失败:", err);
      return;
    }

    // 按行分割数据
    const lines = content.trim().split('\n');

    // 获取列名（第一行）
    const headers = lines[0].split('\t').map(header => header.replace(/\r/g, '').trim());

    // 将每行数据转换为对象并存入数组
    const dataArray = lines.slice(1).map(line => {
      const values = line.split('\t');
      const row = {};
      headers.forEach((header, index) => {
        row[header] = values[index].replace(/\r/g, '').trim(); // 将每列数据映射到对应列名
      });
      return row;
    });

    console.log("转换后的数组:", dataArray);

    // 提取TF列,TF列去重,输出TF列
    const tf = dataArray.map(item => item.TF)
    const uniquetf = [...new Set(tf)];
    console.log("TF:",uniquetf)

    // 提取Target_gene列,Target_gene列去重,输出Target_gene列
    const tg = dataArray.map(item => item.Target_gene)
    const uniquetg = [...new Set(tg)];
    console.log("TF:",uniquetg)

    // 如果需要保存为 JSON 文件
    const outputFilePath = path.join(__dirname, `${jsonname}.json`);
    fs.writeFileSync(outputFilePath, JSON.stringify(dataArray, null, 4), 'utf8');
    console.log("数组已保存为 JSON 文件:", outputFilePath);



  });
}



// 执行转换
convertFileToArray(filePath,jsonname);
convertFileToArray(filePath2,jsonname2);
// 输出TF为指定值的数据
function filterDataByTF(tfValue) {
  const filteredData = dataArray.filter(item => item.TF === tfValue);
  console.log(`所有TF为"${tfValue}"的数据:`, filteredData);
  return filteredData;
}

// tg_result作为后续画图相关输入
// const tg_result = filterDataByTF('AHR');
// 例如，调用该函数并传入TF值
// filterDataByTF( 'AHR');
