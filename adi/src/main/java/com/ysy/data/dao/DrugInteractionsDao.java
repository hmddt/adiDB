package com.ysy.data.dao;

import org.springframework.http.ResponseEntity;
import  com.ysy.data.entity.DrugInteractionsDrug;

import java.util.List;

public interface DrugInteractionsDao {
  List<DrugInteractionsDrug> QueryDrugInteractionsGene(String gene);
}
