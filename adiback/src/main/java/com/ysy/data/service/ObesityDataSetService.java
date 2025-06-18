package com.ysy.data.service;

import com.ysy.data.dao.ObesityDataSetDao;
import com.ysy.data.entity.ObesityDataset;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("ObesityDataSetService")
public class ObesityDataSetService {
  @Resource
  ObesityDataSetDao obesityDataSetDao;

  public List<ObesityDataset> queryallodcdata(){return this.obesityDataSetDao.queryallodcdata();}
}
