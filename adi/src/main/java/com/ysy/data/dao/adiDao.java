package com.ysy.data.dao;
import com.ysy.data.entity.adigene;

import java.util.List;

public interface adiDao {
  List<adigene> queryalladi();

  List<adigene> queryalladitoabstract();

  adigene queryById(String id);

  adigene queryByGene(String gene);


}
