package com.ysy.data.service;


import org.springframework.stereotype.Service;
import com.ysy.data.entity.synlethalitydata;
import com.ysy.data.dao.synlethalityDao;

import javax.annotation.Resource;
import java.util.List;

@Service("synlethalityService")
public class synlethalityService {
  @Resource synlethalityDao synlethalityDao;

  public List<synlethalitydata> queryallsldata(){return synlethalityDao.queryallsldata();}

  public List<synlethalitydata> queryByGene(String sample){

    return synlethalityDao.queryByGene(sample);
  }

}
