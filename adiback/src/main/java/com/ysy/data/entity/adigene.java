package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("adipocytokinegene")
public class adigene {
  public String ID;
  public String gene;
  public String RelatedGeneSymbol;
  public String Ensembl;
  public String Function;
  public String ArticleTitle;
  public String PMID;
  public String YearofPublication;
  public String MoreCertifications;
  public String Abstract;

  public String getID() {
    return ID;
  }
  public String getGene() {
    return gene;
  }

}
