package com.ysy.data.dao;

import com.ysy.data.entity.synlethalitydata;

import java.util.List;

public interface synlethalityDao {
  List<synlethalitydata> queryallsldata();

  List<synlethalitydata> queryByGene(String sample);

}
