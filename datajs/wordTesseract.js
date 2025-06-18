const fs = require('fs');
const path = require('path');
const Tesseract = require('tesseract.js');

const folderPath = 'E:/进化树/输出图片';
const outputFilePath = 'E:/进化树/ocr_output.txt'; // 输出的文本文件

fs.readdir(folderPath, (err, files) => {
  if (err) {
    console.error('读取文件夹错误:', err);
    return;
  }

  let outputText = '';

  files.forEach((file) => {
    const filePath = path.join(folderPath, file);

    if (file.toLowerCase().endsWith('.png') || file.toLowerCase().endsWith('.jpg')) {
      Tesseract.recognize(filePath, 'eng', {
        tessedit_pageseg_mode: 6,  // 6 = Assume a uniform block of text
        logger: (m) => console.log(m)
      })
        .then(({ data: { text } }) => {
          console.log(`文件: ${file}`);
          console.log(`提取的文本:\n${text}`);

          outputText += `文件: ${file}\n${text}\n\n`;

          // 追加保存到文件
          fs.writeFileSync(outputFilePath, outputText, 'utf8');
        })
        .catch((err) => {
          console.error(`OCR 识别 ${file} 失败:`, err);
        });
    }
  });
});
