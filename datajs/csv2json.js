// 引入 Node.js 文件系统模块
const fs = require('fs');
const path = require('path');
const XLSX = require('xlsx');

// 定义一个函数将 CSV 转换为 JSON
function csvToJson(csvFilePath, jsonFilePath) {
  fs.readFile(csvFilePath, 'utf8', (err, data) => {
    if (err) {
      console.error('读取文件失败:', err);
      return;
    }

    // 使用正则表达式处理 CSV
    const parseCsv = (csvString) => {
      const rows = [];
      const lines = csvString.split(/\r?\n/).filter(line => line.trim() !== '');
      const headers = lines[0]
        .split(',')
        .map(header => header.trim().replace(/^"|"$/g, '')); // 移除列名的引号

      for (let i = 1; i < lines.length; i++) {
        const row = [];
        let current = '';
        let inQuotes = false;
        for (let char of lines[i]) {
          if (char === '"') {
            inQuotes = !inQuotes;
          } else if (char === ',' && !inQuotes) {
            row.push(current.trim());
            current = '';
          } else {
            current += char;
          }
        }
        row.push(current.trim()); // Add the last value

        const jsonObject = {};
        headers.forEach((header, index) => {
          jsonObject[header] = row[index] || '';
        });
        rows.push(jsonObject);
      }

      return rows;
    };

    const jsonArray = parseCsv(data);

    // 将 JSON 数据写入文件
    fs.writeFile(jsonFilePath, JSON.stringify(jsonArray, null, 2), 'utf8', err => {
      if (err) {
        console.error('写入文件失败:', err);
      } else {
        console.log('CSV 转换为 JSON 成功，文件路径:', jsonFilePath);
      }
    });
  });
}


// 定义一个函数将 XLSX 转换为 JSON
function xlsxToJson(xlsxFilePath, jsonFilePath) {
  // 读取 Excel 文件
  const workbook = XLSX.readFile(xlsxFilePath);

  // 假设你只想转换第一个工作表
  const sheetName = workbook.SheetNames[0];
  const worksheet = workbook.Sheets[sheetName];

  // 将工作表转换为 JSON 格式
  const jsonArray = XLSX.utils.sheet_to_json(worksheet, { header: 1 });

  // 如果需要将第一行作为头部，则需要调整
  const headers = jsonArray.shift(); // 获取第一行作为列名
  const jsonResult = jsonArray.map(row => {
    const jsonObject = {};
    row.forEach((cell, index) => {
      jsonObject[headers[index]] = cell;
    });
    return jsonObject;
  });

  // 将 JSON 数据写入文件
  fs.writeFile(jsonFilePath, JSON.stringify(jsonResult, null, 2), 'utf8', err => {
    if (err) {
      console.error('写入文件失败:', err);
    } else {
      console.log('XLSX 转换为 JSON 成功，文件路径:', jsonFilePath);
    }
  });
}


// 定义一个函数将 TXT 转换为 JSON

// delimiter 代表分隔方式  /\s{2,}/ 代表采用两个以上空格分隔，常用于在不规则空格情况下
function txtToJson(txtFilePath, jsonFilePath, delimiter = /\s{2,}/) {
  fs.readFile(txtFilePath, 'utf8', (err, data) => {
    if (err) {
      console.error('读取文件失败:', err);
      return;
    }

    // 按行分割 TXT 文件内容
    const lines = data.split(/\r?\n/).filter(line => line.trim() !== '');

    // 获取表头（第一行）
    const headers = lines[0]
      .split(delimiter)
      .map(header => header.trim()); // 去除多余空格

    // 解析数据行
    const jsonArray = lines.slice(1).map(line => {
      const row = line.split(delimiter).map(cell => cell.trim()); // 按制表符分割并去除空格
      const jsonObject = {};
      headers.forEach((header, index) => {
        jsonObject[header] = row[index] || '';
      });
      return jsonObject;
    });

    // 将 JSON 数据写入文件
    fs.writeFile(jsonFilePath, JSON.stringify(jsonArray, null, 2), 'utf8', err => {
      if (err) {
        console.error('写入文件失败:', err);
      } else {
        console.log('TXT 转换为 JSON 成功，文件路径:', jsonFilePath);
      }
    });
  });
}

// 示例用法
const inputPath = path.join(__dirname, 'chromeadigene/chromeadigene.txt'); // 输入 TXT 文件路径
const outputPath = path.join(__dirname, 'chromeadigene/chromeadigene.json'); // 输出 JSON 文件路径
// const delimiter = /\s{2,}/

const delimiter = /\t/
txtToJson(inputPath, outputPath, delimiter);
// Example usage

// const inputPath = "C://Users//28397//Desktop//肥胖数据.xlsx";
// const outputPath = path.join(__dirname, 'Obesity_dataset.json');


// csvToJson(inputPath, outputPath);
// xlsxToJson(inputPath,outputPath);
