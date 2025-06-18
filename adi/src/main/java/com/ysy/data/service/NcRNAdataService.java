package com.ysy.data.service;

import com.ysy.data.entity.ncRNAdata;
import org.springframework.stereotype.Service;
import com.ysy.data.dao.NcRNAdataDao;
import javax.annotation.Resource;
import java.util.List;

@Service("ncRNAdataService")
public class NcRNAdataService {

  @Resource
  private NcRNAdataDao ncRNAdataDao;

  /**
   * 查询所有 ncRNA 数据
   */
  public List<ncRNAdata> queryAllNcRNAdata() {
    return ncRNAdataDao.queryAllNcRNAdata();
  }

  /**
   * 查询简略数据（不包含 Abstract 字段）
   */
  public List<ncRNAdata> queryBriefNcRNAdata() {
    return ncRNAdataDao.queryBriefNcRNAdata();
  }

  /**
   * 根据 gene 查询单条记录
   */
  public ncRNAdata queryByncRNA(String gene) {
    return ncRNAdataDao.queryByncRNA(gene);
  }
}
