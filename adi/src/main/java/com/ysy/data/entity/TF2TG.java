package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@TableName("allclassifiedData")

public class TF2TG {
  @JsonProperty("tf")
  private String TF;

  @JsonProperty("targetgene")  // 指定 JSON 中的字段名
  private String Target_gene;

  @JsonProperty("function")
  private String Function;

  @JsonProperty("pmid")
  private String PMID;

  @JsonProperty("tf_Entrez")
  private String TF_Entrez;

  @JsonProperty("target_gene_Entrez")
  private String Target_gene_Entrez;

  // getters and setters
  public String getTF() {
    return TF;
  }

  public void setTF(String TF) {
    this.TF = TF;
  }

  public String getTargetgene() {
    return Target_gene;
  }

  public void setTarget_gene(String target_gene) {
    Target_gene = target_gene;
  }

  public String getFunction() {
    return Function;
  }

  public void setFunction(String function) {
    Function = function;
  }

  public String getPMID() {
    return PMID;
  }

  public void setPMID(String PMID) {
    this.PMID = PMID;
  }

  public String getTF_Entrez() {
    return TF_Entrez;
  }

  public void setTF_Entrez(String TF_Entrez) {
    this.TF_Entrez = TF_Entrez;
  }

  public String getTarget_gene_Entrez() {
    return Target_gene_Entrez;
  }

  public void setTarget_gene_Entrez(String target_gene_Entrez) {
    Target_gene_Entrez = target_gene_Entrez;
  }
}
