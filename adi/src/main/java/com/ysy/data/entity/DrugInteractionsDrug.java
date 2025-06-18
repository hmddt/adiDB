package com.ysy.data.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("interactions")
public class DrugInteractionsDrug {
//  名
//    gene_claim_name
//  gene_concept_id
//    gene_name
//  interaction_source_db_name
//    interaction_source_db_version
//  interaction_type
//    interaction_score
//  drug_claim_name
//    drug_concept_id
//  drug_name
//    approved
//  immunotherapy
//  anti_neoplastic
  public String gene_claim_name;
  public String gene_concept_id;
  public String gene_name;
  public String interaction_source_db_name;
  public String interaction_source_db_version;
  public String interaction_type;
  public String interactionScore;
  public String drug_claim_name;
  public String drug_concept_id;
  public String drug_name;
  public String approved;
  public String immunotherapy;
  public String anti_neoplastic;

  public String getInteractionScore() {
    return interactionScore;
  }
}
