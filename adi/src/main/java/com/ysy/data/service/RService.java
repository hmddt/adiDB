package com.ysy.data.service;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.io.IoUtil;
import cn.hutool.log.StaticLog;
import com.ysy.data.util.Rutil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import sun.misc.BASE64Encoder;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

//r连接服务层
@Service
public class RService {


  //Base64编码
  public String base64Enc(File file) {
    BASE64Encoder encoder = new BASE64Encoder();
    byte[] bytes = null;
    try {
      bytes = IoUtil.readBytes(new FileInputStream(file));
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    }
    return encoder.encode(bytes);
  }

  public String getEncByNameAndCmd(String filepath, String cmd, String script) {
    // 如果图片不存在就调用R生成
    if (!FileUtil.exist(filepath)) {
      StaticLog.info("脂肪因子数据库:没有该图片, 调用R生成!");
      Rutil.runRScript(script, cmd);
    } else {
      StaticLog.info("有现成的照片, 直接返回!");
    }
    File file = FileUtil.file(filepath);
    // 图片转base64编码
    return base64Enc(file);
  }

  @Value("D:\\R\\mrnaR\\diffL.R")
  private String diffScript;
  @Value("D:/R//mrnaR/results/")
  private String imgPath;

  public String drawcheckpoint(String gene) {
    StaticLog.info("开始分析");
    String name =  gene + "_mRNA.png";//图片名称
    String filePath = imgPath + name;
    String cmd = "draw_pic('" + gene + "')";
    return getEncByNameAndCmd(filePath, cmd, diffScript);
  }

//  //本地地址
//  @Value("D:/数据库项目/脂肪因子数据库/R/script/analyze_gene_expression.R")
//  private String expressionScript;
//  @Value("D:/数据库项目/脂肪因子数据库/R/result/")
//  private String expressionImgPath;  //两个脂肪组织特异性表达结果存储位置

  @Value("/shujupan/adi/Rserve/Script/analyze_gene_expression_Rserve.R")
  private String expressionScript;
  @Value("/shujupan/PicStorage/adi/Rresult/gene_expression/")
  private String expressionImgPath;  //两个脂肪组织特异性表达结果存储位置

  public  String drawTissueExpression(String gene){
    StaticLog.info("开启两个脂肪组织特异性表达分析");
    String name = "Expression_" +  gene + ".png";
    String filePath = expressionImgPath + name;
    StaticLog.info(filePath);
    String cmd = "analyze_gene_expression(\"" + gene + "\")";
    return getEncByNameAndCmd(filePath , cmd , expressionScript);
  }
}

