package com.ysy.data.service;


import com.ysy.data.dao.AdiDiseaseDao;
import com.ysy.data.entity.adiDisease;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("AdiDiseaseService")
public class AdiDiseaseService {

  @Resource
  AdiDiseaseDao adiDiseaseDao;


  public List<adiDisease> queryalladidiseasedata(){return adiDiseaseDao.queryalladidiseasedata();}
}
