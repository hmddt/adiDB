package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("ncRNAdata")

public class ncRNAdata {
  private String gene;                // Gene Symbol
  private String ncRNAtype;           // ncRNA type
  private String pmid;                // PubMed ID
  private String articleTitle;        // Article Title
  private String abstractText;        // Abstract 内容（TEXT 字段）
  private String yearOfPublication;   // 年份
  private String species;             // 物种
  private String f8;                  // 额外字段 f8


}
