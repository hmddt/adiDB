package com.ysy.data.service;

import com.ysy.data.dao.TF2TGDao;
import com.ysy.data.entity.TF2TG;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("TF2TGService")

public class TF2TGService {

  @Resource
  TF2TGDao tf2TGDao;

  public List<TF2TG> queryalltfgene(){return this.tf2TGDao.queryalltfgene();}
}
