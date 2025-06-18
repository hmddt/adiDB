package com.ysy.data.service;

import com.ysy.data.dao.adiDao;
import com.ysy.data.entity.adigene;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("adiService")
public class adiService {
  @Resource adiDao adiDao;
  public List<adigene> queryalladi(){return this.adiDao.queryalladi();}

  public List<adigene> queryalladitoabstract(){return this.adiDao.queryalladitoabstract();}

  public adigene queryById(String id){return this.adiDao.queryById(id);}

  public adigene queryByGene(String gene){return this.adiDao.queryByGene(gene);}
}
