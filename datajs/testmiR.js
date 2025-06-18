const dataArray = require('./miRTarBase_SE_WR.json')

const uniqueSpecies = [...new Set(dataArray.map(item => item["Experiments"]))];

console.log("mIR物种：",uniqueSpecies)
