package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("synlethalitydata")

public class synlethalitydata {
  public String GeneA;
  public String GeneB;
  public String PMID;

}
