package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("adi-disease")

public class adiDisease {
  public String Diseases;
  public String PMID;
  public String Title;
  public String Abstract;
}
