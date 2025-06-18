
// 词云提取筛选关键词是文本挖掘里的keyword
import data from "./gene-drugData.json";

function calculateKeywordFrequencies(dataList) {
  const keywordFrequency = {};

  dataList.forEach((data) => {
    const keywords = data.keywords.split(";").map((kw) => kw.trim());
    keywords.forEach((keyword) => {
      keywordFrequency[keyword] = (keywordFrequency[keyword] || 0) + 1;
    });
  });

  const keywordArray = Object.keys(keywordFrequency).map((keyword) => ({
    name: keyword,
    value: keywordFrequency[keyword],
  }));

  // 按 value 从大到小排序
  return keywordArray.sort((a, b) => b.value - a.value);
}


function filterDataByQuery(query) {
  const data = require('./gene-drugData.json');
  // 如果没有查询内容，则返回完整的数据
  if (!query) {
    return data;
  }

  // 过滤数据，检查每个字段是否包含搜索内容
  const searchTerm = query.toLowerCase();
  return data.filter(item => {
    return Object.values(item).some(value =>
      String(value).toLowerCase().includes(searchTerm)
    );
  });
}
function filterDIsDataByQuery(query) {
  const data = require('./gene-disData.json');
  // 如果没有查询内容，则返回完整的数据
  if (!query) {
    return data;
  }

  // 过滤数据，检查每个字段是否包含搜索内容
  const searchTerm = query.toLowerCase();
  return data.filter(item => {
    return Object.values(item).some(value =>
      String(value).toLowerCase().includes(searchTerm)
    );
  });
}


export { calculateKeywordFrequencies,filterDataByQuery,filterDIsDataByQuery };
