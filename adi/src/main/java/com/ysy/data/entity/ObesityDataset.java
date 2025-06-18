package com.ysy.data.entity;


import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("Obesity_dataset")

public class ObesityDataset {
  public String GSEid;
  public String Title;
  public String Organism;
  public String Status;
  public String Overall_design;
  public String obese_group;
  public String lean_group;
}
