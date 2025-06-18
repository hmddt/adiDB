package com.ysy.data.dao;

import com.ysy.data.entity.ncRNAdata;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface NcRNAdataDao {

  // 查询全部 ncRNA 数据
  List<ncRNAdata> queryAllNcRNAdata();

  // 查询不包含 abstract 字段的精简数据（用于分页加载等）
  List<ncRNAdata> queryBriefNcRNAdata();

  // 根据 gene 字段查询一条数据
  ncRNAdata queryByncRNA(@Param("gene") String gene);
}
