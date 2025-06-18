package com.ysy.data.service;


import com.ysy.data.dao.DrugInteractionsDao;
import com.ysy.data.entity.DrugInteractionsDrug;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("DrugInteractionsService")
public class DrugInteractionsService {
  @Resource
  DrugInteractionsDao drugInteractionsDao;
  public List<DrugInteractionsDrug> QueryDrugInteractionsGene(String gene){
    return this.drugInteractionsDao.QueryDrugInteractionsGene(gene);
  };
}
