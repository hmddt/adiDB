package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("allclassifiedData")

public class TF2TG {
  public String TF;
  public String Target_gene;
  public String Function;
  public String PMID;
  public String TF_Entrez;
  public String Target_gene_Entrez;
}
